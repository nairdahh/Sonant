// lib/services/sentence_tts_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sentence_segment.dart';
import '../utils/audio_url_helper.dart' as audio_helper;
import 'sentence_audio_cache.dart';
import 'tts_service.dart';

/// Callback types for TTS events
typedef OnSentenceReady = void Function(int sentenceIndex, SentenceAudio audio);
typedef OnPlaybackProgress = void Function(int sentenceIndex, double progress);
typedef OnError = void Function(String error);

/// Controller for sentence-by-sentence TTS with caching and preloading
class SentenceTTSController {
  final TTSService _ttsService;
  final SentenceAudioCache _cache = SentenceAudioCache.instance;

  /// Voice settings
  String voiceId = 'af_bella';
  double speed = 1.0;

  /// Current sentences being processed
  List<SentenceSegment> _sentences = [];

  /// Preloading state
  final Set<int> _preloadingIndices = {};
  final Map<int, SentenceAudio> _readyAudio = {};

  /// Current playback state
  int _currentSentenceIndex = -1;
  bool _isPlaying = false;
  bool _disposed = false;

  /// Number of sentences to preload ahead
  static const int _preloadAhead = 5;

  /// Maximum retries for failed sentence generation
  static const int _maxRetries = 2;

  /// Callbacks
  OnSentenceReady? onSentenceReady;
  OnPlaybackProgress? onProgress;
  OnError? onError;

  SentenceTTSController({
    required TTSService ttsService,
  }) : _ttsService = ttsService;

  /// Initialize with sentences from a page
  Future<void> initialize(List<SentenceSegment> sentences) async {
    _sentences = sentences;
    _currentSentenceIndex = -1;
    _readyAudio.clear();
    _preloadingIndices.clear();

    // Initialize cache
    await _cache.init();

    // Check which sentences are already cached
    int cachedCount = 0;
    for (int i = 0; i < sentences.length; i++) {
      final cached = await _cache.get(sentences[i].textHash);
      if (cached != null) {
        _readyAudio[i] = cached;
        cachedCount++;
      }
    }

    if (kDebugMode) {
      debugPrint(
          '📝 SentenceTTS initialized: ${sentences.length} sentences, $cachedCount cached');
    }
  }

  /// Start playback from a specific sentence
  /// Returns the first ready audio for immediate playback
  Future<SentenceAudio?> startFrom(int sentenceIndex) async {
    if (sentenceIndex >= _sentences.length) return null;

    _currentSentenceIndex = sentenceIndex;
    _isPlaying = true;

    // Check if already cached
    if (_readyAudio.containsKey(sentenceIndex)) {
      if (kDebugMode) {
        debugPrint('⚡ Sentence $sentenceIndex from cache');
      }
      _preloadUpcoming();
      return _readyAudio[sentenceIndex];
    }

    // Check persistent cache
    final sentence = _sentences[sentenceIndex];
    final cached = await _cache.get(sentence.textHash);
    if (cached != null) {
      _readyAudio[sentenceIndex] = cached;
      if (kDebugMode) {
        debugPrint('⚡ Sentence $sentenceIndex from persistent cache');
      }
      _preloadUpcoming();
      return cached;
    }

    // Generate if not cached
    if (kDebugMode) {
      debugPrint(
          '🎤 Generating sentence $sentenceIndex: "${sentence.text.substring(0, sentence.text.length.clamp(0, 50))}..."');
    }

    final audio = await _generateSentenceAudio(sentenceIndex);
    if (audio != null) {
      _preloadUpcoming();
    }
    return audio;
  }

  /// Move to next sentence
  Future<SentenceAudio?> nextSentence() async {
    if (_currentSentenceIndex + 1 >= _sentences.length) {
      _isPlaying = false;
      return null;
    }

    _currentSentenceIndex++;

    // Check if already ready
    if (_readyAudio.containsKey(_currentSentenceIndex)) {
      if (kDebugMode) {
        debugPrint('▶️ Next sentence $_currentSentenceIndex ready');
      }
      _preloadUpcoming();
      return _readyAudio[_currentSentenceIndex];
    }

    // Wait for it to be generated
    if (kDebugMode) {
      debugPrint('⏳ Waiting for sentence $_currentSentenceIndex');
    }

    return await _generateSentenceAudio(_currentSentenceIndex);
  }

  /// Get audio for a specific sentence (from cache or generate)
  Future<SentenceAudio?> getAudioFor(int sentenceIndex) async {
    if (sentenceIndex >= _sentences.length) return null;

    // Check memory
    if (_readyAudio.containsKey(sentenceIndex)) {
      return _readyAudio[sentenceIndex];
    }

    // Check persistent cache
    final sentence = _sentences[sentenceIndex];
    final cached = await _cache.get(sentence.textHash);
    if (cached != null) {
      _readyAudio[sentenceIndex] = cached;
      return cached;
    }

    // Generate
    return await _generateSentenceAudio(sentenceIndex);
  }

  /// Generate TTS for a sentence using the new synthesizeSentence method
  Future<SentenceAudio?> _generateSentenceAudio(int sentenceIndex,
      {int attempt = 0}) async {
    if (_disposed) return null;
    if (sentenceIndex >= _sentences.length) return null;
    if (_preloadingIndices.contains(sentenceIndex)) {
      // Already being generated, wait for it
      int waitCount = 0;
      while (_preloadingIndices.contains(sentenceIndex) &&
          !_disposed &&
          waitCount < 100) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      return _readyAudio[sentenceIndex];
    }

    _preloadingIndices.add(sentenceIndex);

    try {
      final sentence = _sentences[sentenceIndex];

      // Use the new synthesizeSentence method for raw base64 + speech marks
      final result = await _ttsService.synthesizeSentence(
        sentence.text,
        voiceId: voiceId,
        speed: speed,
        sentenceId: sentence.id,
      );

      if (result == null || _disposed) {
        _preloadingIndices.remove(sentenceIndex);
        return null;
      }

      final audio = SentenceAudio(
        sentenceId: sentence.id,
        textHash: sentence.textHash,
        audioBase64: result.audioBase64,
        speechMarks: result.speechMarks,
        durationMs: result.durationMs,
        cachedAt: DateTime.now(),
      );

      _readyAudio[sentenceIndex] = audio;

      // Cache persistently
      await _cache.put(audio);

      onSentenceReady?.call(sentenceIndex, audio);

      if (kDebugMode) {
        debugPrint('✅ Sentence $sentenceIndex ready (${audio.durationMs}ms)');
      }

      _preloadingIndices.remove(sentenceIndex);
      return audio;
    } catch (e) {
      _preloadingIndices.remove(sentenceIndex);

      // Retry on failure
      if (attempt < _maxRetries) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Sentence $sentenceIndex failed, retry ${attempt + 1}/$_maxRetries');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        return _generateSentenceAudio(sentenceIndex, attempt: attempt + 1);
      }

      if (kDebugMode) {
        debugPrint(
            '❌ Sentence $sentenceIndex error after $_maxRetries retries: $e');
      }
      onError?.call('Failed to generate sentence $sentenceIndex: $e');
      return null;
    }
  }

  /// Preload upcoming sentences in background
  void _preloadUpcoming() {
    if (_disposed || !_isPlaying) return;

    for (int i = 1; i <= _preloadAhead; i++) {
      final idx = _currentSentenceIndex + i;
      if (idx < _sentences.length &&
          !_readyAudio.containsKey(idx) &&
          !_preloadingIndices.contains(idx)) {
        // Fire and forget preload
        _generateSentenceAudio(idx);
      }
    }
  }

  /// Check if a sentence is ready for playback
  bool isSentenceReady(int sentenceIndex) {
    return _readyAudio.containsKey(sentenceIndex);
  }

  /// Get current sentence index
  int get currentSentenceIndex => _currentSentenceIndex;

  /// Get total sentence count
  int get sentenceCount => _sentences.length;

  /// Check if playing
  bool get isPlaying => _isPlaying;

  /// Pause preloading
  void pause() {
    _isPlaying = false;
  }

  /// Resume preloading
  void resume() {
    _isPlaying = true;
    _preloadUpcoming();
  }

  /// Stop and clear
  void stop() {
    _isPlaying = false;
    _currentSentenceIndex = -1;
  }

  /// Get all sentences
  List<SentenceSegment> get sentences => _sentences;

  /// Check if we're near the end of the current page
  /// (last 2 sentences or less remaining)
  bool get isNearPageEnd {
    if (_sentences.isEmpty) return false;
    return _currentSentenceIndex >= _sentences.length - 2;
  }

  /// Preload sentences from the next page in background
  /// This allows for smoother page transitions
  Future<void> preloadNextPageSentences(
      List<SentenceSegment> nextPageSentences) async {
    if (_disposed) return;

    // Only preload first 3 sentences of next page
    final preloadCount = nextPageSentences.length.clamp(0, 3);

    for (int i = 0; i < preloadCount; i++) {
      final sentence = nextPageSentences[i];

      // Check if already cached
      final cached = await _cache.get(sentence.textHash);
      if (cached != null) {
        if (kDebugMode) {
          debugPrint('⏩ Next page sentence $i already cached');
        }
        continue;
      }

      // Generate in background
      if (kDebugMode) {
        debugPrint('⏩ Preloading next page sentence $i');
      }

      try {
        final result = await _ttsService.synthesizeSentence(
          sentence.text,
          voiceId: voiceId,
          speed: speed,
          sentenceId: sentence.id,
        );

        if (result != null && !_disposed) {
          final audio = SentenceAudio(
            sentenceId: sentence.id,
            textHash: sentence.textHash,
            audioBase64: result.audioBase64,
            speechMarks: result.speechMarks,
            durationMs: result.durationMs,
            cachedAt: DateTime.now(),
          );

          await _cache.put(audio);

          if (kDebugMode) {
            debugPrint('✅ Next page sentence $i cached');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Failed to preload next page sentence $i: $e');
        }
      }
    }
  }

  /// Create audio URL from cached audio base64
  String getAudioUrl(SentenceAudio audio) {
    if (audio.audioBase64.isEmpty) {
      return '';
    }
    return audio_helper.createAudioUrl(audio.audioBase64);
  }

  void dispose() {
    _disposed = true;
    _isPlaying = false;
    _sentences.clear();
    _readyAudio.clear();
    _preloadingIndices.clear();
  }
}
