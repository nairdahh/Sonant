// lib/providers/reader/book_state_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/advanced_book_parser_service.dart';
import '../../models/saved_book.dart';

part 'book_state_provider.freezed.dart';
part 'book_state_provider.g.dart';

/// Current book and navigation state
@freezed
class BookState with _$BookState {
  const factory BookState({
    ParsedBook? currentBook,
    SavedBook? savedBook,
    @Default(0) int currentPageIndex,
    @Default(false) bool isLoading,
  }) = _BookState;
}

/// StateNotifier provider for book state
@riverpod
class BookStateNotifier extends _$BookStateNotifier {
  @override
  BookState build() => const BookState();

  void setBook(ParsedBook book, SavedBook? savedBook) {
    state = state.copyWith(
      currentBook: book,
      savedBook: savedBook,
      currentPageIndex: 0,
    );
  }

  void setCurrentPage(int pageIndex) {
    if (state.currentBook == null) return;
    final maxPage = state.currentBook!.pages.length - 1;
    state = state.copyWith(
      currentPageIndex: pageIndex.clamp(0, maxPage),
    );
  }

  void nextPage() {
    if (state.currentBook == null) return;
    final maxPage = state.currentBook!.pages.length - 1;
    if (state.currentPageIndex < maxPage) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex + 1);
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex - 1);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void updateSavedBook(SavedBook savedBook) {
    state = state.copyWith(savedBook: savedBook);
  }
}
