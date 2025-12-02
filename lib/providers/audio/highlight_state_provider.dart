// lib/providers/audio/highlight_state_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../widgets/highlighted_text_widget.dart';

part 'highlight_state_provider.freezed.dart';
part 'highlight_state_provider.g.dart';

/// Highlight state with current page and word indices
@freezed
class HighlightData with _$HighlightData {
  const factory HighlightData({
    @Default(-1) int currentPageIndex,
    @Default(-1) int currentWordIndex,
    @Default([]) List<WordHighlight> wordHighlights,
    @Default(false) bool isActive,
  }) = _HighlightData;
}

/// StateNotifier provider for highlight state
@riverpod
class HighlightState extends _$HighlightState {
  @override
  HighlightData build() => const HighlightData();

  void initializeForPage({
    required int pageIndex,
    required List<WordHighlight> wordHighlights,
  }) {
    state = HighlightData(
      currentPageIndex: pageIndex,
      currentWordIndex: -1,
      wordHighlights: wordHighlights,
      isActive: true,
    );
  }

  void updateWordIndex(int wordIndex) {
    state = state.copyWith(currentWordIndex: wordIndex);
  }

  void stop() {
    state = const HighlightData();
  }
}
