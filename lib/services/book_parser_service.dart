// lib/services/book_parser_service.dart

import 'package:flutter/foundation.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/book_models.dart';

class BookParserService {
  // LIMITĂ STRICTĂ: Max 2500 caractere per pagină
  // Garantează că nu depășim niciodată limita AWS Polly (3000)
  static const int charsPerPage = 2500;

  Future<Book?> parseBook(Uint8List fileBytes, String fileName) async {
    try {
      final extension = fileName.toLowerCase().split('.').last;

      switch (extension) {
        case 'epub':
          return await _parseEpub(fileBytes, fileName);
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

  Future<Book?> _parseEpub(Uint8List fileBytes, String fileName) async {
    try {
      // Parsăm fișierul EPUB
      final epubBook = await epubx.EpubReader.readBook(fileBytes);

      // Extragem titlul și autorul
      final title = epubBook.Title ?? fileName.replaceAll('.epub', '');
      final author = epubBook.Author ?? 'Autor necunoscut';

      // Extragem tot textul din capitole
      String fullText = '';

      // Încercăm să extragem din capitole
      if (epubBook.Chapters != null && epubBook.Chapters!.isNotEmpty) {
        final chapters = epubBook.Chapters!;
        for (var chapter in chapters) {
          final chapterText = _extractTextFromHtml(chapter.HtmlContent ?? '');
          if (chapterText.isNotEmpty) {
            fullText += '$chapterText\n\n';
          }

          // Procesăm și subcapitolele
          if (chapter.SubChapters != null) {
            for (var subChapter in chapter.SubChapters!) {
              final subText =
                  _extractTextFromHtml(subChapter.HtmlContent ?? '');
              if (subText.isNotEmpty) {
                fullText += '$subText\n\n';
              }
            }
          }
        }
      }

      // Dacă nu am găsit text în capitole, încercăm din Content
      if (fullText.isEmpty && epubBook.Content != null) {
        final content = epubBook.Content!;
        if (content.Html != null) {
          for (var htmlFile in content.Html!.values) {
            final htmlContent = htmlFile.Content ?? '';
            final text = _extractTextFromHtml(htmlContent);
            if (text.isNotEmpty) {
              fullText += '$text\n\n';
            }
          }
        }
      }

      // Dacă tot nu avem text, returnăm eroare
      if (fullText.trim().isEmpty) {
        debugPrint('EPUB nu conține text extractabil');
        return null;
      }

      // Creăm paginile
      final pages = _createPages(fullText);

      return Book(
        title: title,
        author: author,
        pages: pages,
        format: BookFormat.epub,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea EPUB: $e');
      // Nu aruncăm eroarea, doar returnăm null
      return null;
    }
  }

  Future<Book?> _parsePdf(Uint8List fileBytes, String fileName) async {
    try {
      // Încărcăm documentul PDF
      final PdfDocument document = PdfDocument(inputBytes: fileBytes);

      String fullText = '';

      // Extragem textul din fiecare pagină
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = PdfTextExtractor(document).extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        fullText += '$pageText\n\n';
      }

      document.dispose();

      // Creăm paginile
      final pages = _createPages(fullText);

      return Book(
        title: fileName.replaceAll('.pdf', ''),
        author: 'Autor necunoscut',
        pages: pages,
        format: BookFormat.pdf,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea PDF: $e');
      return null;
    }
  }

  Future<Book?> _parseTxt(Uint8List fileBytes, String fileName) async {
    try {
      final text = String.fromCharCodes(fileBytes);
      final pages = _createPages(text);

      return Book(
        title: fileName.replaceAll('.txt', ''),
        author: 'Autor necunoscut',
        pages: pages,
        format: BookFormat.txt,
      );
    } catch (e) {
      debugPrint('Eroare la parsarea TXT: $e');
      return null;
    }
  }

  // Extrage text din HTML (pentru EPUB)
  String _extractTextFromHtml(String html) {
    // Elimină tag-urile HTML
    String text = html.replaceAll(RegExp(r'<[^>]*>'), ' ');

    // Decodează entitățile HTML
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // Curăță spațiile multiple
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  // Creează pagini din text
  List<BookPage> _createPages(String fullText) {
    if (fullText.isEmpty) return [];

    final List<BookPage> pages = [];
    int pageNumber = 1;

    // Împărțim textul în paragrafe
    final paragraphs =
        fullText.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    String currentPageContent = '';
    int pageStartIndex = 0;

    for (var paragraph in paragraphs) {
      // Dacă adăugarea paragrafului ar depăși limita de caractere
      if (currentPageContent.length + paragraph.length > charsPerPage &&
          currentPageContent.isNotEmpty) {
        // Salvăm pagina curentă
        pages.add(BookPage(
          pageNumber: pageNumber,
          content: currentPageContent.trim(),
          startCharIndex: pageStartIndex,
          endCharIndex: pageStartIndex + currentPageContent.length,
        ));

        // Începem o pagină nouă
        pageNumber++;
        pageStartIndex += currentPageContent.length;
        currentPageContent = '$paragraph\n\n';
      } else {
        currentPageContent += '$paragraph\n\n';
      }
    }

    // Adăugăm ultima pagină
    if (currentPageContent.isNotEmpty) {
      pages.add(BookPage(
        pageNumber: pageNumber,
        content: currentPageContent.trim(),
        startCharIndex: pageStartIndex,
        endCharIndex: pageStartIndex + currentPageContent.length,
      ));
    }

    return pages;
  }

  // Helper pentru a găsi pagina care conține un anumit caracter
  int findPageForCharIndex(List<BookPage> pages, int charIndex) {
    for (int i = 0; i < pages.length; i++) {
      if (charIndex >= pages[i].startCharIndex &&
          charIndex < pages[i].endCharIndex) {
        return i;
      }
    }
    return 0;
  }
}
