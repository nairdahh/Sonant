// lib/services/tts_service.dart - TTS Service with Kokoro API integration

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/polly_response.dart';

class TTSService {
  static const String _kokoroUrl = 'https://tts.nairdah.me';

  /// Get TTS endpoint from environment or fallback to hardcoded URL
  static String get ttsEndpoint => dotenv.get('TTS_ENDPOINT', fallback: _kokoroUrl);
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxRetries = 2;

  /// Maximum text length for TTS synthesis (Kokoro limit: ~5000 characters)
  static const int maxTextLength = 5000;

  String get _baseUrl => _customBaseUrl ?? ttsEndpoint;
  String? _customBaseUrl;

  final http.Client _httpClient = http.Client();
  final Map<String, CancelableRequest> _activeRequests = {};
  Timer? _cleanupTimer;

  TTSService({String? customBaseUrl}) {
    _customBaseUrl = customBaseUrl;

    _cleanupTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      _cleanupOldRequests();
    });
  }

  void dispose() {
    if (kDebugMode) {
      debugPrint('TTSService dispose - cleanup ${_activeRequests.length} requests');
    }
    _cleanupTimer?.cancel();
    _cancelAllRequests();
    _httpClient.close();
  }

  String get baseUrl => _customBaseUrl ?? _baseUrl;

  /// Health check for TTS server availability
  Future<bool> checkHealth() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/v1/audio/voices'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      }

      if (kDebugMode) {
        debugPrint('Health check failed: ${response.statusCode}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Health check error: $e');
      }
      return false;
    }
  }

  /// Synthesizes speech using Kokoro TTS with retry and cancellation support
  Future<PollyResponse?> synthesizeSpeech(
    String text, {
    String voiceId = 'af_bella',
    String? bookId,
    int? pageIndex,
    Function(double)? onProgress,
    double speed = 1.0,
  }) async {
    final reqId =
        'req_${DateTime.now().millisecondsSinceEpoch}_p${pageIndex ?? 0}';

    if (pageIndex != null) {
      final oldReq = 'req_*_p$pageIndex';
      _cancelRequestsByPattern(oldReq);
    }

    int attempt = 0;
    Exception? lastError;

    while (attempt < _maxRetries) {
      attempt++;

      try {
        String textToSynthesize = text;
        if (text.length > maxTextLength) {
          int truncateAt = maxTextLength;
          while (truncateAt > 0 && text[truncateAt] != ' ') {
            truncateAt--;
          }
          if (truncateAt < maxTextLength * 0.9) {
            truncateAt = maxTextLength;
          }
          textToSynthesize = text.substring(0, truncateAt);
        }

        final cancelableRequest = CancelableRequest();
        _activeRequests[reqId] = cancelableRequest;

        onProgress?.call(0.1);

        final requestBody = {
          'model': 'kokoro',
          'input': textToSynthesize,
          'voice': voiceId,
          'speed': speed,
          'response_format': 'mp3',
          'stream': false,
        };

        final response = await _httpClient
            .post(
          Uri.parse('$baseUrl/dev/captioned_speech'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
            .timeout(_requestTimeout, onTimeout: () {
          throw TimeoutException('Request timed out after $_requestTimeout');
        });

        if (cancelableRequest.isCancelled) {
          return null;
        }

        onProgress?.call(0.5);

        if (response.statusCode == 200) {
          final result = _parseKokoroResponse(response.body, textToSynthesize);

          if (cancelableRequest.isCancelled) {
            return null;
          }

          onProgress?.call(1.0);
          _activeRequests.remove(reqId);

          return result;
        } else {
          throw Exception(
              'Kokoro API error: ${response.statusCode} - ${response.body}');
        }
      } on TimeoutException catch (e) {
        lastError = e;
        if (_activeRequests[reqId]?.isCancelled ?? false) {
          return null;
        }
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (_activeRequests[reqId]?.isCancelled ?? false) {
          return null;
        }
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    _activeRequests.remove(reqId);
    throw lastError ?? Exception('TTS request failed');
  }

  /// Parses Kokoro API response and converts timestamps to SpeechMarks
  PollyResponse _parseKokoroResponse(String responseBody, String originalText) {
    try {
      final data = jsonDecode(responseBody);

      final audioBase64 = data['audio'] as String?;
      final timestampsJson = data['timestamps'] as List<dynamic>?;

      if (audioBase64 == null || timestampsJson == null) {
        throw Exception('Invalid Kokoro response format');
      }

      final audioBytes = base64Decode(audioBase64);
      final audioDataUri = 'data:audio/mpeg;base64,${base64Encode(audioBytes)}';

      // Build word positions map from original text
      final wordPositions = <_WordPosition>[];
      final wordPattern = RegExp(r'\b[\w]+\b');
      for (final match in wordPattern.allMatches(originalText)) {
        wordPositions.add(_WordPosition(
          start: match.start,
          end: match.end,
          word: match.group(0)!,
        ));
      }

      final speechMarks = <SpeechMark>[];
      int wordIndex = 0;

      for (var timestamp in timestampsJson) {
        final startTime = timestamp['start_time'] as num;
        final timeMs = (startTime * 1000).round();

        // Map to next available word position in original text
        if (wordIndex < wordPositions.length) {
          final wordPos = wordPositions[wordIndex];

          speechMarks.add(
            SpeechMark(
              time: timeMs,
              type: 'word',
              start: wordPos.start,
              end: wordPos.end,
              value: wordPos.word,
            ),
          );

          wordIndex++;
        }
      }

      return PollyResponse(
        audioUrl: audioDataUri,
        speechMarks: speechMarks,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get available voices from Kokoro server
  Future<List<String>> getAvailableVoices() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/v1/audio/voices'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('voices')) {
          final voices =
              (data['voices'] as List).map((v) => v.toString()).toList();
          return voices;
        }
      }

      return ['af_bella'];
    } catch (e) {
      return ['af_bella'];
    }
  }

  /// Cancel requests for a specific page
  void cancelPageRequests(int pageIndex) {
    final pattern = 'req_*_p$pageIndex';
    _cancelRequestsByPattern(pattern);
  }

  /// Cancel all active requests
  void cancelAllRequests() {
    _cancelAllRequests();
  }

  void _cancelAllRequests() {
    for (final req in _activeRequests.values) {
      req.cancel();
    }
    _activeRequests.clear();
  }

  void _cancelRequestsByPattern(String pattern) {
    final toCancel = <String>[];

    for (final key in _activeRequests.keys) {
      if (_matchesPattern(key, pattern)) {
        toCancel.add(key);
      }
    }

    for (final key in toCancel) {
      _activeRequests[key]?.cancel();
      _activeRequests.remove(key);
    }
  }

  bool _matchesPattern(String key, String pattern) {
    if (pattern.contains('*')) {
      final parts = pattern.split('*');
      return key.contains(parts.last);
    }
    return key == pattern;
  }

  void _cleanupOldRequests() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final toRemove = <String>[];

    for (final entry in _activeRequests.entries) {
      final reqTimestamp = _extractTimestamp(entry.key);
      if (reqTimestamp != null) {
        final age = now - reqTimestamp;
        if (age > 5 * 60 * 1000) {
          toRemove.add(entry.key);
          entry.value.cancel();
        }
      }
    }

    for (final key in toRemove) {
      _activeRequests.remove(key);
    }
  }

  int? _extractTimestamp(String requestId) {
    final match = RegExp(r'req_(\d+)_').firstMatch(requestId);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Cleanup old cache entries
  Future<void> cleanupCache({Duration? olderThan}) async {
    // This can be implemented if caching is added later
  }
}

/// Represents a cancelable request
class CancelableRequest {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

/// Helper class to store word positions in original text
class _WordPosition {
  final int start;
  final int end;
  final String word;

  _WordPosition({
    required this.start,
    required this.end,
    required this.word,
  });
}
