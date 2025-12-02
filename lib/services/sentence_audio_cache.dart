// lib/services/sentence_audio_cache.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sentence_segment.dart';
import '../models/tts_response.dart';

/// Persistent cache for sentence-level TTS audio
/// Uses Hive/IndexedDB for Web persistence
class SentenceAudioCache {
  static SentenceAudioCache? _instance;
  static SentenceAudioCache get instance =>
      _instance ??= SentenceAudioCache._();

  SentenceAudioCache._();

  Box<String>? _audioBox;
  Box<String>? _metaBox;
  bool _initialized = false;

  /// In-memory cache for quick access
  final Map<String, SentenceAudio> _memoryCache = {};

  /// Maximum number of items in memory cache
  static const int _maxMemoryCacheSize = 50;

  /// Track access order for LRU eviction
  final List<String> _accessOrder = [];

  /// Initialize the cache
  Future<void> init() async {
    if (_initialized) return;

    try {
      _audioBox = await Hive.openBox<String>('sentence_audio_cache');
      _metaBox = await Hive.openBox<String>('sentence_audio_meta');
      _initialized = true;

      if (kDebugMode) {
        debugPrint('✅ SentenceAudioCache initialized');
        debugPrint('   Cached sentences: ${_audioBox?.length ?? 0}');
      }

      // Auto-cleanup old entries on startup
      await cleanup(maxAge: const Duration(days: 14));
    } catch (e) {
      debugPrint('❌ SentenceAudioCache init error: $e');
    }
  }

  /// Get cached audio for a sentence by its text hash
  Future<SentenceAudio?> get(String textHash) async {
    // Check memory cache first
    if (_memoryCache.containsKey(textHash)) {
      return _memoryCache[textHash];
    }

    // Check persistent cache
    if (_audioBox == null || _metaBox == null) return null;

    try {
      final audioBase64 = _audioBox!.get(textHash);
      final metaJson = _metaBox!.get(textHash);

      if (audioBase64 == null || metaJson == null) return null;

      final meta = jsonDecode(metaJson) as Map<String, dynamic>;

      // Parse speech marks
      final speechMarksJson = meta['speechMarks'] as List<dynamic>;
      final speechMarks = speechMarksJson
          .map((m) => SpeechMark.fromJson(m as Map<String, dynamic>))
          .toList();

      final audio = SentenceAudio(
        sentenceId: meta['sentenceId'] as String,
        textHash: textHash,
        audioBase64: audioBase64,
        speechMarks: speechMarks,
        durationMs: meta['durationMs'] as int,
        cachedAt: DateTime.parse(meta['cachedAt'] as String),
      );

      // Store in memory cache with LRU management
      _memoryCache[textHash] = audio;
      _updateAccessOrder(textHash);

      return audio;
    } catch (e) {
      debugPrint('❌ SentenceAudioCache get error: $e');
      return null;
    }
  }

  /// Check if audio is cached for a text hash
  Future<bool> has(String textHash) async {
    if (_memoryCache.containsKey(textHash)) return true;
    if (_audioBox == null) return false;
    return _audioBox!.containsKey(textHash);
  }

  /// Store audio for a sentence
  Future<void> put(SentenceAudio audio) async {
    // Always store in memory with LRU management
    _memoryCache[audio.textHash] = audio;
    _updateAccessOrder(audio.textHash);

    // Store in persistent cache
    if (_audioBox == null || _metaBox == null) return;

    try {
      // Store audio data
      await _audioBox!.put(audio.textHash, audio.audioBase64);

      // Store metadata
      final meta = {
        'sentenceId': audio.sentenceId,
        'speechMarks': audio.speechMarks.map((m) => m.toJson()).toList(),
        'durationMs': audio.durationMs,
        'cachedAt': audio.cachedAt.toIso8601String(),
      };
      await _metaBox!.put(audio.textHash, jsonEncode(meta));

      if (kDebugMode) {
        debugPrint('💾 Cached sentence audio: ${audio.sentenceId}');
      }
    } catch (e) {
      debugPrint('❌ SentenceAudioCache put error: $e');
    }
  }

  /// Remove old cached entries (older than maxAge)
  Future<void> cleanup({Duration maxAge = const Duration(days: 30)}) async {
    if (_metaBox == null || _audioBox == null) return;

    final cutoff = DateTime.now().subtract(maxAge);
    final keysToRemove = <String>[];

    for (final key in _metaBox!.keys) {
      try {
        final metaJson = _metaBox!.get(key);
        if (metaJson == null) continue;

        final meta = jsonDecode(metaJson) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(meta['cachedAt'] as String);

        if (cachedAt.isBefore(cutoff)) {
          keysToRemove.add(key as String);
        }
      } catch (_) {
        keysToRemove.add(key as String);
      }
    }

    for (final key in keysToRemove) {
      await _audioBox!.delete(key);
      await _metaBox!.delete(key);
      _memoryCache.remove(key);
    }

    if (keysToRemove.isNotEmpty && kDebugMode) {
      debugPrint(
          '🧹 Cleaned up ${keysToRemove.length} old sentence audio entries');
    }
  }

  /// Clear all cached audio
  Future<void> clear() async {
    _memoryCache.clear();
    _accessOrder.clear();
    await _audioBox?.clear();
    await _metaBox?.clear();
  }

  /// Update LRU access order and evict if needed
  void _updateAccessOrder(String key) {
    // Remove from current position if exists
    _accessOrder.remove(key);
    // Add to end (most recently used)
    _accessOrder.add(key);

    // Evict oldest if over limit
    while (
        _memoryCache.length > _maxMemoryCacheSize && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.removeAt(0);
      _memoryCache.remove(oldest);
      if (kDebugMode) {
        debugPrint('🗑️ Evicted from memory cache: $oldest');
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryCount': _memoryCache.length,
      'persistentCount': _audioBox?.length ?? 0,
    };
  }
}
