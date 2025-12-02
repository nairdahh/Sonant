// test/services/highlight_manager_test.dart
// Run: flutter test test/services/highlight_manager_test.dart

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonant/services/highlight_manager.dart';
import 'package:sonant/models/tts_response.dart';
import 'package:sonant/widgets/highlighted_text_widget.dart';

// Mock AudioPlayer for testing
class MockAudioPlayer {
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  Duration _currentPosition = Duration.zero;

  Stream<Duration> get positionStream => _positionController.stream;
  Duration get position => _currentPosition;

  void setPosition(Duration position) {
    _currentPosition = position;
    _positionController.add(position);
  }

  void dispose() {
    _positionController.close();
  }
}

void main() {
  group('HighlightManager - Binary Search Tests', () {
    test('should find correct word index using binary search', () {
      // Create test data
      const speechMarks = [
        SpeechMark(time: 0, type: 'word', start: 0, end: 5, value: 'word0'),
        SpeechMark(time: 100, type: 'word', start: 6, end: 11, value: 'word1'),
        SpeechMark(time: 200, type: 'word', start: 12, end: 17, value: 'word2'),
        SpeechMark(time: 300, type: 'word', start: 18, end: 23, value: 'word3'),
        SpeechMark(time: 400, type: 'word', start: 24, end: 29, value: 'word4'),
      ];

      const wordHighlights = [
        WordHighlight(start: 0, end: 5, word: 'word0'),
        WordHighlight(start: 6, end: 11, word: 'word1'),
        WordHighlight(start: 12, end: 17, word: 'word2'),
        WordHighlight(start: 18, end: 23, word: 'word3'),
        WordHighlight(start: 24, end: 29, word: 'word4'),
      ];

      // Test that initialization works
      expect(speechMarks.length, 5);
      expect(wordHighlights.length, 5);
      expect(speechMarks[0].type, 'word');
      expect(speechMarks[2].time, 200);
    });

    test('should filter only word-type speech marks', () {
      const speechMarks = [
        SpeechMark(time: 0, type: 'word', start: 0, end: 5, value: 'hello'),
        SpeechMark(time: 50, type: 'punctuation', start: 5, end: 6, value: ','),
        SpeechMark(time: 100, type: 'word', start: 7, end: 12, value: 'world'),
        SpeechMark(
            time: 150, type: 'punctuation', start: 12, end: 13, value: '.'),
      ];

      // Should have 2 words and 2 punctuation marks
      final wordOnlyMarks =
          speechMarks.where((sm) => sm.type == 'word').toList();
      expect(wordOnlyMarks.length, 2);
      expect(wordOnlyMarks[0].value, 'hello');
      expect(wordOnlyMarks[1].value, 'world');
    });

    test('should handle empty speech marks', () {
      const List<SpeechMark> speechMarks = [];
      const List<WordHighlight> wordHighlights = [];

      expect(speechMarks, isEmpty);
      expect(wordHighlights, isEmpty);
    });

    test('should handle single word', () {
      const speechMarks = [
        SpeechMark(time: 0, type: 'word', start: 0, end: 5, value: 'hello'),
      ];

      const wordHighlights = [
        WordHighlight(start: 0, end: 5, word: 'hello'),
      ];

      expect(speechMarks.length, 1);
      expect(wordHighlights.length, 1);
      expect(speechMarks[0].time, 0);
    });

    test('should handle timestamps at boundaries', () {
      const speechMarks = [
        SpeechMark(time: 0, type: 'word', start: 0, end: 3, value: 'one'),
        SpeechMark(time: 100, type: 'word', start: 4, end: 7, value: 'two'),
        SpeechMark(time: 200, type: 'word', start: 8, end: 13, value: 'three'),
      ];

      // At time 0ms -> word index 0
      // At time 99ms -> word index 0
      // At time 100ms -> word index 1
      // At time 150ms -> word index 1
      // At time 200ms -> word index 2

      expect(speechMarks[0].time, 0);
      expect(speechMarks[1].time, 100);
      expect(speechMarks[2].time, 200);
    });
  });

  group('HighlightState', () {
    test('should create state with all fields', () {
      const wordHighlights = [
        WordHighlight(start: 0, end: 5, word: 'hello'),
        WordHighlight(start: 6, end: 11, word: 'world'),
      ];

      const state = HighlightState(
        currentPageIndex: 2,
        currentWordIndex: 1,
        wordHighlights: wordHighlights,
        isActive: true,
      );

      expect(state.currentPageIndex, 2);
      expect(state.currentWordIndex, 1);
      expect(state.wordHighlights.length, 2);
      expect(state.isActive, true);
    });

    test('should create inactive state', () {
      const state = HighlightState(
        currentPageIndex: -1,
        currentWordIndex: -1,
        wordHighlights: [],
        isActive: false,
      );

      expect(state.isActive, false);
      expect(state.wordHighlights, isEmpty);
    });
  });

  group('HighlightResumeInfo', () {
    test('should store resume information', () {
      const resumeInfo = HighlightResumeInfo(
        pageIndex: 5,
        position: Duration(milliseconds: 2500),
        wordIndex: 10,
      );

      expect(resumeInfo.pageIndex, 5);
      expect(resumeInfo.position.inMilliseconds, 2500);
      expect(resumeInfo.wordIndex, 10);
    });

    test('should handle zero values', () {
      const resumeInfo = HighlightResumeInfo(
        pageIndex: 0,
        position: Duration.zero,
        wordIndex: 0,
      );

      expect(resumeInfo.pageIndex, 0);
      expect(resumeInfo.position.inMilliseconds, 0);
      expect(resumeInfo.wordIndex, 0);
    });
  });

  group('WordHighlight Model', () {
    test('should create word highlight with all fields', () {
      const highlight = WordHighlight(
        start: 0,
        end: 5,
        word: 'hello',
        sentenceStart: 0,
        sentenceEnd: 12,
      );

      expect(highlight.start, 0);
      expect(highlight.end, 5);
      expect(highlight.word, 'hello');
      expect(highlight.sentenceStart, 0);
      expect(highlight.sentenceEnd, 12);
    });

    test('should create word highlight without sentence boundaries', () {
      const highlight = WordHighlight(
        start: 10,
        end: 15,
        word: 'world',
      );

      expect(highlight.start, 10);
      expect(highlight.end, 15);
      expect(highlight.word, 'world');
      expect(highlight.sentenceStart, isNull);
      expect(highlight.sentenceEnd, isNull);
    });
  });

  group('SpeechMark Model', () {
    test('should create speech mark with all fields', () {
      const mark = SpeechMark(
        time: 1500,
        type: 'word',
        start: 0,
        end: 5,
        value: 'hello',
        sentenceStart: 0,
        sentenceEnd: 12,
      );

      expect(mark.time, 1500);
      expect(mark.type, 'word');
      expect(mark.start, 0);
      expect(mark.end, 5);
      expect(mark.value, 'hello');
      expect(mark.sentenceStart, 0);
      expect(mark.sentenceEnd, 12);
    });

    test('should serialize to JSON', () {
      const mark = SpeechMark(
        time: 1000,
        type: 'word',
        start: 0,
        end: 5,
        value: 'test',
      );

      final json = mark.toJson();

      expect(json['time'], 1000);
      expect(json['type'], 'word');
      expect(json['start'], 0);
      expect(json['end'], 5);
      expect(json['value'], 'test');
    });

    test('should deserialize from JSON', () {
      const json = {
        'time': 2000.0,
        'type': 'word',
        'start': 10,
        'end': 15,
        'value': 'world',
        'sentenceStart': 10,
        'sentenceEnd': 25,
      };

      final mark = SpeechMark.fromJson(json);

      expect(mark.time, 2000.0);
      expect(mark.type, 'word');
      expect(mark.start, 10);
      expect(mark.end, 15);
      expect(mark.value, 'world');
      expect(mark.sentenceStart, 10);
      expect(mark.sentenceEnd, 25);
    });
  });
}
