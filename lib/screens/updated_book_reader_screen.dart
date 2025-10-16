// lib/screens/updated_book_reader_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../services/advanced_book_parser_service.dart';
import '../services/polly_service.dart';
import '../models/polly_response.dart';
import '../widgets/highlighted_text_widget.dart';

class UpdatedBookReaderScreen extends StatefulWidget {
  const UpdatedBookReaderScreen({super.key});

  @override
  State<UpdatedBookReaderScreen> createState() =>
      _UpdatedBookReaderScreenState();
}

class _UpdatedBookReaderScreenState extends State<UpdatedBookReaderScreen> {
  final AdvancedBookParser _bookParser = AdvancedBookParser();
  final PollyService _pollyService = PollyService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ParsedBook? _currentBook;
  int _currentPageIndex = 0;
  bool _isLoading = false;
  bool _isLoadingAudio = false;
  double _audioLoadProgress = 0.0;
  String _selectedVoice = 'Joanna';
  bool _isPlaying = false;

  Map<int, PollyResponse> _audioCache = {};
  List<SpeechMark> _speechMarks = [];
  List<WordHighlight> _wordHighlights = [];
  int _currentWordIndex = -1;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();

    // Track audio position pentru highlight
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

    // Auto-avans între pagini
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }

      if (state.processingState == ProcessingState.completed) {
        if (_audioPlayer.position >= (_audioPlayer.duration ?? Duration.zero)) {
          _handleAudioComplete();
        }
      }
    });
  }

  void _handleAudioComplete() {
    if (!mounted) return;

    debugPrint('✅ Audio terminat, trecem la următoarea pagină...');

    setState(() {
      _isPlaying = false;
    });

    if (_currentPageIndex < (_currentBook?.pages.length ?? 0) - 1) {
      _currentPageIndex++;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }

      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          if (_audioCache.containsKey(_currentPageIndex)) {
            await _playFromCache(_currentPageIndex);
          } else {
            await _playCurrentPage();
          }
        }
      });
    } else {
      debugPrint('📖 Ultima pagină - citire completă!');
      setState(() {
        _currentWordIndex = -1;
        _isPlaying = false;
      });
    }
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
          _wordHighlights = [];
          _currentWordIndex = -1;
          _audioCache = {};
          _audioPlayer.stop();
        });

        if (book != null) {
          _pageController.jumpToPage(0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Carte încărcată: ${book.title}\n'
                '${book.chapters.length} capitole, ${book.pages.length} pagini',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _playCurrentPage() async {
    if (_currentBook == null ||
        _currentPageIndex >= _currentBook!.pages.length) {
      return;
    }

    if (_audioCache.containsKey(_currentPageIndex)) {
      await _playFromCache(_currentPageIndex);
      _preloadNext2Pages();
      return;
    }

    setState(() {
      _isLoadingAudio = true;
      _audioLoadProgress = 0.0;
    });

    try {
      final pagesToGenerate = <int>[];
      for (int i = 0; i < 3; i++) {
        final pageIdx = _currentPageIndex + i;
        if (pageIdx < _currentBook!.pages.length &&
            !_audioCache.containsKey(pageIdx)) {
          pagesToGenerate.add(pageIdx);
        }
      }

      for (int i = 0; i < pagesToGenerate.length; i++) {
        final pageIdx = pagesToGenerate[i];
        if (mounted) {
          setState(() => _audioLoadProgress = (i + 1) / pagesToGenerate.length);
        }
        await _preloadPageAudio(pageIdx);
      }

      if (_audioCache.containsKey(_currentPageIndex) && mounted) {
        await _playFromCache(_currentPageIndex);
      }
    } catch (e) {
      debugPrint('❌ Eroare la redarea paginii: $e');
    }

    if (mounted) {
      setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _playFromCache(int pageIndex) async {
    final cachedResponse = _audioCache[pageIndex]!;

    // Pregătim highlight-urile pentru pagina curentă
    final page = _currentBook!.pages[pageIndex];
    _wordHighlights = cachedResponse.speechMarks
        .where((mark) =>
            mark.start >= page.startCharIndex && mark.start < page.endCharIndex)
        .map((mark) => WordHighlight(
              start: mark.start - page.startCharIndex,
              end: mark.end - page.startCharIndex,
              word: mark.value,
            ))
        .toList();

    setState(() {
      _speechMarks = cachedResponse.speechMarks;
      _currentWordIndex = -1;
    });

    await _audioPlayer.setUrl(cachedResponse.audioUrl!);
    _audioPlayer.play();
    _preloadNext2Pages();
  }

  Future<void> _preloadPageAudio(int pageIndex) async {
    if (_currentBook == null || pageIndex >= _currentBook!.pages.length) {
      return;
    }

    if (_audioCache.containsKey(pageIndex)) {
      return;
    }

    try {
      final page = _currentBook!.pages[pageIndex];

      if (page.content.length > 2900) {
        debugPrint(
            '⚠️ Pagina ${pageIndex + 1} prea lungă (${page.content.length} char)');
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

        debugPrint('✅ Pagina ${pageIndex + 1} → Cache');
      }
    } catch (e) {
      debugPrint('❌ EROARE pagina ${pageIndex + 1}: $e');
    }
  }

  void _preloadNext2Pages() {
    if (_currentBook == null) return;

    final pagesToPreload = <int>[];
    for (int i = 1; i <= 2; i++) {
      final pageIdx = _currentPageIndex + i;
      if (pageIdx < _currentBook!.pages.length &&
          !_audioCache.containsKey(pageIdx)) {
        pagesToPreload.add(pageIdx);
      }
    }

    if (pagesToPreload.isEmpty) return;

    Future.microtask(() async {
      for (final pageIdx in pagesToPreload) {
        await _preloadPageAudio(pageIdx);
      }
    });
  }

  void _playFromWord(int wordIndex) async {
    if (_speechMarks.isEmpty ||
        wordIndex < 0 ||
        wordIndex >= _speechMarks.length) {
      return;
    }

    final mark = _speechMarks[wordIndex];

    if (_audioPlayer.duration == null &&
        _audioCache.containsKey(_currentPageIndex)) {
      final cachedResponse = _audioCache[_currentPageIndex]!;
      await _audioPlayer.setUrl(cachedResponse.audioUrl!);
    }

    await _audioPlayer.seek(Duration(milliseconds: mark.time));
    _audioPlayer.play();

    setState(() {
      _currentWordIndex = wordIndex;
    });
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() {
      _currentWordIndex = -1;
    });
  }

  void _showTableOfContents() {
    if (_currentBook == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cuprins',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _currentBook!.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _currentBook!.chapters[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${chapter.number}'),
                    ),
                    title: Text(chapter.title),
                    subtitle: Text(
                      chapter.isSubChapter ? 'Subcapitol' : 'Capitol',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () {
                      // Găsim prima pagină din capitol
                      final pageIndex = _currentBook!.pages.indexWhere(
                        (page) => page.chapterNumber == chapter.number,
                      );

                      if (pageIndex != -1) {
                        setState(() {
                          _currentPageIndex = pageIndex;
                        });
                        _pageController.jumpToPage(pageIndex);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionSubscription?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: Text(_currentBook?.title ?? 'Sonant Reader'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        leading: _currentBook != null
            ? IconButton(
                icon: const Icon(Icons.menu_book),
                onPressed: _showTableOfContents,
                tooltip: 'Cuprins',
              )
            : null,
        actions: [
          if (_currentBook != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showBookInfo,
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
          _currentWordIndex = -1;
        });
      },
      itemBuilder: (context, index) {
        final page = _currentBook!.pages[index];
        return _buildPage(page);
      },
    );
  }

  Widget _buildPage(BookPage page) {
    // Verificăm dacă e început de capitol
    final isChapterStart = _currentPageIndex == 0 ||
        _currentBook!.pages[_currentPageIndex - 1].chapterNumber !=
            page.chapterNumber;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header pagină
                    Row(
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

                    // 🎯 Capitol header (dacă e începutul unui capitol)
                    if (isChapterStart) ...[
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

                    // ✨ TEXT CU HIGHLIGHT PERFORMANT
                    HighlightedText(
                      text: page.content,
                      highlights: _wordHighlights,
                      currentHighlightIndex: _currentWordIndex,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        color: Colors.black87,
                        fontFamily: 'serif',
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.justify,
                      onWordTap: (wordIndex) {
                        // Găsim index-ul global din speech marks
                        if (wordIndex < _wordHighlights.length) {
                          final localHighlight = _wordHighlights[wordIndex];
                          final globalIndex = _speechMarks.indexWhere(
                            (mark) =>
                                mark.start - page.startCharIndex ==
                                localHighlight.start,
                          );
                          if (globalIndex != -1) {
                            _playFromWord(globalIndex);
                          }
                        }
                      },
                      scrollController: _scrollController,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Progress bar
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
            color: Colors.black.withOpacity(0.1),
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
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.stop, size: 28),
                onPressed: _stopAudio,
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
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.library_books, size: 28),
                onPressed: _isLoadingAudio ? null : _playCurrentPage,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 32),
                onPressed: _currentPageIndex < _currentBook!.pages.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
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
                      setState(() => _selectedVoice = value);
                      _audioCache.clear();
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
            Text('Capitole: ${_currentBook!.chapters.length}'),
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
