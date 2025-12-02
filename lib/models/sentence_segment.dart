// lib/models/sentence_segment.dart

import 'tts_response.dart';

/// Represents a sentence or paragraph segment for TTS
class SentenceSegment {
  /// Unique ID based on book + position
  final String id;

  /// The text content of this sentence
  final String text;

  /// Start character index in the full book content
  final int startIndex;

  /// End character index in the full book content
  final int endIndex;

  /// Which page this sentence belongs to
  final int pageIndex;

  /// Index of this sentence within the page
  final int sentenceIndex;

  /// Hash of the text for cache lookup
  final String textHash;

  const SentenceSegment({
    required this.id,
    required this.text,
    required this.startIndex,
    required this.endIndex,
    required this.pageIndex,
    required this.sentenceIndex,
    required this.textHash,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'startIndex': startIndex,
        'endIndex': endIndex,
        'pageIndex': pageIndex,
        'sentenceIndex': sentenceIndex,
        'textHash': textHash,
      };

  factory SentenceSegment.fromJson(Map<String, dynamic> json) =>
      SentenceSegment(
        id: json['id'] as String,
        text: json['text'] as String,
        startIndex: json['startIndex'] as int,
        endIndex: json['endIndex'] as int,
        pageIndex: json['pageIndex'] as int,
        sentenceIndex: json['sentenceIndex'] as int,
        textHash: json['textHash'] as String,
      );
}

/// Cached audio for a sentence
class SentenceAudio {
  /// The sentence this audio belongs to
  final String sentenceId;

  /// Text hash for cache validation
  final String textHash;

  /// Base64 encoded audio data
  final String audioBase64;

  /// Speech marks for word-level highlighting
  final List<SpeechMark> speechMarks;

  /// Audio duration in milliseconds
  final int durationMs;

  /// When this was cached
  final DateTime cachedAt;

  const SentenceAudio({
    required this.sentenceId,
    required this.textHash,
    required this.audioBase64,
    required this.speechMarks,
    required this.durationMs,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
        'sentenceId': sentenceId,
        'textHash': textHash,
        'audioBase64': audioBase64,
        'speechMarks': speechMarks.map((m) => m.toJson()).toList(),
        'durationMs': durationMs,
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory SentenceAudio.fromJson(Map<String, dynamic> json) => SentenceAudio(
        sentenceId: json['sentenceId'] as String,
        textHash: json['textHash'] as String,
        audioBase64: json['audioBase64'] as String,
        speechMarks: (json['speechMarks'] as List<dynamic>)
            .map((m) => SpeechMark.fromJson(m as Map<String, dynamic>))
            .toList(),
        durationMs: json['durationMs'] as int,
        cachedAt: DateTime.parse(json['cachedAt'] as String),
      );
}
