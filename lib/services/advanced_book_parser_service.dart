// lib/services/advanced_book_parser_service.dart

import 'package:flutter/foundation.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Progress callback for book parsing
typedef ParseProgressCallback = void Function(double progress, String status);

/// Top-level function for isolate - reads EPUB
Future<epubx.EpubBook?> _readEpubInIsolate(Uint8List fileBytes) async {
  try {
    return await epubx.EpubReader.readBook(fileBytes);
  } catch (e) {
    return null;
  }
}

class AdvancedBookParser {
  static const int maxWordsPerPage = 400;
  static final RegExp _imgTagDoubleQuote =
      RegExp(r'<img[^>]+src="([^"]+)"[^>]*>', caseSensitive: false);
  static final RegExp _imgTagSingleQuote =
      RegExp(r"<img[^>]+src='([^']+)'[^>]*>", caseSensitive: false);
  static final RegExp _paragraphRegex =
      RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);

  /// Parse book with optional progress callback
  /// Runs heavy parsing in background isolate to avoid blocking UI
  Future<ParsedBook?> parseBook(
    Uint8List fileBytes,
    String fileName, {
    ParseProgressCallback? onProgress,
  }) async {
    try {
      final extension = fileName.toLowerCase().split('.').last;

      onProgress?.call(0.1, 'Starting...');

      switch (extension) {
        case 'epub':
          return await _parseEpubAdvanced(fileBytes, fileName, onProgress);
        case 'pdf':
          return await _parsePdf(fileBytes, fileName, onProgress);
        case 'txt':
          return await _parseTxt(fileBytes, fileName, onProgress);
        default:
          debugPrint('Format nesuportat: $extension');
          return null;
      }
    } catch (e) {
      debugPrint('Eroare la parsarea cărții: $e');
      return null;
    }
  }

  /// Parser EPUB avansat: extrage capitole, imagini și paginează conținutul
  Future<ParsedBook?> _parseEpubAdvanced(
    Uint8List fileBytes,
    String fileName,
    ParseProgressCallback? onProgress,
  ) async {
    try {
      onProgress?.call(0.15, 'Reading EPUB...');

      // Use compute for heavy EPUB reading
      final epubBook = await compute(_readEpubInIsolate, fileBytes);
      if (epubBook == null) return null;

      final title = epubBook.Title ?? fileName.replaceAll('.epub', '');
      final author = epubBook.Author ?? 'Autor necunoscut';
      final chapters = <BookChapter>[];

      if (epubBook.Chapters != null && epubBook.Chapters!.isNotEmpty) {
        final totalChapters = epubBook.Chapters!.length;

        for (int i = 0; i < totalChapters; i++) {
          // Report progress
          final chapterProgress = 0.2 + (0.5 * (i / totalChapters));
          onProgress?.call(
              chapterProgress, 'Processing chapter ${i + 1}/$totalChapters...');

          // Yield to UI between chapters
          await Future.delayed(Duration.zero);

          final epubChapter = epubBook.Chapters![i];
          final chapter = await _parseChapter(epubChapter, i + 1, epubBook);

          if (chapter != null && chapter.elements.isNotEmpty) {
            chapters.add(chapter);
          }

          if (epubChapter.SubChapters != null) {
            for (int j = 0; j < epubChapter.SubChapters!.length; j++) {
              final subChapter = await _parseChapter(
                epubChapter.SubChapters![j],
                i + 1,
                epubBook,
                isSubChapter: true,
              );

              if (subChapter != null && subChapter.elements.isNotEmpty) {
                chapters.add(subChapter);
              }
            }
          }
        }
      }

      if (chapters.isEmpty) {
        debugPrint('Nu s-au găsit capitole în EPUB');
        return null;
      }

      onProgress?.call(0.8, 'Creating pages...');

      // Yield before heavy page creation
      await Future.delayed(Duration.zero);

      final pages = _createPagesFromChapters(chapters);

      onProgress?.call(1.0, 'Done!');

      return ParsedBook(
        title: title,
        author: author,
        chapters: chapters,
        pages: pages,
        format: BookFormat.epub,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea EPUB avansată: $e');
      return null;
    }
  }

  /// Parses individual EPUB chapter
  Future<BookChapter?> _parseChapter(
    epubx.EpubChapter epubChapter,
    int chapterNumber,
    epubx.EpubBook epubBook, {
    bool isSubChapter = false,
  }) async {
    try {
      final chapterTitle = epubChapter.Title ?? 'Capitol $chapterNumber';
      final htmlContent = epubChapter.HtmlContent ?? '';

      if (htmlContent.isEmpty) return null;

      final elements = _parseHtmlToElements(htmlContent, epubBook);

      if (elements.isEmpty) return null;

      return BookChapter(
        number: chapterNumber,
        title: chapterTitle,
        elements: elements,
        isSubChapter: isSubChapter,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea capitolului: $e');
      return null;
    }
  }

  /// Parses HTML and preserves structure
  List<ChapterElement> _parseHtmlToElements(
      String html, epubx.EpubBook epubBook) {
    final elements = <ChapterElement>[];

    // Extragem TOATE imaginile din HTML
    final allImgMatchesDouble = _imgTagDoubleQuote.allMatches(html);
    final allImgMatchesSingle = _imgTagSingleQuote.allMatches(html);
    final allImgMatches = [...allImgMatchesDouble, ...allImgMatchesSingle];

    for (final imgMatch in allImgMatches) {
      final imgSrc = imgMatch.group(1) ?? '';
      final imageBytes = _extractImageFromEpub(imgSrc, epubBook);

      if (imageBytes != null) {
        elements.add(ChapterElement.image(
          imageData: imageBytes,
          altText: 'Imagine',
        ));
      }
    }

    // Regex pentru paragrafe <p>...</p>
    final pMatches = _paragraphRegex.allMatches(html);

    for (final match in pMatches) {
      final paragraphHtml = match.group(1) ?? '';
      final textSpans = _parseInlineFormatting(paragraphHtml);

      if (textSpans.isNotEmpty) {
        elements.add(ChapterElement.paragraph(spans: textSpans));
      }
    }

    if (elements.where((e) => e.type == ChapterElementType.paragraph).isEmpty) {
      final cleanText = _stripHtmlTags(html).trim();
      if (cleanText.isNotEmpty) {
        elements.add(ChapterElement.paragraph(
          spans: [TextSpanData(text: cleanText)],
        ));
      }
    }

    return elements;
  }

  List<TextSpanData> _parseInlineFormatting(String html) {
    final spans = <TextSpanData>[];

    // Simplificat: extragem doar textul curat

    final cleanText = _stripHtmlTags(html).trim();

    if (cleanText.isNotEmpty) {
      spans.add(TextSpanData(text: cleanText));
    }

    return spans;
  }

  /// Extrage imagini din EPUB
  Uint8List? _extractImageFromEpub(String imgSrc, epubx.EpubBook epubBook) {
    try {
      String cleanSrc =
          imgSrc.replaceAll('../', '').replaceAll('./', '').trim();

      if (epubBook.Content?.Images != null) {
        for (final image in epubBook.Content!.Images!.values) {
          final fileName = image.FileName ?? '';

          // Strategy 1: Match exact
          if (fileName == cleanSrc) {
            if (image.Content != null) {
              return Uint8List.fromList(image.Content!);
            }
          }

          // Strategy 2: Ends with
          if (fileName.endsWith(cleanSrc)) {
            if (image.Content != null) {
              return Uint8List.fromList(image.Content!);
            }
          }

          // Strategy 3: Contains filename
          final srcFileName = cleanSrc.split('/').last;
          if (fileName.contains(srcFileName)) {
            if (image.Content != null) {
              return Uint8List.fromList(image.Content!);
            }
          }
        }
      }

      // Doar log pentru erori
      debugPrint('⚠️ Imagine nu găsită: $cleanSrc');
      return null;
    } catch (e) {
      debugPrint('❌ Eroare la extragerea imaginii: $e');
      return null;
    }
  }

  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<BookPage> _createPagesFromChapters(List<BookChapter> chapters) {
    final pages = <BookPage>[];
    int pageNumber = 1;
    int globalCharIndex = 0;

    for (final chapter in chapters) {
      final currentPageBuffer = StringBuffer();
      int currentWordCount = 0;
      int pageStartCharIndex = globalCharIndex;
      final List<ChapterElement> currentPageElements = [];

      void commitPage() {
        final content = currentPageBuffer.toString().trim();
        if (content.isEmpty) {
          return;
        }
        pages.add(
          BookPage(
            pageNumber: pageNumber,
            content: content,
            startCharIndex: pageStartCharIndex,
            endCharIndex: globalCharIndex,
            chapterNumber: chapter.number,
            chapterTitle: chapter.title,
            elements: List<ChapterElement>.from(currentPageElements),
          ),
        );
        pageNumber++;
        pageStartCharIndex = globalCharIndex;
        currentPageBuffer.clear();
        currentWordCount = 0;
        currentPageElements.clear();
      }

      for (final element in chapter.elements) {
        if (element.type == ChapterElementType.paragraph) {
          final paragraphText = element.spans.map((s) => s.text).join();
          final paragraphWords = paragraphText
              .split(RegExp(r'\s+'))
              .where((w) => w.isNotEmpty)
              .length;

          if (currentWordCount + paragraphWords > maxWordsPerPage &&
              currentPageBuffer.length > 0) {
            commitPage();
          }

          currentPageBuffer
            ..write(paragraphText)
            ..write('\n\n');
          currentWordCount += paragraphWords;
          currentPageElements.add(element);
          globalCharIndex += paragraphText.length + 2;
        } else if (element.type == ChapterElementType.image) {
          currentPageElements.add(element);
        }
      }

      if (currentPageBuffer.length > 0) {
        commitPage();
      }
    }

    return pages;
  }

  /// Parser PDF (similar cu cel vechi)
  Future<ParsedBook?> _parsePdf(
    Uint8List fileBytes,
    String fileName,
    ParseProgressCallback? onProgress,
  ) async {
    try {
      onProgress?.call(0.2, 'Reading PDF...');

      final PdfDocument document = PdfDocument(inputBytes: fileBytes);
      final pages = <BookPage>[];
      int globalCharIndex = 0;

      final allElements = <ChapterElement>[];
      final totalPdfPages = document.pages.count;

      for (int i = 0; i < totalPdfPages; i++) {
        // Report progress
        final pageProgress = 0.2 + (0.7 * (i / totalPdfPages));
        onProgress?.call(
            pageProgress, 'Processing page ${i + 1}/$totalPdfPages...');

        // Yield to UI between pages
        await Future.delayed(Duration.zero);

        final String pageText = PdfTextExtractor(document).extractText(
          startPageIndex: i,
          endPageIndex: i,
        );

        // Clean text slightly but keep structure
        final cleanPageText = pageText.trim();

        final pageElements = [
          ChapterElement.paragraph(spans: [TextSpanData(text: cleanPageText)])
        ];
        allElements.addAll(pageElements);

        pages.add(BookPage(
          pageNumber: i + 1,
          content: cleanPageText,
          startCharIndex: globalCharIndex,
          endCharIndex: globalCharIndex + cleanPageText.length,
          chapterNumber: 1,
          chapterTitle: fileName.replaceAll('.pdf', ''),
          elements: pageElements,
        ));

        globalCharIndex += cleanPageText.length + 2; // +2 for newline/spacing
      }

      document.dispose();

      onProgress?.call(1.0, 'Done!');

      final chapter = BookChapter(
        number: 1,
        title: fileName.replaceAll('.pdf', ''),
        elements: allElements,
      );

      return ParsedBook(
        title: fileName.replaceAll('.pdf', ''),
        author: 'Autor necunoscut',
        chapters: [chapter],
        pages: pages,
        format: BookFormat.pdf,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea PDF: $e');
      return null;
    }
  }

  /// Parser TXT (similar cu cel vechi)
  Future<ParsedBook?> _parseTxt(
    Uint8List fileBytes,
    String fileName,
    ParseProgressCallback? onProgress,
  ) async {
    try {
      onProgress?.call(0.3, 'Reading text file...');

      final text = String.fromCharCodes(fileBytes);

      onProgress?.call(0.6, 'Creating pages...');

      final chapter = BookChapter(
        number: 1,
        title: fileName.replaceAll('.txt', ''),
        elements: [
          ChapterElement.paragraph(
            spans: [TextSpanData(text: text)],
          )
        ],
      );

      final pages = _createPagesFromChapters([chapter]);

      onProgress?.call(1.0, 'Done!');

      return ParsedBook(
        title: fileName.replaceAll('.txt', ''),
        author: 'Autor necunoscut',
        chapters: [chapter],
        pages: pages,
        format: BookFormat.txt,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea TXT: $e');
      return null;
    }
  }
}

// ========== MODELE NOI ==========

class ParsedBook {
  final String title;
  final String author;
  final List<BookChapter> chapters;
  final List<BookPage> pages;
  final BookFormat format;

  ParsedBook({
    required this.title,
    required this.author,
    required this.chapters,
    required this.pages,
    required this.format,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'pages': pages.map((p) => p.toJson()).toList(),
        'format': format.name,
      };

  factory ParsedBook.fromJson(Map<String, dynamic> json) => ParsedBook(
        title: json['title'] as String,
        author: json['author'] as String,
        chapters: (json['chapters'] as List)
            .map((c) => BookChapter.fromJson(c as Map<String, dynamic>))
            .toList(),
        pages: (json['pages'] as List)
            .map((p) => BookPage.fromJson(p as Map<String, dynamic>))
            .toList(),
        format: BookFormat.values.firstWhere(
          (f) => f.name == json['format'],
          orElse: () => BookFormat.epub,
        ),
      );
}

class BookChapter {
  final int number;
  final String title;
  final List<ChapterElement> elements;
  final bool isSubChapter;

  BookChapter({
    required this.number,
    required this.title,
    required this.elements,
    this.isSubChapter = false,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'elements': elements.map((e) => e.toJson()).toList(),
        'isSubChapter': isSubChapter,
      };

  factory BookChapter.fromJson(Map<String, dynamic> json) => BookChapter(
        number: json['number'] as int,
        title: json['title'] as String,
        elements: (json['elements'] as List)
            .map((e) => ChapterElement.fromJson(e as Map<String, dynamic>))
            .toList(),
        isSubChapter: json['isSubChapter'] as bool? ?? false,
      );
}

enum ChapterElementType { paragraph, image, heading }

class ChapterElement {
  final ChapterElementType type;
  final List<TextSpanData> spans;
  final Uint8List? imageData;
  final String? altText;

  ChapterElement._({
    required this.type,
    this.spans = const [],
    this.imageData,
    this.altText,
  });

  factory ChapterElement.paragraph({required List<TextSpanData> spans}) {
    return ChapterElement._(
      type: ChapterElementType.paragraph,
      spans: spans,
    );
  }

  factory ChapterElement.image(
      {required Uint8List imageData, String? altText}) {
    return ChapterElement._(
      type: ChapterElementType.image,
      imageData: imageData,
      altText: altText,
    );
  }

  factory ChapterElement.heading({required String text}) {
    return ChapterElement._(
      type: ChapterElementType.heading,
      spans: [TextSpanData(text: text, isBold: true)],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'spans': spans.map((s) => s.toJson()).toList(),
        'imageData': imageData?.toList(),
        'altText': altText,
      };

  factory ChapterElement.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = ChapterElementType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => ChapterElementType.paragraph,
    );
    return ChapterElement._(
      type: type,
      spans: (json['spans'] as List? ?? [])
          .map((s) => TextSpanData.fromJson(s as Map<String, dynamic>))
          .toList(),
      imageData: json['imageData'] != null
          ? Uint8List.fromList(List<int>.from(json['imageData']))
          : null,
      altText: json['altText'] as String?,
    );
  }
}

class TextSpanData {
  final String text;
  final bool isBold;
  final bool isItalic;

  TextSpanData({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isBold': isBold,
        'isItalic': isItalic,
      };

  factory TextSpanData.fromJson(Map<String, dynamic> json) => TextSpanData(
        text: json['text'] as String,
        isBold: json['isBold'] as bool? ?? false,
        isItalic: json['isItalic'] as bool? ?? false,
      );
}

class BookPage {
  final int pageNumber;
  final String content;
  final int startCharIndex;
  final int endCharIndex;
  final int chapterNumber;
  final String chapterTitle;
  final List<ChapterElement> elements;

  BookPage({
    required this.pageNumber,
    required this.content,
    required this.startCharIndex,
    required this.endCharIndex,
    required this.chapterNumber,
    required this.chapterTitle,
    this.elements = const [],
  });

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'content': content,
        'startCharIndex': startCharIndex,
        'endCharIndex': endCharIndex,
        'chapterNumber': chapterNumber,
        'chapterTitle': chapterTitle,
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory BookPage.fromJson(Map<String, dynamic> json) => BookPage(
        pageNumber: json['pageNumber'] as int,
        content: json['content'] as String,
        startCharIndex: json['startCharIndex'] as int,
        endCharIndex: json['endCharIndex'] as int,
        chapterNumber: json['chapterNumber'] as int,
        chapterTitle: json['chapterTitle'] as String,
        elements: (json['elements'] as List? ?? [])
            .map((e) => ChapterElement.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum BookFormat { pdf, epub, txt }
