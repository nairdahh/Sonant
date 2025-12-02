// lib/services/book_cache_service.dart

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'persistent_cache_service.dart';
import 'advanced_book_parser_service.dart';

/// Serviciu pentru cache-uirea locală a cărților.
///
/// NOTĂ: Pe Web, cache-ul folosește memoria (Map) și IndexedDB pentru persistență.
class BookCacheService {
  // Cache în memorie pentru Web
  static final Map<String, Uint8List> _memoryCache = {};
  // Session-only parsed books cache (simple Map)
  static final Map<String, ParsedBook> _parsedBooksCache = {};

  // Quota pentru cache persistent (500MB)
  static const int maxCacheSizeBytes = 500 * 1024 * 1024;

  /// Verifică dacă cache-ul funcționează pe această platformă
  bool get isCacheSupported => kIsWeb;

  /// Generează cheie unică pentru cache
  String _getCacheKey(String bookId, String originalFileName) {
    return '${bookId}_$originalFileName';
  }

  /// Calculează SHA-256 hash pentru conținut
  String computeHash(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Verifică dacă o carte există în cache
  Future<bool> isBookCached(String bookId, String originalFileName) async {
    if (!kIsWeb) {
      return false; // Nu suportăm încă desktop/mobile
    }

    try {
      final key = _getCacheKey(bookId, originalFileName);
      return _memoryCache.containsKey(key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking cache for book $bookId: $e');
      }
      return false;
    }
  }

  /// Salvează o carte în cache
  Future<bool> saveBookToCache({
    required String bookId,
    required String originalFileName,
    required Uint8List fileBytes,
  }) async {
    if (!kIsWeb) {
      return false;
    }

    try {
      final key = _getCacheKey(bookId, originalFileName);
      _memoryCache[key] = fileBytes;

      // Persist to IndexedDB via Hive for cross-session caching
      await PersistentCacheService().saveBytes(key, fileBytes);

      // Enforce quota after save
      await PersistentCacheService().enforceQuota(maxCacheSizeBytes);

      if (kDebugMode) {
        final sizeMB = (fileBytes.length / (1024 * 1024)).toStringAsFixed(2);
        debugPrint(
            '✅ Book cached (mem + persistent): $originalFileName ($sizeMB MB)');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error caching book $bookId: $e');
      }
      return false;
    }
  }

  /// Încarcă o carte din cache
  Future<Uint8List?> loadBookFromCache({
    required String bookId,
    required String originalFileName,
  }) async {
    if (!kIsWeb) {
      return null;
    }

    try {
      final key = _getCacheKey(bookId, originalFileName);

      // 1) Memory cache
      Uint8List? bytes = _memoryCache[key];

      // 2) Persistent cache (IndexedDB via Hive)
      bytes ??= await PersistentCacheService().loadBytes(key);

      // Reduced logging - only log first time or errors
      return bytes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading book from cache $bookId: $e');
      }
      return null;
    }
  }

  /// Șterge o carte din cache
  Future<bool> deleteBookFromCache({
    required String bookId,
    required String originalFileName,
  }) async {
    if (!kIsWeb) {
      return false;
    }

    try {
      final key = _getCacheKey(bookId, originalFileName);

      _memoryCache.remove(key);
      await PersistentCacheService().deleteBytes(key);

      if (kDebugMode) {
        debugPrint('🗑️ Book removed from cache: $originalFileName');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting book from cache $bookId: $e');
      }
      return false;
    }
  }

  /// Șterge tot cache-ul de cărți
  Future<bool> clearAllCache() async {
    if (!kIsWeb) {
      return false;
    }

    try {
      _memoryCache.clear();
      await PersistentCacheService().clearAll();

      if (kDebugMode) {
        debugPrint('🗑️ All book cache cleared');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing cache: $e');
      }
      return false;
    }
  }

  /// Obține dimensiunea totală a cache-ului
  Future<int> getCacheSizeBytes() async {
    if (!kIsWeb) {
      return 0;
    }

    try {
      int totalSize = 0;

      for (final bytes in _memoryCache.values) {
        totalSize += bytes.length;
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error calculating cache size: $e');
      }
      return 0;
    }
  }

  /// Obține dimensiunea cache-ului în MB (pentru UI)
  Future<String> getCacheSizeMB() async {
    final bytes = await getCacheSizeBytes();
    final mb = bytes / (1024 * 1024);
    return mb.toStringAsFixed(2);
  }

  /// Obține numărul de cărți cached
  Future<int> getCachedBooksCount() async {
    if (!kIsWeb) {
      return 0;
    }

    try {
      return _memoryCache.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error counting cached books: $e');
      }
      return 0;
    }
  }

  /// Get comprehensive cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!kIsWeb) {
      return {
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'bookCount': 0,
        'parsedCount': 0,
      };
    }
    return await PersistentCacheService().getCacheStats();
  }

  /// Invalidate cache for specific book
  Future<bool> invalidateBook({
    required String bookId,
    required String originalFileName,
  }) async {
    if (!kIsWeb) return false;

    try {
      final key = _getCacheKey(bookId, originalFileName);

      // Remove from memory
      _memoryCache.remove(key);
      _parsedBooksCache.remove(bookId);

      // Remove from persistent
      await PersistentCacheService().deleteBytes(key);
      await PersistentCacheService().deleteJson('parsed_$bookId');

      if (kDebugMode) {
        debugPrint('🔄 Cache invalidated for: $originalFileName');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error invalidating cache: $e');
      }
      return false;
    }
  }

  // ===============================
  // Parsed in-memory (session) LRU
  // ===============================

  void cacheParsedBookInMemory(String bookId, ParsedBook book) {
    if (!kIsWeb) return;
    _parsedBooksCache[bookId] = book;
    if (kDebugMode) {
      debugPrint('💾 Parsed (session) cached: $bookId');
    }
  }

  ParsedBook? getParsedBookFromMemory(String bookId) {
    if (!kIsWeb) return null;
    return _parsedBooksCache[bookId];
  }
}
