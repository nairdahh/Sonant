// lib/screens/book_reader_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Pentru TapGestureRecognizer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../models/book_models.dart';
import '../models/polly_response.dart';
import '../services/book_parser_service.dart';
import '../services/polly_service.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final BookParserService _bookParser = BookParserService();
  final PollyService _pollyService = PollyService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PageController _pageController = PageController();

  Book? _currentBook;
  int _currentPageIndex = 0;
  bool _isLoading = false;
  bool _isLoadingAudio = false;
  double _audioLoadProgress = 0.0;
  String _selectedVoice = 'Joanna';

  // Cache pentru audio generat per pagină
  Map<int, PollyResponse> _audioCache = {};

  List<SpeechMark> _speechMarks = [];
  int _currentWordIndex = -1;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_speechMarks.isEmpty) return;

      final currentMillis = position.inMilliseconds;
      final lastMarkIndex = _speechMarks.lastIndexWhere(
        (mark) => mark.time <= currentMillis && mark.type == 'word',
      );

      if (lastMarkIndex != _currentWordIndex && mounted) {
        setState(() {
          _currentWordIndex = lastMarkIndex;
        });
      }
    });

    // 🎯 Listener pentru auto-avans și citire continuă
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Verificăm că audio-ul chiar s-a terminat complet
        if (_audioPlayer.position >= (_audioPlayer.duration ?? Duration.zero)) {
          debugPrint(
              '✅ Audio terminat complet, trecem la următoarea pagină...');

          if (mounted) {
            // Verificăm dacă mai există pagini următoare
            if (_currentPageIndex < (_currentBook?.pages.length ?? 0) - 1) {
              // Trecem la următoarea pagină
              _currentPageIndex++;
              _pageController.animateToPage(
                _currentPageIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );

              // 🔥 Continuăm citirea automat + generăm următoarele 2
              Future.delayed(const Duration(milliseconds: 500), () async {
                if (mounted) {
                  // Redăm pagina curentă (ar trebui să fie în cache)
                  if (_audioCache.containsKey(_currentPageIndex)) {
                    debugPrint(
                        '⚡ Redăm automat pagina $_currentPageIndex din cache');
                    final cachedResponse = _audioCache[_currentPageIndex]!;
                    setState(() {
                      _speechMarks = cachedResponse.speechMarks;
                      _currentWordIndex = -1;
                    });
                    await _audioPlayer.setUrl(cachedResponse.audioUrl!);
                    _audioPlayer.play();

                    // 🎵 Generăm în fundal următoarele 2 pagini
                    _preloadNext2Pages();
                  } else {
                    debugPrint(
                        '⚠️ Pagina $_currentPageIndex nu e în cache, generăm acum...');
                    await _playCurrentPage();
                  }
                }
              });
            } else {
              debugPrint('📖 Ultima pagină - citire completă!');
              if (mounted) {
                setState(() {
                  _currentWordIndex = -1;
                });
              }
            }
          }
        }
      }
    });
  }

  // 🎵 Generează următoarele 2 pagini în fundal (doar cele noi)
  void _preloadNext2Pages() {
    if (_currentBook == null) return;

    final pagesToPreload = <int>[];

    // Următoarele 2 pagini
    for (int i = 1; i <= 2; i++) {
      final pageIdx = _currentPageIndex + i;
      if (pageIdx < _currentBook!.pages.length &&
          !_audioCache.containsKey(pageIdx)) {
        pagesToPreload.add(pageIdx);
      }
    }

    if (pagesToPreload.isEmpty) {
      debugPrint('⚡ Următoarele 2 pagini deja în cache');
      return;
    }

    debugPrint('🎵 [FUNDAL] Începem generarea: $pagesToPreload');

    // ✅ Generăm async în fundal fără await - NU blochează audio-ul!
    Future.microtask(() async {
      for (final pageIdx in pagesToPreload) {
        debugPrint('🎵 [FUNDAL] Generăm pagina ${pageIdx + 1}...');
        await _preloadPageAudio(pageIdx);
        debugPrint('✅ [FUNDAL] Pagina ${pageIdx + 1} gata!');
      }
      debugPrint('✅ [FUNDAL] Toate paginile generate!');
    });
  }

  Future<void> _pickBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'txt'],
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() => _isLoading = true);

      final book = await _bookParser.parseBook(
        result.files.first.bytes!,
        result.files.first.name,
      );

      if (mounted) {
        setState(() {
          _currentBook = book;
          _currentPageIndex = 0;
          _isLoading = false;
          _speechMarks = [];
          _currentWordIndex = -1;
          _audioCache = {};
          _audioPlayer.stop();
        });

        if (book != null) {
          _pageController.jumpToPage(0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Carte încărcată: ${book.title}\n${book.pages.length} pagini'),
              duration: const Duration(seconds: 2),
            ),
          );
          // ❌ NU mai pregenerăm automat
        }
      }
    }
  }

  Future<void> _preloadPageAudio(int pageIndex) async {
    if (_currentBook == null || pageIndex >= _currentBook!.pages.length) {
      return;
    }

    if (_audioCache.containsKey(pageIndex)) {
      debugPrint('⚡ Pagina ${pageIndex + 1} deja în cache, skip');
      return;
    }

    debugPrint('🎵 START generare pagina ${pageIndex + 1}...');

    try {
      final page = _currentBook!.pages[pageIndex];

      // Verificăm dacă pagina e prea lungă
      if (page.content.length > 2900) {
        debugPrint(
            '⚠️ Pagina ${pageIndex + 1} prea lungă (${page.content.length} char), va fi trunChiată');
      }

      final pollyResponse = await _pollyService.synthesizeSpeech(
        page.content,
        voiceId: _selectedVoice,
      );

      if (pollyResponse != null && pollyResponse.audioUrl != null) {
        final adjustedMarks = pollyResponse.speechMarks.map((mark) {
          return SpeechMark(
            time: mark.time,
            type: mark.type,
            start: mark.start + page.startCharIndex,
            end: mark.end + page.startCharIndex,
            value: mark.value,
          );
        }).toList();

        _audioCache[pageIndex] = PollyResponse(
          audioUrl: pollyResponse.audioUrl,
          speechMarks: adjustedMarks,
        );

        debugPrint('✅ DONE pagina ${pageIndex + 1} → Cache');
      }
    } catch (e) {
      debugPrint('❌ EROARE pagina ${pageIndex + 1}: $e');
    }
  }

  Future<void> _playCurrentPage() async {
    if (_currentBook == null ||
        _currentPageIndex >= _currentBook!.pages.length) {
      return;
    }

    // Verificăm dacă avem deja audio în cache pentru pagina curentă
    if (_audioCache.containsKey(_currentPageIndex)) {
      debugPrint('⚡ Folosim audio din cache pentru pagina $_currentPageIndex');

      final cachedResponse = _audioCache[_currentPageIndex]!;

      setState(() {
        _speechMarks = cachedResponse.speechMarks;
        _currentWordIndex = -1;
      });

      await _audioPlayer.setUrl(cachedResponse.audioUrl!);
      _audioPlayer.play();

      // 🎵 Generăm în fundal următoarele 2 pagini
      _preloadNext2Pages();
      return;
    }

    // Generăm pagina curentă + următoarele 2 (total 3 pagini)
    setState(() {
      _isLoadingAudio = true;
      _audioLoadProgress = 0.0;
    });

    debugPrint('🎵 Generăm audio pentru pagina curentă + următoarele 2...');

    try {
      // Pregătim paginile de generat (curentă + max 2 următoare)
      final pagesToGenerate = <int>[];
      for (int i = 0; i < 3; i++) {
        final pageIdx = _currentPageIndex + i;
        if (pageIdx < _currentBook!.pages.length &&
            !_audioCache.containsKey(pageIdx)) {
          pagesToGenerate.add(pageIdx);
        }
      }

      debugPrint(
          '📄 Vom genera ${pagesToGenerate.length} pagini: $pagesToGenerate');

      // Generăm fiecare pagină
      for (int i = 0; i < pagesToGenerate.length; i++) {
        final pageIdx = pagesToGenerate[i];

        if (mounted) {
          setState(() => _audioLoadProgress = (i + 1) / pagesToGenerate.length);
        }

        await _preloadPageAudio(pageIdx);
      }

      // După generare, pornim audio-ul pentru pagina curentă
      if (_audioCache.containsKey(_currentPageIndex) && mounted) {
        final cachedResponse = _audioCache[_currentPageIndex]!;

        setState(() {
          _speechMarks = cachedResponse.speechMarks;
          _currentWordIndex = -1;
        });

        await _audioPlayer.setUrl(cachedResponse.audioUrl!);
        _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('❌ Eroare la redarea paginii: $e');
    }

    if (mounted) {
      setState(() => _isLoadingAudio = false);
    }
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() {
      _currentWordIndex = -1;
      _speechMarks = [];
    });
  }

  void _preloadNextPage(int currentPageIndex) {
    // ❌ Nu mai facem pregenerare automată la schimbarea paginii
    // Generarea se face DOAR când user apasă Play
    return;
  }

  // 🎯 Funcție pentru a începe redarea de la un cuvânt specific
  void _playFromWord(int markIndex) async {
    if (_speechMarks.isEmpty ||
        markIndex < 0 ||
        markIndex >= _speechMarks.length) {
      return;
    }

    final mark = _speechMarks[markIndex];
    final timeToSeek = mark.time;

    debugPrint(
        '🎯 Click pe cuvânt: "${mark.value}" - Sărim la ${timeToSeek}ms');

    // Dacă audio-ul nu e încărcat, îl încărcăm
    if (_audioPlayer.duration == null &&
        _audioCache.containsKey(_currentPageIndex)) {
      final cachedResponse = _audioCache[_currentPageIndex]!;
      await _audioPlayer.setUrl(cachedResponse.audioUrl!);
    }

    // Sărim la timpul corespunzător
    await _audioPlayer.seek(Duration(milliseconds: timeToSeek));

    // Pornim redarea
    _audioPlayer.play();

    // Actualizăm highlight-ul
    setState(() {
      _currentWordIndex = markIndex;
    });
  }

  List<TextSpan> _buildTextSpans(String content, int pageStartIndex) {
    // Dacă nu avem speech marks, returnăm textul simplu
    if (content.isEmpty || _speechMarks.isEmpty) {
      return [TextSpan(text: content)];
    }

    List<TextSpan> spans = [];
    int textPointer = 0;

    final pageEndIndex = pageStartIndex + content.length;

    // Filtrăm speech marks pentru această pagină
    final pageMarks = _speechMarks
        .where(
            (mark) => mark.start >= pageStartIndex && mark.start < pageEndIndex)
        .toList();

    // Sortăm marks după poziție pentru a procesa corect
    pageMarks.sort((a, b) => a.start.compareTo(b.start));

    for (int i = 0; i < pageMarks.length; i++) {
      final mark = pageMarks[i];
      if (mark.type != 'word') continue;

      final localStart = mark.start - pageStartIndex;
      final localEnd = mark.end - pageStartIndex;

      // Verificăm boundaries
      if (localStart < 0 ||
          localEnd > content.length ||
          localStart >= content.length) {
        continue;
      }

      // Text înainte de cuvânt
      if (localStart > textPointer) {
        spans.add(TextSpan(text: content.substring(textPointer, localStart)));
      }

      final markIndexInFull = _speechMarks.indexOf(mark);
      final isCurrentWord = markIndexInFull == _currentWordIndex;

      // Extragem cuvântul EXACT din conținutul original (nu din mark.value!)
      final actualWord = content.substring(localStart, localEnd);

      // Facem cuvântul clickable
      spans.add(
        TextSpan(
          text: actualWord, // ✅ Folosim textul original, nu mark.value
          style: TextStyle(
            backgroundColor: isCurrentWord
                ? Colors.yellow.withValues(alpha: 0.6)
                : Colors.transparent,
            fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.normal,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              debugPrint('👆 Click pe: "$actualWord"');
              _playFromWord(markIndexInFull);
            },
        ),
      );
      textPointer = localEnd;
    }

    // Text rămas după ultimul cuvânt
    if (textPointer < content.length) {
      spans.add(TextSpan(text: content.substring(textPointer)));
    }

    return spans;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: Text(_currentBook?.title ?? 'Sonant Reader'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          if (_currentBook != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showBookInfo(),
            ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _currentBook != null ? _buildControls() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _pickBook,
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.menu_book, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Se încarcă cartea...'),
          ],
        ),
      );
    }

    if (_currentBook == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 100, color: Colors.brown[300]),
            const SizedBox(height: 24),
            const Text(
              'Apasă pe butonul de jos pentru\na încărca o carte',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Formate suportate: EPUB, PDF, TXT',
              style: TextStyle(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _currentBook!.pages.length,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
        _preloadNextPage(index);
      },
      itemBuilder: (context, index) {
        final page = _currentBook!.pages[index];
        return _buildPage(page);
      },
    );
  }

  Widget _buildPage(BookPage page) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _currentBook!.title,
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
                            if (_audioCache.containsKey(page.pageNumber - 1))
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 14,
                                  color: Colors.green[700],
                                ),
                              ),
                            Text(
                              'Pagina ${page.pageNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.brown[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          color: Colors.black87,
                          fontFamily: 'serif',
                          letterSpacing: 0.3,
                        ),
                        children:
                            _buildTextSpans(page.content, page.startCharIndex),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${page.pageNumber} / ${_currentBook!.pages.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[400],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: page.pageNumber / _currentBook!.pages.length,
                    backgroundColor: Colors.brown[100],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoadingAudio)
            Column(
              children: [
                LinearProgressIndicator(value: _audioLoadProgress),
                const SizedBox(height: 8),
                Text(
                  'Se generează audio: ${(_audioLoadProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: _currentPageIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                tooltip: 'Pagina anterioară',
              ),
              IconButton(
                icon: const Icon(Icons.stop, size: 28),
                onPressed: () => _stopAudio(),
                tooltip: 'Stop',
              ),
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final isPlaying = playerState?.playing ?? false;
                  final processingState = playerState?.processingState;

                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return const CircularProgressIndicator();
                  }

                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 56,
                      color: const Color(0xFF8B4513),
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        if (_audioPlayer.duration == null) {
                          _playCurrentPage();
                        } else {
                          _audioPlayer.play();
                        }
                      }
                    },
                    tooltip: isPlaying ? 'Pauză' : 'Redare',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.library_books, size: 28),
                onPressed: _isLoadingAudio ? null : _playCurrentPage,
                tooltip: 'Citește pagina curentă',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 32),
                onPressed: _currentPageIndex < _currentBook!.pages.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                tooltip: 'Pagina următoare',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.record_voice_over,
                    size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedVoice,
                  underline: Container(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: const [
                    DropdownMenuItem(
                        value: 'Joanna', child: Text('Joanna (US) ♀')),
                    DropdownMenuItem(
                        value: 'Matthew', child: Text('Matthew (US) ♂')),
                    DropdownMenuItem(value: 'Ivy', child: Text('Ivy (US) ♀')),
                    DropdownMenuItem(value: 'Amy', child: Text('Amy (UK) ♀')),
                    DropdownMenuItem(
                        value: 'Brian', child: Text('Brian (UK) ♂')),
                    DropdownMenuItem(value: 'Emma', child: Text('Emma (UK) ♀')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedVoice = value;
                      });
                      if (_speechMarks.isNotEmpty) {
                        _stopAudio();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Voce schimbată la $value. Apasă Play pentru noua voce.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookInfo() {
    if (_currentBook == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_currentBook!.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Autor: ${_currentBook!.author}'),
            const SizedBox(height: 8),
            Text('Format: ${_currentBook!.format.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Total pagini: ${_currentBook!.pages.length}'),
            const SizedBox(height: 8),
            Text('Pagina curentă: ${_currentPageIndex + 1}'),
            const SizedBox(height: 8),
            Text(
              'Progres: ${((_currentPageIndex + 1) / _currentBook!.pages.length * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            Text('Audio în cache: ${_audioCache.length} pagini'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }
}
