// lib/services/hybrid_book_service.dart
//
// Hybrid service that combines local Drift database with Firestore cloud sync.
// Implements local-first architecture:
// 1. Reads from Drift (instant, offline-capable)
// 2. Writes to Drift first, then syncs to Firestore
// 3. Falls back to Firestore when needed

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import '../database/app_database.dart';
import '../models/saved_book.dart';
import 'firestore_service.dart';

/// Hybrid service for book operations - local-first with cloud sync
class HybridBookService {
  final AppDatabase _db;
  final FirestoreService _firestoreService;
  final _uuid = const Uuid();

  HybridBookService(this._db, this._firestoreService);

  /// Add a book - saves to Drift first, then uploads to Firestore
  Future<SavedBook?> addBook({
    required String userId,
    required String title,
    required String author,
    required String format,
    required Uint8List fileBytes,
    required String fileName,
    required int totalPages,
    Uint8List? coverImageBytes,
  }) async {
    final bookId = _uuid.v4();
    final contentHash = sha256.convert(fileBytes).toString();
    final now = DateTime.now();

    debugPrint('📚 HybridBookService: Adding book "$title"');

    // 1. Save to local Drift first (instant)
    try {
      final localBook = SavedBookEntry(
        id: bookId,
        userId: userId,
        title: title,
        author: author,
        format: format,
        fileUrl: null, // Will be updated after Firestore upload
        coverImageUrl: null, // Will be updated after Firestore upload
        lastPageIndex: 0,
        totalPages: totalPages,
        contentHash: contentHash,
        lastReadAt: now,
        addedAt: now,
        syncedWithFirestore: false,
        lastSyncedAt: null,
      );

      await _db.insertBook(localBook);
      debugPrint('   📱 Saved locally to Drift');
    } catch (e) {
      debugPrint('   ❌ Local save failed: $e');
      // Continue to Firestore anyway
    }

    // 2. Upload to Firestore (async, may fail)
    try {
      final firestoreBook = await _firestoreService.addBook(
        userId: userId,
        title: title,
        author: author,
        format: format,
        fileBytes: fileBytes,
        fileName: fileName,
        totalPages: totalPages,
        coverImageBytes: coverImageBytes,
      );

      if (firestoreBook != null) {
        // 3. Update local entry with Firestore URLs
        final updatedBook = SavedBookEntry(
          id: bookId,
          userId: userId,
          title: title,
          author: author,
          format: format,
          fileUrl: firestoreBook.fileUrl,
          coverImageUrl: firestoreBook.coverImageUrl,
          lastPageIndex: 0,
          totalPages: totalPages,
          contentHash: contentHash,
          lastReadAt: now,
          addedAt: now,
          syncedWithFirestore: true,
          lastSyncedAt: DateTime.now(),
        );

        await _db.upsertBook(updatedBook);
        debugPrint('   ☁️ Synced to Firestore, updated local entry');

        return firestoreBook;
      }
    } catch (e) {
      debugPrint('   ⚠️ Firestore upload failed (will retry): $e');
      // Queue for later sync
      final syncEntry = SyncQueueEntry(
        id: _uuid.v4(),
        operation: 'insert',
        targetTable: 'saved_books_table',
        rowId: bookId,
        payload: jsonEncode({
          'userId': userId,
          'title': title,
          'author': author,
          'format': format,
          'totalPages': totalPages,
          'contentHash': contentHash,
        }),
        status: 'pending',
        retryCount: 0,
        createdAt: DateTime.now(),
      );
      await _db.enqueueSyncOperation(syncEntry);
    }

    // Return local version if Firestore failed
    return SavedBook(
      id: bookId,
      userId: userId,
      title: title,
      author: author,
      format: format,
      coverImageUrl: null,
      fileUrl: '', // Empty - file not uploaded yet
      lastPageIndex: 0,
      totalPages: totalPages,
      lastReadAt: now,
      addedAt: now,
      contentHash: contentHash,
    );
  }

  /// Get user's books from local database
  Stream<List<SavedBook>> getUserBooks(String userId) {
    return _db.watchUserBooks(userId).map((entries) {
      return entries
          .map((e) => SavedBook(
                id: e.id,
                userId: e.userId,
                title: e.title,
                author: e.author ?? 'Unknown',
                format: e.format,
                coverImageUrl: e.coverImageUrl,
                fileUrl: e.fileUrl ?? '',
                lastPageIndex: e.lastPageIndex,
                totalPages: e.totalPages,
                lastReadAt: e.lastReadAt ?? DateTime.now(),
                addedAt: e.addedAt,
                contentHash: e.contentHash,
              ))
          .toList();
    });
  }

  /// Update reading progress - Drift first, then Firestore
  Future<void> updateReadingProgress({
    required String userId,
    required String bookId,
    required int lastPageIndex,
  }) async {
    // 1. Update locally (instant)
    await _db.updateBookLastPage(bookId, lastPageIndex);

    // 2. Sync to Firestore (async, can fail)
    try {
      await _firestoreService.updateReadingProgress(
        userId: userId,
        bookId: bookId,
        lastPageIndex: lastPageIndex,
      );
    } catch (e) {
      debugPrint('Firestore progress sync failed: $e');
      // Local update succeeded, Firestore will sync later
    }
  }

  /// Delete a book from both Drift and Firestore
  Future<void> deleteBook(String userId, String bookId) async {
    // 1. Delete locally
    await _db.deleteBook(bookId);

    // 2. Delete from Firestore
    try {
      await _firestoreService.deleteBook(userId, bookId);
    } catch (e) {
      debugPrint('Firestore delete failed: $e');
      // Queue for later
      final syncEntry = SyncQueueEntry(
        id: _uuid.v4(),
        operation: 'delete',
        targetTable: 'saved_books_table',
        rowId: bookId,
        payload: jsonEncode({'userId': userId}),
        status: 'pending',
        retryCount: 0,
        createdAt: DateTime.now(),
      );
      await _db.enqueueSyncOperation(syncEntry);
    }
  }

  /// Download book file - uses Firestore service
  Future<Uint8List?> downloadBookFile(String fileUrl) {
    return _firestoreService.downloadBookFile(fileUrl);
  }
}
