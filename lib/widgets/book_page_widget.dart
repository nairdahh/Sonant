// lib/widgets/book_page_widget.dart

import 'package:flutter/material.dart';
import '../services/advanced_book_parser_service.dart';
import '../services/highlight_manager.dart';
import '../widgets/highlighted_text_widget.dart';
import '../models/tts_response.dart';
import '../utils/lru_cache.dart';

/// Widget pentru afișarea unei pagini din carte.
/// 
/// Include:
/// - Conținut text cu highlighting
/// - Imagini inline
/// - Titlu capitol (dacă e început de capitol)
/// - Progress bar pagină curentă
/// - Cache indicator pentru audio pre-generat
class BookPageWidget extends StatelessWidget {
  final BookPage page;
  final ParsedBook book;
  final int currentPageIndex;
  final ScrollController scrollController;
  final HighlightState highlightState;
  final LRUCache<int, TtsResponse> audioCache;
  final Function(int wordIndex) onWordTap;

  const BookPageWidget({
    super.key,
    required this.page,
    required this.book,
    required this.currentPageIndex,
    required this.scrollController,
    required this.highlightState,
    required this.audioCache,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final isChapterStart = currentPageIndex == 0 ||
        book.pages[currentPageIndex - 1].chapterNumber != page.chapterNumber;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    const Divider(height: 24),
                    if (isChapterStart) _buildChapterTitle(),
                    ..._buildImages(),
                    _buildPageContent(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildPageProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            page.chapterTitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.brown[600],
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            if (audioCache.containsKey(page.pageNumber - 1))
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.volume_up,
                  size: 14,
                  color: Colors.green[700],
                ),
              ),
            Text(
              'Page ${page.pageNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChapterTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                page.chapterTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontFamily: 'serif',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 100,
                color: Colors.brown[400],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildImages() {
    return page.elements
        .where((e) => e.type == ChapterElementType.image)
        .map((element) {
      if (element.imageData != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              element.imageData!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Image cannot be displayed',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  Widget _buildPageContent() {
    return HighlightedText(
      text: page.content,
      highlights: highlightState.wordHighlights,
      currentHighlightIndex: highlightState.currentWordIndex,
      style: const TextStyle(
        fontSize: 18,
        height: 1.8,
        color: Colors.black87,
        fontFamily: 'serif',
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.justify,
      onWordTap: (wordIndex) {
        if (wordIndex < highlightState.wordHighlights.length) {
          final localHighlight = highlightState.wordHighlights[wordIndex];
          final cachedResponse = audioCache[currentPageIndex];
          if (cachedResponse != null) {
            final globalIndex = cachedResponse.speechMarks.indexWhere(
              (mark) =>
                  mark.start - page.startCharIndex == localHighlight.start,
            );
            if (globalIndex != -1) {
              onWordTap(globalIndex);
            }
          }
        }
      },
      scrollController: scrollController,
    );
  }

  Widget _buildPageProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${page.pageNumber} / ${book.pages.length}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.brown[400],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LinearProgressIndicator(
            value: page.pageNumber / book.pages.length,
            backgroundColor: Colors.brown[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
          ),
        ),
      ],
    );
  }
}
