// lib/services/tts_service.dart - TTS Service with Kokoro API integration

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/tts_response.dart';
import '../utils/audio_url_helper.dart';

class TTSService {
  static const String _kokoroUrl = 'https://tts.nairdah.me';

  /// Get TTS endpoint from environment or fallback to hardcoded URL
  static String get ttsEndpoint =>
      dotenv.get('TTS_ENDPOINT', fallback: _kokoroUrl);
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxRetries = 2;

  /// Maximum text length for TTS synthesis (Kokoro limit: ~5000 characters)
  static const int maxTextLength = 5000;

  /// Default normalization options - match API defaults
  static const NormalizationOptions defaultNormalization = NormalizationOptions(
    normalize: true,
    unitNormalization: false,
    urlNormalization: true,
    emailNormalization: true,
    optionalPluralizationNormalization: true,
    phoneNormalization: true,
    replaceRemainingSymbols: true,
  );

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
      debugPrint(
          'TTSService dispose - cleanup ${_activeRequests.length} requests');
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
  Future<TtsResponse?> synthesizeSpeech(
    String text, {
    String voiceId = 'af_bella',
    String? bookId,
    int? pageIndex,
    Function(double)? onProgress,
    double speed = 1.0,
    double volume = 1.0,
    NormalizationOptions? normalizationOptions,
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

        // Pre-process text to remove problematic characters for Kokoro API
        final originalLength = textToSynthesize.length;
        textToSynthesize = _normalizeTextForTTS(textToSynthesize);

        if (kDebugMode && textToSynthesize.length != originalLength) {
          debugPrint(
              'TTS: Text normalized: $originalLength -> ${textToSynthesize.length} chars');
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
          'return_timestamps': true,
          'volume_multiplier': volume,
          'normalization_options':
              (normalizationOptions ?? defaultNormalization).toJson(),
        };

        final response = await _httpClient
            .post(
          Uri.parse('$baseUrl/dev/captioned_speech'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
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
          // Pass both original text (for positions) and normalized text (for API)
          final result =
              _parseKokoroResponse(response.body, text, textToSynthesize);

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
  /// Maps timestamps from normalized text back to original text positions
  TtsResponse _parseKokoroResponse(
    String responseBody,
    String originalText,
    String normalizedText,
  ) {
    try {
      final data = jsonDecode(responseBody);

      final audioBase64 = data['audio'] as String?;
      final timestampsJson = data['timestamps'] as List<dynamic>?;

      if (audioBase64 == null || timestampsJson == null) {
        throw Exception('Invalid Kokoro response format');
      }

      final audioBytes = base64Decode(audioBase64);
      // Use Blob URL on Web for better performance, data URI on native
      final audioUrl = createAudioUrl(base64Encode(audioBytes));

      // Build word positions from ORIGINAL text (what user sees)
      // Include apostrophes within words and trailing punctuation
      final originalWords = <_WordPosition>[];

      // Match words including internal apostrophes (e.g., "Adrian's", "don't")
      // CRITICAL: Include both ASCII apostrophe (') AND smart apostrophe (') U+2019
      // NOTE: Dashes and slashes are NOT included - they separate words
      // Slashes get their own highlight (Kokoro says "slash")
      final wordPattern = RegExp(r"\b[\w]+(?:[''\u2019][\w]+)*\b");

      // Symbols that get expanded and need their own highlight
      // & → "and", / → "slash", % → "percent", $ → "dollar", + → "plus"
      // @ → "at", # → "hashtag", = → "equals", © → "copyright", etc.
      final symbolPattern = RegExp(r'[&©®™/%$+@#=]');

      int textPos = 0;
      while (textPos < originalText.length) {
        // Skip whitespace (spaces, newlines, tabs)
        while (textPos < originalText.length &&
            (originalText[textPos] == ' ' ||
                originalText[textPos] == '\n' ||
                originalText[textPos] == '\r' ||
                originalText[textPos] == '\t')) {
          textPos++;
        }
        if (textPos >= originalText.length) break;

        // Skip hyphens/dashes and underscores - they don't get pronounced, just separate words
        if (originalText[textPos] == '-' ||
            originalText[textPos] == '_' ||
            originalText[textPos] == '–' ||
            originalText[textPos] == '—') {
          textPos++;
          continue;
        }

        // Check for standalone symbols that get spoken (/, &, ©, etc.)
        if (symbolPattern.hasMatch(originalText[textPos])) {
          final symbol = originalText[textPos];
          originalWords.add(_WordPosition(
            start: textPos,
            end: textPos + 1,
            word: _getExpandedSymbol(symbol),
          ));
          textPos++;
          continue;
        }

        // Check for words
        final match = wordPattern.matchAsPrefix(originalText, textPos);
        if (match != null) {
          // match.end INCLUDES the apostrophe and text after: "Adrian's" → end is after 's'
          // We want highlight to cover the ENTIRE word including apostrophe
          int wordEnd = match.end; // This is the END of word WITH apostrophe
          int endPosWithPunctuation = wordEnd;

          // Include trailing punctuation (., ! ? , ; : etc) AFTER the word
          // BUT NOT hyphens or slashes - those separate words
          final trailingPunctuation = RegExp(r'[.,!?;:\)\]\}"]');
          while (endPosWithPunctuation < originalText.length &&
              trailingPunctuation
                  .hasMatch(originalText[endPosWithPunctuation])) {
            endPosWithPunctuation++;
          }

          // Extract the full matched word (including apostrophe)
          // Example: "Adrian's" → fullWord = "Adrian's"
          // NOTE: Dashes are NOT part of words - they separate words
          final fullWord = originalText.substring(match.start, wordEnd);
          // For matching with Kokoro, we remove ALL apostrophe variants
          final wordForMatching = fullWord
              .toLowerCase()
              .replaceAll("'", '') // ASCII apostrophe
              .replaceAll("'", '') // Smart apostrophe U+2019
              .replaceAll('\u2018', ''); // Left single quote U+2018

          originalWords.add(_WordPosition(
            start: match.start,
            end:
                endPosWithPunctuation, // Includes apostrophe + text after + trailing punctuation
            word: wordForMatching,
          ));
          textPos = endPosWithPunctuation;
        } else {
          textPos++;
        }
      }

      // Build word list from NORMALIZED text (what was sent to API)
      final normalizedWords = <String>[];
      for (final match in wordPattern.allMatches(normalizedText)) {
        final word = match.group(0)!.toLowerCase();
        // Remove ALL apostrophe variants for matching with original
        final normalizedWord = word
            .replaceAll("'", '') // ASCII apostrophe
            .replaceAll("'", '') // Smart apostrophe U+2019
            .replaceAll('\u2018', ''); // Left single quote U+2018
        normalizedWords.add(normalizedWord);
      }

      if (kDebugMode) {
        debugPrint(
            'TTS: Original words: ${originalWords.length}, Normalized: ${normalizedWords.length}, Timestamps: ${timestampsJson.length}');
        if (originalWords.length < 20) {
          debugPrint(
              'TTS: Original word tokens: ${originalWords.map((w) => w.word).join(", ")}');
        }
      }

      // Calculate sentence boundaries first
      final sentenceBoundaries = _calculateSentenceBoundaries(originalText);

      final speechMarks = <SpeechMark>[];
      int originalWordIndex = 0;
      int timestampIndex = 0;

      // Map timestamps to original text words
      while (timestampIndex < timestampsJson.length &&
          originalWordIndex < originalWords.length) {
        final timestamp = timestampsJson[timestampIndex];
        final startTime = timestamp['start_time'] as num;
        final timeMs = startTime * 1000.0;
        final timestampWord = (timestamp['word'] as String?)?.toLowerCase();

        if (timestampWord == null || timestampWord.isEmpty) {
          timestampIndex++;
          continue;
        }

        // Skip punctuation-only timestamps
        if (!RegExp(r'[a-zA-Z0-9]').hasMatch(timestampWord)) {
          timestampIndex++;
          continue;
        }

        final wordPos = originalWords[originalWordIndex];

        // Check if this is a number that gets expanded
        final originalWordText = originalText
            .substring(wordPos.start, wordPos.end)
            .replaceAll(RegExp(r'[,\.]'), '');
        final isNumber = RegExp(r'^\d+$').hasMatch(originalWordText);

        if (isNumber) {
          // Collect all timestamps for this number
          // Number can be expanded as: "twenty eighteen" OR "two zero one eight"
          var numberTimestamps = <Map<String, dynamic>>[];
          int tempIndex = timestampIndex;

          // All possible number-related words
          final numberWords = RegExp(
              r'^(zero|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred|thousand|million|billion|trillion)$');

          // Count expected words based on original number length
          final digitCount = originalWordText.length;
          int wordsCollected = 0;
          int maxWords = digitCount * 2; // Safety limit

          while (
              tempIndex < timestampsJson.length && wordsCollected < maxWords) {
            final tempWord =
                (timestampsJson[tempIndex]['word'] as String?)?.toLowerCase();
            if (tempWord == null || tempWord.isEmpty) {
              tempIndex++;
              continue;
            }

            // Skip punctuation
            if (!RegExp(r'[a-zA-Z0-9]').hasMatch(tempWord)) {
              tempIndex++;
              continue;
            }

            // If it's a number word, include it
            if (numberWords.hasMatch(tempWord)) {
              numberTimestamps.add(timestampsJson[tempIndex]);
              wordsCollected++;
              tempIndex++;

              // For digit-by-digit, we expect exactly digitCount words
              // For natural reading, we stop when we hit a non-number word
            } else {
              // Not a number word, stop collecting
              break;
            }
          }

          // CRITICAL FIX: Validate we didn't collect too many timestamps
          if (numberTimestamps.length > digitCount * 3) {
            // Likely collected timestamps from next word - trim to reasonable amount
            if (kDebugMode) {
              debugPrint(
                  'TTS WARNING: Number "${originalText.substring(wordPos.start, wordPos.end)}" collected ${numberTimestamps.length} timestamps for $digitCount digits - trimming to ${digitCount * 2}');
            }
            numberTimestamps = numberTimestamps.take(digitCount * 2).toList();
          }

          if (numberTimestamps.isNotEmpty) {
            if (kDebugMode) {
              debugPrint(
                  'TTS: Number "${originalText.substring(wordPos.start, wordPos.end)}" ($digitCount digits) consumed ${numberTimestamps.length} timestamps');
            }

            // Use the first timestamp for the entire number
            final sentenceBounds =
                _findSentenceBoundary(wordPos.start, sentenceBoundaries);
            speechMarks.add(
              SpeechMark(
                time: timeMs,
                type: 'word',
                start: wordPos.start,
                end: wordPos.end,
                value: originalText.substring(wordPos.start, wordPos.end),
                sentenceStart: sentenceBounds['start'],
                sentenceEnd: sentenceBounds['end'],
              ),
            );

            // Skip all timestamps we consumed for this number
            timestampIndex = tempIndex;
            originalWordIndex++;
          } else {
            // No number timestamps found, treat as regular word
            final sentenceBounds =
                _findSentenceBoundary(wordPos.start, sentenceBoundaries);
            speechMarks.add(
              SpeechMark(
                time: timeMs,
                type: 'word',
                start: wordPos.start,
                end: wordPos.end,
                value: originalText.substring(wordPos.start, wordPos.end),
                sentenceStart: sentenceBounds['start'],
                sentenceEnd: sentenceBounds['end'],
              ),
            );
            timestampIndex++;
            originalWordIndex++;
          }
        } else {
          // Regular word - check if it has apostrophe that might be split
          // If original word contains apostrophe (like "Adrian's"), Kokoro might split it
          // into "adrian" + "s" timestamps, so we need to consume both
          final originalFullWord =
              originalText.substring(wordPos.start, wordPos.end);
          final hasApostrophe = originalFullWord.contains("'");

          // wordPos.word is already normalized (no apostrophe): "Adrian's" → "adrians"
          final expectedWord = wordPos.word;

          // CRITICAL: Normalize timestampWord for comparison (Kokoro may return variants)
          // Remove ALL apostrophe variants to match with expectedWord
          final timestampWordNormalized = timestampWord
              .replaceAll("'", '') // ASCII apostrophe
              .replaceAll("'", '') // Smart apostrophe U+2019
              .replaceAll('\u2018', ''); // Left single quote U+2018

          int timestampsToConsume = 1;

          // CRITICAL FIX: First check if normalized timestamp matches expected word exactly
          if (timestampWordNormalized == expectedWord) {
            // Perfect match - Kokoro returned the word as a single token (with or without apostrophe)
            timestampsToConsume = 1;

            if (kDebugMode && hasApostrophe) {
              debugPrint(
                  'TTS: Word "$originalFullWord" matched as single token: "$timestampWord" (normalized: "$timestampWordNormalized")');
            }
          } else if (hasApostrophe || timestampWordNormalized.isNotEmpty) {
            // Word might be split: check if current + next timestamp = expected
            // Example: "author" + "s" = "authors" OR "don" + "t" = "dont"

            // Strict apostrophe continuations (WITHOUT optional apostrophe)
            final apostropheContinuations = RegExp(r"^(s|t|re|ll|ve|d|m)$");

            // Look ahead at next timestamp
            if (timestampIndex + 1 < timestampsJson.length) {
              final nextTimestamp = timestampsJson[timestampIndex + 1];
              final nextWordRaw =
                  (nextTimestamp['word'] as String?)?.toLowerCase();
              final nextWord = nextWordRaw
                  ?.replaceAll("'", '') // ASCII apostrophe
                  .replaceAll("'", '') // Smart apostrophe U+2019
                  .replaceAll('\u2018', ''); // Left single quote U+2018

              if (nextWord != null &&
                  apostropheContinuations.hasMatch(nextWord)) {
                // Verify that combining both timestamps (normalized) equals our expected word
                final combined = timestampWordNormalized + nextWord;

                if (combined == expectedWord) {
                  // Confirmed split - consume both timestamps
                  timestampsToConsume = 2;

                  if (kDebugMode) {
                    debugPrint(
                        'TTS: Word "$originalFullWord" split verified: "$timestampWord" + next timestamp = "$combined"');
                  }
                } else {
                  // Combination doesn't match expected word - something's wrong
                  if (kDebugMode) {
                    debugPrint(
                        'TTS WARNING: Word "$originalFullWord" (expected: "$expectedWord") split mismatch: "$timestampWordNormalized" + "$nextWord" = "$combined"');
                  }
                  // Consume only 1 timestamp and let next iteration handle the rest
                  timestampsToConsume = 1;
                }
              }
            }
          }

          // Additional debug logging for persistent mismatches
          if (timestampsToConsume == 1 &&
              timestampWordNormalized != expectedWord &&
              kDebugMode) {
            debugPrint(
                'TTS WARNING: Word mismatch - expected: "$expectedWord", got: "$timestampWord" (normalized: "$timestampWordNormalized")');
          }

          final sentenceBounds =
              _findSentenceBoundary(wordPos.start, sentenceBoundaries);
          speechMarks.add(
            SpeechMark(
              time: timeMs,
              type: 'word',
              start: wordPos.start,
              end: wordPos.end,
              value: originalFullWord,
              sentenceStart: sentenceBounds['start'],
              sentenceEnd: sentenceBounds['end'],
            ),
          );

          timestampIndex += timestampsToConsume;
          originalWordIndex++;
        }
      }

      if (kDebugMode) {
        debugPrint('TTS: Created ${speechMarks.length} speech marks');
      }

      return TtsResponse(
        audioUrl: audioUrl,
        speechMarks: speechMarks,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Synthesizes a single sentence and returns both base64 audio and speech marks
  /// Used for sentence-by-sentence TTS with caching
  Future<SentenceTtsResult?> synthesizeSentence(
    String text, {
    String voiceId = 'af_bella',
    double speed = 1.0,
    double volume = 1.0,
    NormalizationOptions? normalizationOptions,
    String? sentenceId,
  }) async {
    final reqId =
        'sentence_${DateTime.now().millisecondsSinceEpoch}_${sentenceId ?? 'unknown'}';

    try {
      // Normalize text for TTS
      String textToSynthesize = text.trim();
      if (textToSynthesize.isEmpty) {
        return null;
      }

      final originalText = textToSynthesize;
      textToSynthesize = _normalizeTextForTTS(textToSynthesize);

      final cancelableRequest = CancelableRequest();
      _activeRequests[reqId] = cancelableRequest;

      final requestBody = {
        'model': 'kokoro',
        'input': textToSynthesize,
        'voice': voiceId,
        'speed': speed,
        'response_format': 'mp3',
        'stream': false,
        'return_timestamps': true,
        'volume_multiplier': volume,
        'normalization_options':
            (normalizationOptions ?? defaultNormalization).toJson(),
      };

      final response = await _httpClient
          .post(
        Uri.parse('$baseUrl/dev/captioned_speech'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(_requestTimeout, onTimeout: () {
        throw TimeoutException('Request timed out after $_requestTimeout');
      });

      if (cancelableRequest.isCancelled) {
        return null;
      }

      if (response.statusCode == 200) {
        final result = _parseSentenceResponse(
            response.body, originalText, textToSynthesize);
        _activeRequests.remove(reqId);
        return result;
      } else {
        throw Exception(
            'Kokoro API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _activeRequests.remove(reqId);
      if (e is TimeoutException) {
        if (kDebugMode) {
          debugPrint('TTS sentence timeout: $e');
        }
      }
      rethrow;
    }
  }

  /// Parse response for sentence TTS - returns raw base64 and speech marks
  SentenceTtsResult _parseSentenceResponse(
    String responseBody,
    String originalText,
    String normalizedText,
  ) {
    final data = jsonDecode(responseBody);

    final audioBase64 = data['audio'] as String?;
    final timestampsJson = data['timestamps'] as List<dynamic>?;

    if (audioBase64 == null || timestampsJson == null) {
      throw Exception('Invalid Kokoro response format');
    }

    // Estimate duration from audio (MP3 at ~128kbps)
    final audioBytes = base64Decode(audioBase64);
    final estimatedDurationMs =
        (audioBytes.length / 16).round(); // Rough estimate

    // Build word positions from original text
    // Same logic as main parser - handle hyphens, slashes, and other symbols
    final wordPattern = RegExp(r"\b[\w]+(?:[''\u2019][\w]+)*\b");
    final symbolPattern = RegExp(r'[&©®™/%$+@#=]');
    final originalWords = <_WordPosition>[];

    int textPos = 0;
    while (textPos < originalText.length) {
      // Skip whitespace (spaces, newlines, tabs)
      while (textPos < originalText.length &&
          (originalText[textPos] == ' ' ||
              originalText[textPos] == '\n' ||
              originalText[textPos] == '\r' ||
              originalText[textPos] == '\t')) {
        textPos++;
      }
      if (textPos >= originalText.length) break;

      // Skip hyphens/dashes and underscores - they don't get pronounced
      if (originalText[textPos] == '-' ||
          originalText[textPos] == '_' ||
          originalText[textPos] == '–' ||
          originalText[textPos] == '—') {
        textPos++;
        continue;
      }

      // Check for symbols that get spoken (/, &, etc.)
      if (symbolPattern.hasMatch(originalText[textPos])) {
        final symbol = originalText[textPos];
        originalWords.add(_WordPosition(
          start: textPos,
          end: textPos + 1,
          word: _getExpandedSymbol(symbol),
        ));
        textPos++;
        continue;
      }

      final match = wordPattern.matchAsPrefix(originalText, textPos);
      if (match != null) {
        int wordEnd = match.end;
        int endPosWithPunctuation = wordEnd;

        // Don't include hyphens or slashes in trailing punctuation
        final trailingPunctuation = RegExp(r'[.,!?;:\)\]\}"]');
        while (endPosWithPunctuation < originalText.length &&
            trailingPunctuation.hasMatch(originalText[endPosWithPunctuation])) {
          endPosWithPunctuation++;
        }

        final fullWord = originalText.substring(match.start, wordEnd);
        final wordForMatching = fullWord
            .toLowerCase()
            .replaceAll("'", '')
            .replaceAll("'", '')
            .replaceAll('\u2018', '');

        originalWords.add(_WordPosition(
          start: match.start,
          end: endPosWithPunctuation,
          word: wordForMatching,
        ));
        textPos = endPosWithPunctuation;
      } else {
        textPos++;
      }
    }

    // Convert timestamps to speech marks
    final speechMarks = <SpeechMark>[];
    int originalWordIndex = 0;
    int timestampIndex = 0;

    while (timestampIndex < timestampsJson.length &&
        originalWordIndex < originalWords.length) {
      final timestamp = timestampsJson[timestampIndex];
      final startTime = timestamp['start_time'] as num;
      final timeMs = startTime * 1000.0;
      final timestampWord = (timestamp['word'] as String?)?.toLowerCase();

      if (timestampWord == null || timestampWord.isEmpty) {
        timestampIndex++;
        continue;
      }

      if (!RegExp(r'[a-zA-Z0-9]').hasMatch(timestampWord)) {
        timestampIndex++;
        continue;
      }

      final wordPos = originalWords[originalWordIndex];

      speechMarks.add(
        SpeechMark(
          time: timeMs,
          type: 'word',
          start: wordPos.start,
          end: wordPos.end,
          value: originalText.substring(wordPos.start, wordPos.end),
        ),
      );

      timestampIndex++;
      originalWordIndex++;
    }

    return SentenceTtsResult(
      audioBase64: audioBase64,
      speechMarks: speechMarks,
      durationMs: estimatedDurationMs,
    );
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

  /// Convert text to phonemes using Kokoro's phonemization
  /// Useful for debugging pronunciation and understanding IPA
  Future<PhonemeResult> phonemizeText(
    String text, {
    String languageCode = 'a', // 'a' = American English
  }) async {
    try {
      final requestBody = {
        'text': text,
        'language': languageCode,
      };

      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/dev/phonemize'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PhonemeResult(
          phonemes: data['phonemes'] as String,
          tokens: (data['tokens'] as List).map((t) => t as int).toList(),
        );
      } else {
        throw Exception(
            'Phonemize API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Phonemize error: $e');
      }
      rethrow;
    }
  }

  /// Generate audio directly from phonemes
  /// Provides complete control over pronunciation
  Future<TtsResponse?> synthesizeFromPhonemes(
    String phonemes, {
    String voiceId = 'af_bella',
    double speed = 1.0,
    double volume = 1.0,
  }) async {
    try {
      final requestBody = {
        'phonemes': phonemes,
        'voice': voiceId,
      };

      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/dev/generate_from_phonemes'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioBase64 = data['audio'] as String?;

        if (audioBase64 == null) {
          throw Exception('Invalid response: missing audio data');
        }

        final audioBytes = base64Decode(audioBase64);
        final audioUrl = createAudioUrl(base64Encode(audioBytes));

        // No timestamps available from phoneme generation
        return TtsResponse(
          audioUrl: audioUrl,
          speechMarks: [],
        );
      } else {
        throw Exception(
            'Generate from phonemes error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Generate from phonemes error: $e');
      }
      rethrow;
    }
  }

  /// Combine multiple voices into a new voice
  /// Returns the combined voice as a base64 string that can be saved
  Future<String> combineVoices(List<String> voiceIds) async {
    if (voiceIds.length < 2) {
      throw Exception('At least 2 voices are required to combine');
    }

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/v1/audio/voices/combine'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(voiceIds),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Response is the .pt file as bytes
        final bytes = response.bodyBytes;
        return base64Encode(bytes);
      } else {
        throw Exception(
            'Combine voices error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Combine voices error: $e');
      }
      rethrow;
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

  /// Returns the expanded word(s) for a symbol, matching what Kokoro will say
  String _getExpandedSymbol(String symbol) {
    switch (symbol) {
      case '&':
        return 'and';
      case '/':
        return 'slash';
      case '%':
        return 'percent';
      case r'$':
        return 'dollar'; // or 'dollars' depending on context
      case '+':
        return 'plus';
      case '@':
        return 'at';
      case '#':
        return 'hashtag'; // or 'number' in some contexts
      case '=':
        return 'equals';
      case '©':
        return 'copyright';
      case '®':
        return 'registered';
      case '™':
        return 'trademark';
      default:
        return symbol.toLowerCase();
    }
  }

  /// Normalizes text for TTS by replacing problematic characters
  /// that cause Kokoro API to return incomplete timestamps
  /// IMPORTANT: Must match Kokoro's text normalization to keep sync
  String _normalizeTextForTTS(String text) {
    String normalized = text;

    // Process numbers first - convert to digit-by-digit for long numbers
    normalized = _normalizeNumbers(normalized);

    // Replace ampersand with "and" (Kokoro does this anyway, so we need to match)
    normalized = normalized.replaceAll('&', 'and');

    // Replace smart quotes and apostrophes with regular ones
    // IMPORTANT: Keep apostrophes in words - don't remove them!
    normalized = normalized.replaceAll('\u2018', "'"); // Left single quote
    normalized =
        normalized.replaceAll('\u2019', "'"); // Right single quote/apostrophe
    normalized = normalized.replaceAll('\u201C', '"'); // Left double quote
    normalized = normalized.replaceAll('\u201D', '"'); // Right double quote

    // Normalize other apostrophe variants
    normalized = normalized.replaceAll('`', "'");

    // Replace em dash and en dash with SPACE (not hyphen!)
    // This ensures words like "Dragon—Governance" are read as TWO separate words
    // allowing individual highlighting while maintaining sync
    normalized = normalized.replaceAll('—', ' ');
    normalized = normalized.replaceAll('–', ' ');

    // Replace copyright symbol (this breaks Kokoro API completely)
    normalized = normalized.replaceAll('©', ' copyright ');

    // Replace trademark symbols
    normalized = normalized.replaceAll('®', ' registered ');
    normalized = normalized.replaceAll('™', ' trademark ');

    // Replace ellipsis with three dots (Kokoro handles this)
    normalized = normalized.replaceAll('…', '...');

    // Normalize underscores to spaces (common in code/emails)
    // e.g., "user_name" becomes "user name"
    normalized = normalized.replaceAll('_', ' ');

    // Normalize multiple spaces to single space
    normalized = normalized.replaceAll(RegExp(r' +'), ' ');

    // Remove other potentially problematic Unicode characters
    // Keep ASCII printable chars, newlines, tabs, and common symbols
    normalized = normalized.replaceAllMapped(
      RegExp(r'[^\x20-\x7E\n\r\t]'),
      (match) => ' ',
    );

    return normalized;
  }

  /// Calculate sentence/paragraph boundaries in the text
  /// Returns list of {start, end} positions for each sentence
  /// IMPROVED: Better regex that handles edge cases (end of text, abbreviations)
  List<Map<String, int>> _calculateSentenceBoundaries(String text) {
    final boundaries = <Map<String, int>>[];

    // Find sentence endings more accurately:
    // - [.!?]+ one or more sentence-ending punctuation
    // - (?=\s+[A-Z]|\s*$) followed by (space + capital) OR (optional space + end of text)
    // This avoids false positives with abbreviations like "Dr. Smith"
    final sentenceEndings = RegExp(r'[.!?]+(?=\s+[A-Z]|\s*$)');
    int currentStart = 0;

    for (final match in sentenceEndings.allMatches(text)) {
      // match.end is right after the punctuation
      // Find the actual end including any trailing whitespace
      int endPos = match.end;
      while (endPos < text.length && text[endPos] == ' ') {
        endPos++;
      }

      boundaries.add({
        'start': currentStart,
        'end': endPos,
      });
      currentStart = endPos;
    }

    // Add final sentence if text doesn't end with punctuation
    if (currentStart < text.length) {
      boundaries.add({
        'start': currentStart,
        'end': text.length,
      });
    }

    return boundaries;
  }

  /// Find which sentence a word position belongs to
  Map<String, int?> _findSentenceBoundary(
      int wordPosition, List<Map<String, int>> boundaries) {
    for (final boundary in boundaries) {
      if (wordPosition >= boundary['start']! &&
          wordPosition < boundary['end']!) {
        return {
          'start': boundary['start'],
          'end': boundary['end'],
        };
      }
    }

    // Fallback - return null boundaries
    return {'start': null, 'end': null};
  }

  /// Normalizes numbers for TTS:
  /// - Years (1900-2099): read as "nineteen hundred", "twenty eighteen"
  /// - Formatted numbers (1,234 or 1.234): read normally
  /// - Long numbers (5+ digits): read digit by digit
  /// - Short numbers (1-4 digits): read normally
  String _normalizeNumbers(String text) {
    // Match numbers with optional thousand separators
    return text.replaceAllMapped(
      RegExp(r'\b\d[\d,\.]*\d\b|\b\d\b'),
      (match) {
        final numStr = match.group(0)!;

        // Remove separators to check length
        final digitsOnly = numStr.replaceAll(RegExp(r'[,\.]'), '');

        // If it has thousand separators (commas/periods), keep as is - it's formatted
        if (numStr.contains(',') ||
            (numStr.contains('.') && numStr.length > 4)) {
          return numStr; // Let Kokoro handle formatted numbers
        }

        // Check if it's a year (4 digits, 1000-2999)
        if (digitsOnly.length == 4) {
          final year = int.tryParse(digitsOnly);
          if (year != null && year >= 1000 && year < 3000) {
            return numStr; // Let Kokoro read years naturally
          }
        }

        // For long numbers (5+ digits) without separators: digit by digit
        if (digitsOnly.length >= 5) {
          // Convert to digit-by-digit with spaces
          final digitWords = digitsOnly.split('').map((d) {
            switch (d) {
              case '0':
                return 'zero';
              case '1':
                return 'one';
              case '2':
                return 'two';
              case '3':
                return 'three';
              case '4':
                return 'four';
              case '5':
                return 'five';
              case '6':
                return 'six';
              case '7':
                return 'seven';
              case '8':
                return 'eight';
              case '9':
                return 'nine';
              default:
                return d;
            }
          }).join(' ');

          return digitWords;
        }

        // Short numbers (1-4 digits): keep as is
        return numStr;
      },
    );
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

/// Result from synthesizing a single sentence
/// Contains raw base64 audio and speech marks for caching
class SentenceTtsResult {
  final String audioBase64;
  final List<SpeechMark> speechMarks;
  final int durationMs;

  SentenceTtsResult({
    required this.audioBase64,
    required this.speechMarks,
    required this.durationMs,
  });
}
