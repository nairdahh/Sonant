// lib/services/advanced_book_parser_service.dart

import 'package:flutter/foundation.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AdvancedBookParser {
  static const int maxWordsPerPage = 400;

  Future<ParsedBook?> parseBook(Uint8List fileBytes, String fileName) async {
    try {
      final extension = fileName.toLowerCase().split('.').last;

      switch (extension) {
        case 'epub':
          return await _parseEpubAdvanced(fileBytes, fileName);
        case 'pdf':
          return await _parsePdf(fileBytes, fileName);
        case 'txt':
          return await _parseTxt(fileBytes, fileName);
        default:
          debugPrint('Format nesuportat: $extension');
          return null;
      }
    } catch (e) {
      debugPrint('Eroare la parsarea cărții: $e');
      return null;
    }
  }

  /// Parser EPUB AVANSAT - păstrează capitole, imagini, formatare
  Future<ParsedBook?> _parseEpubAdvanced(
      Uint8List fileBytes, String fileName) async {
    try {
      final epubBook = await epubx.EpubReader.readBook(fileBytes);

      final title = epubBook.Title ?? fileName.replaceAll('.epub', '');
      final author = epubBook.Author ?? 'Autor necunoscut';

      // 📚 Extragem CAPITOLE separate (nu text mare)
      final chapters = <BookChapter>[];

      if (epubBook.Chapters != null && epubBook.Chapters!.isNotEmpty) {
        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final epubChapter = epubBook.Chapters![i];
          final chapter = await _parseChapter(epubChapter, i + 1, epubBook);

          if (chapter != null && chapter.elements.isNotEmpty) {
            chapters.add(chapter);
          }

          // Procesăm și subcapitolele
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

      // 📄 Creăm pagini din capitole (max 400 cuvinte per pagină)
      final pages = _createPagesFromChapters(chapters);

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

  /// Parsează un capitol EPUB individual
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

      // 🎨 Parsăm HTML și păstrăm formatarea
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

  /// Parsează HTML și păstrează structura (paragrafe, imagini, bold, italic)
  List<ChapterElement> _parseHtmlToElements(
      String html, epubx.EpubBook epubBook) {
    final elements = <ChapterElement>[];

    // 🖼️ Prima dată, extragem TOATE imaginile din HTML (orice pozție)
    final imgRegexDouble =
        RegExp(r'<img[^>]+src="([^"]+)"[^>]*>', caseSensitive: false);
    final imgRegexSingle =
        RegExp(r"<img[^>]+src='([^']+)'[^>]*>", caseSensitive: false);

    final allImgMatchesDouble = imgRegexDouble.allMatches(html);
    final allImgMatchesSingle = imgRegexSingle.allMatches(html);
    final allImgMatches = [...allImgMatchesDouble, ...allImgMatchesSingle];

    debugPrint('🖼️ Găsite ${allImgMatches.length} tag-uri <img> în HTML');

    for (final imgMatch in allImgMatches) {
      final imgSrc = imgMatch.group(1) ?? '';
      debugPrint('🖼️ Procesăm img src: $imgSrc');

      final imageBytes = _extractImageFromEpub(imgSrc, epubBook);

      if (imageBytes != null) {
        debugPrint('✅ Imagine extrasă cu succes! ${imageBytes.length} bytes');
        elements.add(ChapterElement.image(
          imageData: imageBytes,
          altText: 'Imagine',
        ));
      } else {
        debugPrint('❌ Nu s-a putut extrage imaginea');
      }
    }

    // Regex pentru paragrafe <p>...</p>
    final pRegex = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);
    final pMatches = pRegex.allMatches(html);

    for (final match in pMatches) {
      final paragraphHtml = match.group(1) ?? '';

      // Extragem textul și păstrăm formatarea simplă
      final textSpans = _parseInlineFormatting(paragraphHtml);

      if (textSpans.isNotEmpty) {
        elements.add(ChapterElement.paragraph(spans: textSpans));
      }
    }

    // Dacă nu găsim paragrafe cu <p>, extragem direct textul
    if (elements.where((e) => e.type == ChapterElementType.paragraph).isEmpty) {
      final cleanText = _stripHtmlTags(html).trim();
      if (cleanText.isNotEmpty) {
        elements.add(ChapterElement.paragraph(
          spans: [TextSpanData(text: cleanText)],
        ));
      }
    }

    debugPrint('📄 Total elemente procesate: ${elements.length}');
    debugPrint(
        '   - Paragrafe: ${elements.where((e) => e.type == ChapterElementType.paragraph).length}');
    debugPrint(
        '   - Imagini: ${elements.where((e) => e.type == ChapterElementType.image).length}');

    return elements;
  }

  /// Parsează formatare inline (bold, italic, etc.)
  List<TextSpanData> _parseInlineFormatting(String html) {
    final spans = <TextSpanData>[];

    // Simplificat: extragem doar textul curat
    // Poți extinde pentru <b>, <i>, <em>, <strong>
    final cleanText = _stripHtmlTags(html).trim();

    if (cleanText.isNotEmpty) {
      spans.add(TextSpanData(text: cleanText));
    }

    return spans;
  }

  /// Extrage imagini din EPUB
  Uint8List? _extractImageFromEpub(String imgSrc, epubx.EpubBook epubBook) {
    try {
      debugPrint('🖼️ Căutăm imaginea: $imgSrc');

      // Curățăm path-ul
      String cleanSrc =
          imgSrc.replaceAll('../', '').replaceAll('./', '').trim();

      debugPrint('🖼️ Path curățat: $cleanSrc');

      // Căutăm în Images
      if (epubBook.Content?.Images != null) {
        debugPrint(
            '🖼️ Total imagini în EPUB: ${epubBook.Content!.Images!.length}');

        // Afișăm toate imaginile disponibile pentru debug
        for (final image in epubBook.Content!.Images!.values) {
          debugPrint('  - ${image.FileName}');
        }

        // Încercăm mai multe strategii de matching
        for (final image in epubBook.Content!.Images!.values) {
          final fileName = image.FileName ?? '';

          // Strategy 1: Match exact
          if (fileName == cleanSrc) {
            debugPrint('✅ Imagine găsită (exact match): $fileName');
            if (image.Content != null) {
              return Uint8List.fromList(image.Content!);
            }
          }

          // Strategy 2: Ends with
          if (fileName.endsWith(cleanSrc)) {
            debugPrint('✅ Imagine găsită (ends with): $fileName');
            if (image.Content != null) {
              return Uint8List.fromList(image.Content!);
            }
          }

          // Strategy 3: Contains filename
          final srcFileName = cleanSrc.split('/').last;
          if (fileName.contains(srcFileName)) {
            debugPrint('✅ Imagine găsită (contains): $fileName');
            if (image.Content != null) {
              return Uint8List.fromList(image.Content!);
            }
          }
        }
      } else {
        debugPrint('⚠️ EPUB nu are imagini în Content.Images');
      }

      debugPrint('❌ Imagine nu găsită: $cleanSrc');
      return null;
    } catch (e) {
      debugPrint('❌ Eroare la extragerea imaginii: $e');
      return null;
    }
  }

  /// Elimină tag-uri HTML
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

  /// Creează pagini din capitole (max 400 cuvinte per pagină)
  List<BookPage> _createPagesFromChapters(List<BookChapter> chapters) {
    final pages = <BookPage>[];
    int pageNumber = 1;
    int globalCharIndex = 0;

    for (final chapter in chapters) {
      // Marcăm începutul capitolului
      String currentPageContent = '';
      int currentWordCount = 0;
      int pageStartCharIndex = globalCharIndex;
      final List<ChapterElement> currentPageElements = [];

      // ✅ NU mai adăugăm header-ul aici, îl vom afișa în UI
      // Header-ul va fi afișat automat când isChapterStart = true

      for (final element in chapter.elements) {
        if (element.type == ChapterElementType.paragraph) {
          final paragraphText = element.spans.map((s) => s.text).join();
          final paragraphWords = paragraphText
              .split(RegExp(r'\s+'))
              .where((w) => w.isNotEmpty)
              .length;

          // Verificăm dacă depășim limita de 400 cuvinte
          if (currentWordCount + paragraphWords > maxWordsPerPage &&
              currentPageContent.isNotEmpty) {
            // Salvăm pagina curentă
            pages.add(BookPage(
              pageNumber: pageNumber,
              content: currentPageContent.trim(),
              startCharIndex: pageStartCharIndex,
              endCharIndex: globalCharIndex,
              chapterNumber: chapter.number,
              chapterTitle: chapter.title,
              elements: List.from(currentPageElements),
            ));

            // Începem pagina următoare
            pageNumber++;
            pageStartCharIndex = globalCharIndex;
            currentPageContent = '';
            currentWordCount = 0;
            currentPageElements.clear();
          }

          // Adăugăm paragraful
          currentPageContent += '$paragraphText\n\n';
          currentWordCount += paragraphWords;
          currentPageElements.add(element);
          globalCharIndex += paragraphText.length + 2;
        } else if (element.type == ChapterElementType.image) {
          // ✅ Adăugăm imaginea în elements, dar NU în currentPageContent
          // Imaginea va fi afișată separat în UI
          currentPageElements.add(element);
        }
      }

      // Salvăm ultima pagină a capitolului
      if (currentPageContent.trim().isNotEmpty) {
        pages.add(BookPage(
          pageNumber: pageNumber,
          content: currentPageContent.trim(),
          startCharIndex: pageStartCharIndex,
          endCharIndex: globalCharIndex,
          chapterNumber: chapter.number,
          chapterTitle: chapter.title,
          elements: List.from(currentPageElements),
        ));
        pageNumber++;
      }
    }

    return pages;
  }

  /// Parser PDF (similar cu cel vechi)
  Future<ParsedBook?> _parsePdf(Uint8List fileBytes, String fileName) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: fileBytes);
      String fullText = '';

      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = PdfTextExtractor(document).extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        fullText += '$pageText\n\n';
      }

      document.dispose();

      // Creăm un capitol generic pentru PDF
      final chapter = BookChapter(
        number: 1,
        title: fileName.replaceAll('.pdf', ''),
        elements: [
          ChapterElement.paragraph(
            spans: [TextSpanData(text: fullText)],
          )
        ],
      );

      final pages = _createPagesFromChapters([chapter]);

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
  Future<ParsedBook?> _parseTxt(Uint8List fileBytes, String fileName) async {
    try {
      final text = String.fromCharCodes(fileBytes);

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
}

enum BookFormat { pdf, epub, txt }
