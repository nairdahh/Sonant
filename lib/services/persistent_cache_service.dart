// lib/services/persistent_cache_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Cross-platform persistent cache. On Web, Hive stores data in IndexedDB.
class PersistentCacheService {
  static final PersistentCacheService _instance = PersistentCacheService._();
  PersistentCacheService._();
  factory PersistentCacheService() => _instance;

  static const String _bytesBoxName = 'bytes_cache';
  static const String _jsonBoxName = 'json_cache';
  static const String _metaBoxName = 'cache_meta';
  static const String _audioBoxName = 'audio_cache';
  static const String _audioMetaBoxName = 'audio_meta';

  Box<dynamic>? _bytesBox;
  Box<dynamic>? _jsonBox;
  Box<dynamic>? _metaBox;
  Box<dynamic>? _audioBox;
  Box<dynamic>? _audioMetaBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _bytesBox = await Hive.openBox<dynamic>(_bytesBoxName);
    _jsonBox = await Hive.openBox<dynamic>(_jsonBoxName);
    _metaBox = await Hive.openBox<dynamic>(_metaBoxName);
    _audioBox = await Hive.openBox<dynamic>(_audioBoxName);
    _audioMetaBox = await Hive.openBox<dynamic>(_audioMetaBoxName);
    _initialized = true;
  }

  Future<bool> saveBytes(String key, Uint8List bytes) async {
    await init();
    try {
      await _bytesBox!.put(key, bytes);
      await _updateMetadata(key, bytes.length);
      // Reduced logging
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to persist bytes: $e');
      }
      return false;
    }
  }

  Future<Uint8List?> loadBytes(String key) async {
    await init();
    try {
      final value = await _bytesBox!.get(key);
      if (value is Uint8List) {
        await _touchMetadata(key);
        // Reduced logging - only log on first access in session
        return value;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load persisted bytes: $e');
      }
      return null;
    }
  }

  Future<bool> deleteBytes(String key) async {
    await init();
    try {
      await _bytesBox!.delete(key);
      await _metaBox!.delete(key);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete persisted bytes: $e');
      }
      return false;
    }
  }

  /// Save JSON-encoded parsed book
  Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    await init();
    try {
      final encoded = jsonEncode(json);
      await _jsonBox!.put(key, encoded);
      await _updateMetadata(key, encoded.length);
      if (kDebugMode) {
        final sizeMB = (encoded.length / (1024 * 1024)).toStringAsFixed(2);
        debugPrint('💾 Persistent JSON cached: $key ($sizeMB MB)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to persist JSON: $e');
      }
      return false;
    }
  }

  /// Load JSON-encoded parsed book
  Future<Map<String, dynamic>?> loadJson(String key) async {
    await init();
    try {
      final encoded = await _jsonBox!.get(key);
      if (encoded is String) {
        await _touchMetadata(key);
        if (kDebugMode) {
          debugPrint('📦 Persistent JSON hit: $key');
        }
        return jsonDecode(encoded) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load persisted JSON: $e');
      }
      return null;
    }
  }

  Future<bool> deleteJson(String key) async {
    await init();
    try {
      await _jsonBox!.delete(key);
      await _metaBox!.delete(key);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete persisted JSON: $e');
      }
      return false;
    }
  }

  Future<void> clearAll() async {
    await init();
    await _bytesBox!.clear();
    await _jsonBox!.clear();
    await _metaBox!.clear();
  }

  /// Get total cache size in bytes
  Future<int> getTotalSize() async {
    await init();
    int total = 0;
    for (final meta in _metaBox!.values) {
      if (meta is Map && meta['size'] != null) {
        total += meta['size'] as int;
      }
    }
    return total;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    await init();
    final totalSize = await getTotalSize();
    final bookCount = _bytesBox!.length;
    final parsedCount = _jsonBox!.length;

    return {
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'bookCount': bookCount,
      'parsedCount': parsedCount,
      'entryCount': _metaBox!.length,
    };
  }

  /// LRU eviction: remove oldest entries until under quota
  Future<void> enforceQuota(int maxBytes) async {
    await init();
    int totalSize = await getTotalSize();
    if (totalSize <= maxBytes) return;

    // Sort by lastAccessed
    final entries = <MapEntry<String, Map>>[];
    for (final key in _metaBox!.keys) {
      final meta = await _metaBox!.get(key);
      if (meta is Map) {
        entries.add(MapEntry(key.toString(), meta));
      }
    }
    entries.sort((a, b) {
      final aTime = a.value['lastAccessed'] as int? ?? 0;
      final bTime = b.value['lastAccessed'] as int? ?? 0;
      return aTime.compareTo(bTime);
    });

    // Evict oldest until under quota
    for (final entry in entries) {
      if (totalSize <= maxBytes) break;
      final size = entry.value['size'] as int? ?? 0;
      await deleteBytes(entry.key);
      await deleteJson(entry.key);
      totalSize -= size;
      if (kDebugMode) {
        debugPrint('🗑️ LRU evicted: ${entry.key}');
      }
    }
  }

  Future<void> _updateMetadata(String key, int size) async {
    await _metaBox!.put(key, {
      'size': size,
      'lastAccessed': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _touchMetadata(String key) async {
    final meta = await _metaBox!.get(key);
    if (meta is Map) {
      await _metaBox!.put(key, {
        ...meta,
        'lastAccessed': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // ============================================
  // TTS Audio Cache Methods
  // ============================================

  /// Save TTS audio data to persistent cache
  Future<bool> saveAudio(String key, Uint8List audioBytes) async {
    await init();
    try {
      await _audioBox!.put(key, audioBytes);
      await _updateAudioMetadata(key, audioBytes.length);
      if (kDebugMode) {
        final sizeKB = (audioBytes.length / 1024).toStringAsFixed(2);
        debugPrint('🔊 TTS audio cached: $key ($sizeKB KB)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to persist TTS audio: $e');
      }
      return false;
    }
  }

  /// Load TTS audio data from persistent cache
  Future<Uint8List?> loadAudio(String key) async {
    await init();
    try {
      final data = await _audioBox!.get(key);
      if (data == null) return null;

      await _touchAudioMetadata(key);

      if (data is Uint8List) {
        return data;
      } else if (data is List<int>) {
        return Uint8List.fromList(data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load TTS audio: $e');
      }
      return null;
    }
  }

  /// Delete TTS audio from persistent cache
  Future<void> deleteAudio(String key) async {
    await init();
    await _audioBox!.delete(key);
    await _audioMetaBox!.delete(key);
  }

  /// Get total size of cached TTS audio
  Future<int> getTotalAudioSize() async {
    await init();
    int total = 0;
    for (final key in _audioMetaBox!.keys) {
      final meta = await _audioMetaBox!.get(key);
      if (meta is Map && meta['size'] is int) {
        total += meta['size'] as int;
      }
    }
    return total;
  }

  /// LRU eviction for TTS audio cache
  Future<void> enforceAudioQuota(int maxBytes) async {
    await init();
    int totalSize = await getTotalAudioSize();
    if (totalSize <= maxBytes) return;

    // Sort by lastAccessed
    final entries = <MapEntry<String, Map>>[];
    for (final key in _audioMetaBox!.keys) {
      final meta = await _audioMetaBox!.get(key);
      if (meta is Map) {
        entries.add(MapEntry(key.toString(), meta));
      }
    }
    entries.sort((a, b) {
      final aTime = a.value['lastAccessed'] as int? ?? 0;
      final bTime = b.value['lastAccessed'] as int? ?? 0;
      return aTime.compareTo(bTime);
    });

    // Evict oldest until under quota
    for (final entry in entries) {
      if (totalSize <= maxBytes) break;
      final size = entry.value['size'] as int? ?? 0;
      await deleteAudio(entry.key);
      totalSize -= size;
      if (kDebugMode) {
        debugPrint('🗑️ LRU evicted TTS audio: ${entry.key}');
      }
    }
  }

  /// Clear all TTS audio cache
  Future<void> clearAudioCache() async {
    await init();
    await _audioBox!.clear();
    await _audioMetaBox!.clear();
    if (kDebugMode) {
      debugPrint('🗑️ All TTS audio cache cleared');
    }
  }

  Future<void> _updateAudioMetadata(String key, int size) async {
    await _audioMetaBox!.put(key, {
      'size': size,
      'lastAccessed': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _touchAudioMetadata(String key) async {
    final meta = await _audioMetaBox!.get(key);
    if (meta is Map) {
      await _audioMetaBox!.put(key, {
        ...meta,
        'lastAccessed': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
