// lib/services/highlight_manager.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/tts_response.dart';
import '../widgets/highlighted_text_widget.dart';

class HighlightManager {
  final AudioPlayer audioPlayer;
  final Function(HighlightState) onStateChanged;

  // When true, position updates come from external source (WebAudioPlayer)
  // When false, we listen to audioPlayer.positionStream
  bool _useManualUpdates = false;

  // State tracking
  int _currentPageIndex = -1;
  List<SpeechMark> _speechMarks = [];
  List<WordHighlight> _wordHighlights = [];
  List<int> _wordOnlyIndices =
      []; // Maps word index to speechMark index for O(log n) search
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

  /// Set whether to use manual position updates (for Web)
  void setManualUpdateMode(bool useManual) {
    _useManualUpdates = useManual;
    if (useManual) {
      // Stop listening to just_audio when in manual mode
      _positionSubscription?.cancel();
      _positionSubscription = null;
    }
  }

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

    // PERFORMANCE FIX: Pre-build word-only index map for O(log n) binary search
    // Maps word index to speechMark index (only for type='word')
    _wordOnlyIndices.clear();
    for (int i = 0; i < _speechMarks.length; i++) {
      if (_speechMarks[i].type == 'word') {
        _wordOnlyIndices.add(i);
      }
    }

    // Start listening to position only if NOT in manual mode
    if (!_useManualUpdates) {
      _startPositionTracking();
    }

    // Notifică UI
    _notifyStateChanged();
  }

  /// Public method to update position from external source (e.g., Web Audio)
  /// Used when just_audio position stream is not available
  void updatePositionManually(Duration position) {
    if (_speechMarks.isEmpty || _wordHighlights.isEmpty) return;

    final currentMillis = position.inMilliseconds;
    _lastPlaybackPosition = position;
    _lastPageIndex = _currentPageIndex;
    _updateWordIndex(currentMillis);
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
    // Debug: log word index changes
    // No lag compensation needed - highlights change exactly when word starts
    int newWordIndex = _findCurrentWordIndex(currentMillis.toDouble());

    if (newWordIndex != _currentWordIndex) {
      _currentWordIndex = newWordIndex;
      debugPrint('🔤 Highlight word #$newWordIndex at ${currentMillis}ms');
      _notifyStateChanged();
    }
  }

  /// Finds current word index using O(log n) binary search
  /// CRITICAL FIX: Binary search directly in word-only indices (no linear scan)
  int _findCurrentWordIndex(double currentMillis) {
    if (_wordOnlyIndices.isEmpty) return -1;

    // Binary search in pre-built word-only indices
    // This eliminates the O(n) linear scan that was causing off-by-one errors
    int left = 0;
    int right = _wordOnlyIndices.length - 1;
    int result = -1;

    while (left <= right) {
      int mid = (left + right) ~/ 2;
      final markIndex = _wordOnlyIndices[mid]; // Get actual speechMark index
      final mark = _speechMarks[markIndex];

      if (mark.time <= currentMillis) {
        // This IS our answer - mid is already the correct word index!
        result = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    return result; // Returns zero-based word index directly
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
    _wordOnlyIndices = [];
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

  const HighlightState({
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

  const HighlightResumeInfo({
    required this.pageIndex,
    required this.position,
    required this.wordIndex,
  });
}
