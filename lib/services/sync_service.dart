// lib/services/sync_service.dart
//
// Service for synchronizing local Drift database with Firestore.
// Implements a local-first architecture where:
// 1. All writes go to Drift first (instant)
// 2. Sync operations are queued for Firestore
// 3. Background sync processes the queue when online

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final bool skipped;

  SyncResult({
    required this.synced,
    required this.failed,
    required this.skipped,
  });

  bool get hasErrors => failed > 0;
  bool get isSuccess => !hasErrors && !skipped;
}

/// Manages bidirectional sync between Drift (local) and Firestore (cloud).
class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  Timer? _syncTimer;
  bool _isSyncing = false;

  /// Stream controller for sync status updates
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  SyncService(this._db, this._firestore);

  /// Start periodic sync (call once on app startup)
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => syncPendingOperations());

    // Also sync immediately on start
    syncPendingOperations();
  }

  /// Stop periodic sync (call on app dispose)
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Process all pending sync operations
  Future<SyncResult> syncPendingOperations() async {
    if (_isSyncing) {
      debugPrint('⏳ Sync already in progress, skipping...');
      return SyncResult(synced: 0, failed: 0, skipped: true);
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    int synced = 0;
    int failed = 0;

    try {
      final pendingOps = await _db.getPendingSyncOperations();

      if (pendingOps.isEmpty) {
        debugPrint('✅ No pending sync operations');
        _syncStatusController.add(SyncStatus.idle);
        return SyncResult(synced: 0, failed: 0, skipped: false);
      }

      debugPrint('🔄 Processing ${pendingOps.length} sync operations...');

      for (final op in pendingOps) {
        try {
          await _processSyncOperation(op);
          await _db.markSyncOperationSynced(op.id);
          synced++;
        } catch (e) {
          debugPrint('❌ Sync operation ${op.id} failed: $e');
          await _db.markSyncOperationFailed(op.id);
          failed++;
        }
      }

      debugPrint('✅ Sync complete: $synced synced, $failed failed');
      _syncStatusController.add(SyncStatus.idle);
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }

    return SyncResult(synced: synced, failed: failed, skipped: false);
  }

  /// Process a single sync operation
  Future<void> _processSyncOperation(SyncQueueEntry op) async {
    final payload = jsonDecode(op.payload) as Map<String, dynamic>?;

    switch (op.operation) {
      case 'insert':
      case 'update':
        await _syncUpsert(op.targetTable, op.rowId, payload);
        break;
      case 'delete':
        await _syncDelete(op.targetTable, op.rowId, payload);
        break;
      default:
        throw Exception('Unknown sync operation: ${op.operation}');
    }
  }

  /// Sync an insert or update to Firestore
  Future<void> _syncUpsert(
      String table, String rowId, Map<String, dynamic>? payload) async {
    if (payload == null) {
      throw Exception('Payload required for upsert');
    }

    final docRef = _getFirestoreRef(table, rowId, payload);
    if (docRef == null) {
      throw Exception('Could not determine Firestore path for $table/$rowId');
    }

    // Remove local-only fields
    final cleanPayload = Map<String, dynamic>.from(payload)
      ..remove('syncedWithFirestore')
      ..remove('lastSyncedAt');

    // Convert DateTime strings back to Timestamps
    _convertDatesToTimestamps(cleanPayload);

    await docRef.set(cleanPayload, SetOptions(merge: true));
    debugPrint('   ✅ Synced $table/$rowId to Firestore');
  }

  /// Sync a delete to Firestore
  Future<void> _syncDelete(
      String table, String rowId, Map<String, dynamic>? payload) async {
    final docRef = _getFirestoreRef(table, rowId, payload);
    if (docRef == null) {
      throw Exception('Could not determine Firestore path for $table/$rowId');
    }

    await docRef.delete();
    debugPrint('   ✅ Deleted $table/$rowId from Firestore');
  }

  /// Get Firestore document reference for a table/row
  DocumentReference? _getFirestoreRef(
      String table, String rowId, Map<String, dynamic>? payload) {
    switch (table) {
      case 'users_table':
        return _firestore.collection('users').doc(rowId);

      case 'saved_books_table':
        final userId = payload?['userId'] as String?;
        if (userId == null) return null;
        return _firestore
            .collection('users')
            .doc(userId)
            .collection('books')
            .doc(rowId);

      case 'reading_progress_table':
        final bookId = payload?['bookId'] as String?;
        final userId = payload?['userId'] as String?;
        if (bookId == null || userId == null) return null;
        return _firestore
            .collection('users')
            .doc(userId)
            .collection('books')
            .doc(bookId);

      case 'reader_settings_table':
        final userId = payload?['userId'] as String?;
        if (userId == null) return null;
        return _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('reader');

      case 'bookmarks_table':
        final bookId = payload?['bookId'] as String?;
        final userId = payload?['userId'] as String?;
        if (bookId == null || userId == null) return null;
        return _firestore
            .collection('users')
            .doc(userId)
            .collection('books')
            .doc(bookId)
            .collection('bookmarks')
            .doc(rowId);

      case 'highlights_table':
        final bookId = payload?['bookId'] as String?;
        final userId = payload?['userId'] as String?;
        if (bookId == null || userId == null) return null;
        return _firestore
            .collection('users')
            .doc(userId)
            .collection('books')
            .doc(bookId)
            .collection('highlights')
            .doc(rowId);

      default:
        debugPrint('⚠️ Unknown table for Firestore sync: $table');
        return null;
    }
  }

  /// Convert DateTime ISO strings to Firestore Timestamps
  void _convertDatesToTimestamps(Map<String, dynamic> data) {
    final dateFields = [
      'createdAt',
      'lastLoginAt',
      'lastReadAt',
      'addedAt',
      'savedAt',
      'cachedAt',
      'lastAccessedAt'
    ];

    for (final field in dateFields) {
      if (data.containsKey(field) && data[field] is String) {
        try {
          final date = DateTime.parse(data[field] as String);
          data[field] = Timestamp.fromDate(date);
        } catch (_) {
          // Keep as string if parse fails
        }
      }
    }
  }

  /// Pull latest data from Firestore for a user (initial sync or refresh)
  Future<void> pullFromFirestore(String userId) async {
    debugPrint('📥 Pulling data from Firestore for user $userId...');

    try {
      // Pull books
      final booksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .get();

      debugPrint('   📚 Found ${booksSnapshot.docs.length} books in Firestore');

      for (final doc in booksSnapshot.docs) {
        final data = doc.data();
        debugPrint('   📖 Processing book: ${data['title']} (id: ${doc.id})');

        final book = SavedBookEntry(
          id: doc.id,
          userId: userId,
          title: data['title'] as String? ?? 'Untitled',
          author: data['author'] as String?,
          format: data['format'] as String? ?? 'unknown',
          fileUrl: data['fileUrl'] as String?,
          totalPages: data['totalPages'] as int? ?? 0,
          coverImageUrl: data['coverImageUrl'] as String?,
          lastPageIndex: data['lastPageIndex'] as int? ?? 0,
          contentHash: data['contentHash'] as String?,
          lastReadAt: (data['lastReadAt'] as Timestamp?)?.toDate(),
          addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          syncedWithFirestore: true,
          lastSyncedAt: DateTime.now(),
        );
        await _db.upsertBook(book);
        debugPrint('   ✅ Saved to Drift: ${book.title}');
      }

      debugPrint('   ✅ Pulled ${booksSnapshot.docs.length} books');

      // Pull settings
      final settingsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('reader')
          .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        final settings = ReaderSettingsEntry(
          id: settingsDoc.id,
          userId: userId,
          typeface: data['typeface'] as String? ?? 'Literata',
          fontScale: data['fontScale'] as double? ?? 1.0,
          lineHeightScale: data['lineHeightScale'] as double? ?? 1.5,
          useJustifyAlignment: data['useJustifyAlignment'] as bool? ?? true,
          immersiveMode: data['immersiveMode'] as bool? ?? false,
          themeMode: data['themeMode'] as String? ?? 'light',
          updatedAt: DateTime.now(),
          syncedWithFirestore: true,
          lastSyncedAt: DateTime.now(),
        );
        await _db.updateReaderSettings(settings);
        debugPrint('   ✅ Pulled reader settings');
      }
    } catch (e) {
      debugPrint('❌ Error pulling from Firestore: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicSync();
    _syncStatusController.close();
  }
}
