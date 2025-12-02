// lib/models/tts_response.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_response.freezed.dart';
part 'tts_response.g.dart';

/// Normalization options for text processing
/// Controls how Kokoro preprocesses text before synthesis
@freezed
class NormalizationOptions with _$NormalizationOptions {
  const factory NormalizationOptions({
    /// Normalizes input text to make it easier for the model to say
    @Default(true) bool normalize,

    /// Transforms units like 10KB to 10 kilobytes
    @Default(false) bool unitNormalization,

    /// Changes urls so they can be properly pronounced by kokoro
    @Default(true) bool urlNormalization,

    /// Changes emails so they can be properly pronounced by kokoro
    @Default(true) bool emailNormalization,

    /// Replaces (s) with s so some words get pronounced correctly
    @Default(true) bool optionalPluralizationNormalization,

    /// Changes phone numbers so they can be properly pronounced by kokoro
    @Default(true) bool phoneNormalization,

    /// Replaces the remaining symbols after normalization with their words
    @Default(true) bool replaceRemainingSymbols,
  }) = _NormalizationOptions;

  factory NormalizationOptions.fromJson(Map<String, dynamic> json) =>
      _$NormalizationOptionsFromJson(json);
}

/// Result from phonemizing text
@freezed
class PhonemeResult with _$PhonemeResult {
  const factory PhonemeResult({
    required String phonemes,
    required List<int> tokens,
  }) = _PhonemeResult;

  factory PhonemeResult.fromJson(Map<String, dynamic> json) =>
      _$PhonemeResultFromJson(json);
}

@freezed
class TtsResponse with _$TtsResponse {
  const factory TtsResponse({
    required String? audioUrl,
    required List<SpeechMark> speechMarks,
  }) = _TtsResponse;

  factory TtsResponse.fromJson(Map<String, dynamic> json) =>
      _$TtsResponseFromJson(json);
}

@freezed
class SpeechMark with _$SpeechMark {
  const factory SpeechMark({
    required double time,
    required String type,
    required int start,
    required int end,
    required String value,
    int? sentenceStart,
    int? sentenceEnd,
  }) = _SpeechMark;

  factory SpeechMark.fromJson(Map<String, dynamic> json) =>
      _$SpeechMarkFromJson(json);
}
