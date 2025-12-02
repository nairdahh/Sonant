import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/firestore_service.dart';
import '../services/hybrid_book_service.dart';
import '../services/sync_service.dart';

/// Global provider for the AppDatabase singleton.
///
/// This database works on ALL platforms including Web thanks to drift_flutter:
/// - Mobile/Desktop: Native SQLite via FFI
/// - Web: SQLite compiled to WASM (stored in IndexedDB)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  ref.onDispose(() {
    db.close();
  });

  return db;
});

/// Provider for the SyncService.
///
/// Handles bidirectional sync between Drift and Firestore.
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final firestore = FirebaseFirestore.instance;

  final syncService = SyncService(db, firestore);
  syncService.startPeriodicSync();

  ref.onDispose(() {
    syncService.dispose();
  });

  return syncService;
});

/// Provider for HybridBookService.
///
/// Combines Drift (local) with Firestore (cloud) for book operations.
final hybridBookServiceProvider = Provider<HybridBookService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final firestoreService = FirestoreService();
  return HybridBookService(db, firestoreService);
});

/// Provider for sync status stream.
///
/// Useful for showing sync indicators in the UI.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStatus;
});

/// Provider for watching user's saved books.
///
/// Returns a stream that emits whenever the books list changes.
final userBooksStreamProvider =
    StreamProvider.family<List<SavedBookEntry>, String>((ref, userId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchUserBooks(userId);
});

/// Provider for getting user's reader settings.
///
/// Returns the current settings or null if none exist.
final readerSettingsProvider =
    FutureProvider.family<ReaderSettingsEntry?, String>((ref, userId) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getSettings(userId);
});

/// Provider for pending sync operations count.
///
/// Useful for showing sync status in the UI.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .select(db.syncQueueTable)
      .watch()
      .map((ops) => ops.where((op) => op.status == 'pending').length);
});
