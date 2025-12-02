// lib/widgets/chapter_drawer_widget.dart

import 'package:flutter/material.dart';
import '../services/advanced_book_parser_service.dart';

/// Widget pentru afișarea Table of Contents într-un Drawer.
/// 
/// Afișează:
/// - Lista capitolelor din carte
/// - Highlight pentru capitolul curent
/// - Navigare rapidă la orice capitol
class ChapterDrawerWidget extends StatelessWidget {
  final ParsedBook book;
  final int currentPageIndex;
  final Function(int pageIndex) onChapterTap;

  const ChapterDrawerWidget({
    super.key,
    required this.book,
    required this.currentPageIndex,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFFFFDF7),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildChapterList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF8B4513),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.menu_book,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Table of Contents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return ListView.builder(
      itemCount: book.chapters.length,
      itemBuilder: (context, index) {
        final chapter = book.chapters[index];
        final pageIndex = book.pages.indexWhere(
          (page) => page.chapterNumber == chapter.number,
        );
        final isCurrentChapter = pageIndex != -1 &&
            currentPageIndex >= pageIndex &&
            (currentPageIndex < book.pages.length - 1 &&
                book.pages[currentPageIndex].chapterNumber == chapter.number);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isCurrentChapter
                ? const Color(0xFF8B4513)
                : Colors.brown[100],
            foregroundColor: isCurrentChapter ? Colors.white : Colors.brown[700],
            child: Text(
              '${chapter.number}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            chapter.title,
            style: TextStyle(
              fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
              color: isCurrentChapter ? const Color(0xFF8B4513) : Colors.black87,
            ),
          ),
          subtitle: Text(
            chapter.isSubChapter ? 'Subchapter' : 'Chapter',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          onTap: () {
            if (pageIndex != -1) {
              onChapterTap(pageIndex);
            }
          },
        );
      },
    );
  }
}
