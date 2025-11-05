// lib/services/highlight_manager.dart

import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/tts_response.dart';
import '../widgets/highlighted_text_widget.dart';

class HighlightManager {
  final AudioPlayer audioPlayer;
  final Function(HighlightState) onStateChanged;

  // State tracking
  int _currentPageIndex = -1;
  List<SpeechMark> _speechMarks = [];
  List<WordHighlight> _wordHighlights = [];
  int _currentWordIndex = -1;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _fallbackTimer;

  // Playback tracking pentru resume
  Duration? _lastPlaybackPosition;
  int? _lastPageIndex;

  HighlightManager({
    required this.audioPlayer,
    required this.onStateChanged,
  });

  /// Initialize highlights for a new page
  void initializeForPage({
    required int pageIndex,
    required List<SpeechMark> speechMarks,
    required List<WordHighlight> wordHighlights,
  }) {

    // Cleanup anterior
    _cleanup();

    _currentPageIndex = pageIndex;
    _speechMarks = speechMarks;
    _wordHighlights = wordHighlights;
    _currentWordIndex = -1;

    // Start listening to position
    _startPositionTracking();

    // Notifică UI
    _notifyStateChanged();
  }

  /// Start tracking poziție audio pentru highlight
  void _startPositionTracking() {
    _positionSubscription?.cancel();
    _fallbackTimer?.cancel();

    // Use ONLY positionStream - no timer to avoid race conditions
    // just_audio reports position accurately, trust it completely
    _positionSubscription = audioPlayer.positionStream.listen((position) {
      if (_speechMarks.isEmpty || _wordHighlights.isEmpty) return;

      final currentMillis = position.inMilliseconds;

      _lastPlaybackPosition = position;
      _lastPageIndex = _currentPageIndex;

      _updateWordIndex(currentMillis);
    });
  }

  /// Updates word index based on current audio position
  /// Matches highlights EXACTLY to Kokoro timestamps with zero artificial delay
  void _updateWordIndex(int currentMillis) {
    // Use actual audio position directly - Kokoro timestamps are accurate
    // No lag compensation needed - highlights change exactly when word starts
    int newWordIndex = _findCurrentWordIndex(currentMillis.toDouble());

    if (newWordIndex != _currentWordIndex) {
      _currentWordIndex = newWordIndex;
      _notifyStateChanged();
    }
  }

  /// Finds current word index using O(log n) binary search
  /// Directly returns word index without HashMap overhead
  int _findCurrentWordIndex(double currentMillis) {
    if (_speechMarks.isEmpty) return -1;

    // Binary search to find the rightmost word with time <= currentMillis
    int left = 0;
    int right = _speechMarks.length - 1;
    int result = -1;

    while (left <= right) {
      int mid = (left + right) ~/ 2;
      final mark = _speechMarks[mid];

      if (mark.time <= currentMillis) {
        // This could be our answer, but check if there's a better one to the right
        if (mark.type == 'word') {
          result = mid;
        }
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    if (result == -1) return -1;

    // Count how many words come before this index
    int wordCount = 0;
    for (int i = 0; i < result; i++) {
      if (_speechMarks[i].type == 'word') {
        wordCount++;
      }
    }

    return wordCount;
  }

  void pause() {
    _positionSubscription?.pause();
    _fallbackTimer?.cancel();

    _lastPlaybackPosition = audioPlayer.position;
    _lastPageIndex = _currentPageIndex;
  }

  Future<void> resume() async {
    if (_positionSubscription?.isPaused ?? false) {
      _positionSubscription?.resume();
    }

    _startPositionTracking();
    _notifyStateChanged();
  }

  HighlightResumeInfo? getResumeInfo() {
    if (_lastPageIndex != null && _lastPlaybackPosition != null) {
      return HighlightResumeInfo(
        pageIndex: _lastPageIndex!,
        position: _lastPlaybackPosition!,
        wordIndex: _currentWordIndex,
      );
    }
    return null;
  }

  void stop() {
    _cleanup();
    _currentPageIndex = -1;
    _speechMarks = [];
    _wordHighlights = [];
    _currentWordIndex = -1;

    _lastPlaybackPosition = null;
    _lastPageIndex = null;

    _notifyStateChanged();
  }

  void _cleanup() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  void _notifyStateChanged() {
    onStateChanged(HighlightState(
      currentPageIndex: _currentPageIndex,
      currentWordIndex: _currentWordIndex,
      wordHighlights: _wordHighlights,
      isActive: _currentPageIndex >= 0,
    ));
  }

  bool isActiveOnPage(int pageIndex) {
    return _currentPageIndex == pageIndex && _currentWordIndex >= 0;
  }

  void dispose() {
    _cleanup();
  }
}

class HighlightState {
  final int currentPageIndex;
  final int currentWordIndex;
  final List<WordHighlight> wordHighlights;
  final bool isActive;

  HighlightState({
    required this.currentPageIndex,
    required this.currentWordIndex,
    required this.wordHighlights,
    required this.isActive,
  });
}

class HighlightResumeInfo {
  final int pageIndex;
  final Duration position;
  final int wordIndex;

  HighlightResumeInfo({
    required this.pageIndex,
    required this.position,
    required this.wordIndex,
  });
}
