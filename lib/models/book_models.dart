// lib/models/book_models.dart

class Book {
  final String title;
  final String author;
  final List<BookPage> pages;
  final BookFormat format;

  Book({
    required this.title,
    required this.author,
    required this.pages,
    required this.format,
  });

  String get fullText => pages.map((p) => p.content).join('\n\n');
}

class BookPage {
  final int pageNumber;
  final String content;
  final int startCharIndex; // Index in complete text
  final int endCharIndex;

  BookPage({
    required this.pageNumber,
    required this.content,
    required this.startCharIndex,
    required this.endCharIndex,
  });
}

enum BookFormat { pdf, epub, txt }

class ReadingProgress {
  final int currentPage;
  final int totalPages;
  final double progressPercentage;

  ReadingProgress({required this.currentPage, required this.totalPages})
    : progressPercentage = (currentPage / totalPages) * 100;
}
