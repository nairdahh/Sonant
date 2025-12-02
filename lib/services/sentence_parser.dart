// lib/services/sentence_parser.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/sentence_segment.dart';

/// Parses text into sentences for incremental TTS
class SentenceParser {
  /// Split text into sentences based on punctuation
  /// Handles: . ! ? and paragraph breaks
  static List<SentenceSegment> parse({
    required String text,
    required String bookId,
    required int pageIndex,
    required int pageStartIndex, // Character offset of this page in full book
  }) {
    final sentences = <SentenceSegment>[];

    if (text.trim().isEmpty) return sentences;

    // Regex to split on sentence-ending punctuation
    // Keeps the punctuation with the sentence
    // Also splits on paragraph breaks (double newlines)
    final pattern = RegExp(
      r'(?<=[.!?])\s+|(?<=\n)\n+',
      multiLine: true,
    );

    int currentIndex = 0;
    int sentenceIndex = 0;

    // Find all split positions
    final matches = pattern.allMatches(text).toList();

    for (int i = 0; i <= matches.length; i++) {
      final start = currentIndex;
      final end = i < matches.length ? matches[i].start : text.length;

      // Extract sentence text
      String sentenceText = text.substring(start, end).trim();

      // Skip empty sentences
      if (sentenceText.isEmpty) {
        if (i < matches.length) {
          currentIndex = matches[i].end;
        }
        continue;
      }

      // Calculate absolute indices
      final absoluteStart = pageStartIndex + start;
      final absoluteEnd = pageStartIndex + end;

      // Generate text hash for cache lookup
      final textHash = _generateHash(sentenceText);

      // Generate unique ID
      final id = '${bookId}_p${pageIndex}_s$sentenceIndex';

      sentences.add(SentenceSegment(
        id: id,
        text: sentenceText,
        startIndex: absoluteStart,
        endIndex: absoluteEnd,
        pageIndex: pageIndex,
        sentenceIndex: sentenceIndex,
        textHash: textHash,
      ));

      sentenceIndex++;

      if (i < matches.length) {
        currentIndex = matches[i].end;
      }
    }

    return sentences;
  }

  /// Generate MD5 hash of text for cache key
  static String _generateHash(String text) {
    // Normalize text before hashing (lowercase, trim, collapse whitespace)
    final normalized =
        text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final bytes = utf8.encode(normalized);
    return md5.convert(bytes).toString();
  }

  /// Parse all sentences from a book's pages
  static List<SentenceSegment> parseBook({
    required String bookId,
    required List<String> pageTexts,
    required List<int> pageStartIndices,
  }) {
    final allSentences = <SentenceSegment>[];

    for (int i = 0; i < pageTexts.length; i++) {
      final pageSentences = parse(
        text: pageTexts[i],
        bookId: bookId,
        pageIndex: i,
        pageStartIndex: pageStartIndices[i],
      );
      allSentences.addAll(pageSentences);
    }

    return allSentences;
  }
}
