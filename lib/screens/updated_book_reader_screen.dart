// lib/screens/updated_book_reader_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../services/advanced_book_parser_service.dart';
import '../services/polly_service.dart';
import '../services/firestore_service.dart';
import '../models/polly_response.dart';
import '../models/saved_book.dart';
import '../widgets/highlighted_text_widget.dart';
import 'dart:typed_data';

class UpdatedBookReaderScreen extends StatefulWidget {
  final Uint8List? initialFileBytes;
  final String? initialFileName;
  final SavedBook? savedBook;

  const UpdatedBookReaderScreen({
    super.key,
    this.initialFileBytes,
    this.initialFileName,
    this.savedBook,
  });

  @override
  State<UpdatedBookReaderScreen> createState() =>
      _UpdatedBookReaderScreenState();
}

class _UpdatedBookReaderScreenState extends State<UpdatedBookReaderScreen> {
  final AdvancedBookParser _bookParser = AdvancedBookParser();
  final PollyService _pollyService = PollyService();
  final FirestoreService _firestoreService = FirestoreService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ParsedBook? _currentBook;
  SavedBook? _savedBook;
  int _currentPageIndex = 0;
  bool _isLoading = false;
  bool _isLoadingAudio = false;
  String _selectedVoice = 'Joanna';
  bool _isPlaying = false;

  Map<int, PollyResponse> _audioCache = {};
  List<SpeechMark> _speechMarks = [];
  List<WordHighlight> _wordHighlights = [];
  int _currentWordIndex = -1;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _progressSaveTimer;

  @override
  void initState() {
    super.initState();

    _savedBook = widget.savedBook;

    // Încarcă cartea dacă avem date inițiale
    if (widget.initialFileBytes != null && widget.initialFileName != null) {
      _loadInitialBook();
    }

    // Timer pentru salvare automată progres (la fiecare 10 secunde)
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveProgress();
    });

    // Track audio position pentru highlight
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_speechMarks.isEmpty || !mounted) return;

      final currentMillis = position.inMilliseconds;
      final lastMarkIndex = _speechMarks.lastIndexWhere(
        (mark) => mark.time <= currentMillis && mark.type == 'word',
      );

      if (lastMarkIndex != _currentWordIndex) {
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

  Future<void> _loadInitialBook() async {
    setState(() => _isLoading = true);

    final book = await _bookParser.parseBook(
      widget.initialFileBytes!,
      widget.initialFileName!,
    );

    if (mounted) {
      setState(() {
        _currentBook = book;
        // Restaurează progresul dacă avem SavedBook
        _currentPageIndex = widget.savedBook?.lastPageIndex ?? 0;
        _isLoading = false;
      });

      if (book != null && _currentPageIndex > 0) {
        _pageController.jumpToPage(_currentPageIndex);
      }
    }
  }

  /// Salvează progresul curent în Firebase
  Future<void> _saveProgress() async {
    if (_savedBook == null || _currentBook == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestoreService.updateReadingProgress(
      userId: user.uid,
      bookId: _savedBook!.id,
      lastPageIndex: _currentPageIndex,
    );
  }

  void _handleAudioComplete() {
    if (!mounted) return;

    debugPrint('✅ Audio terminat, trecem la următoarea pagină...');

    setState(() {
      _isPlaying = false;
      _currentWordIndex = -1;
    });

    if (_currentPageIndex < (_currentBook?.pages.length ?? 0) - 1) {
      _currentPageIndex++;

      // ✅ Navigare programatică (auto-advance) - PERMISĂ
      if (_pageController.hasClients) {
        // Temporar activăm navigarea pentru auto-advance
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
          _savedBook = null; // ✅ Resetăm savedBook pentru cărți noi
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

    // ✅ Dacă avem cache, redăm direct
    if (_audioCache.containsKey(_currentPageIndex)) {
      await _playFromCache(_currentPageIndex);
      _preloadNext2Pages();
      return;
    }

    setState(() {
      _isLoadingAudio = true;
    });

    try {
      // 🚀 OPTIMIZARE: Generăm DOAR prima pagină, redăm imediat
      debugPrint('🎵 Generăm pagina curentă...');
      await _preloadPageAudio(_currentPageIndex);

      // ✅ Redăm imediat după ce prima pagină e gata
      if (_audioCache.containsKey(_currentPageIndex) && mounted) {
        await _playFromCache(_currentPageIndex);
      }

      // 🎵 Generăm următoarele 2 în fundal (fără await)
      Future.microtask(() async {
        for (int i = 1; i <= 2; i++) {
          final pageIdx = _currentPageIndex + i;
          if (pageIdx < _currentBook!.pages.length &&
              !_audioCache.containsKey(pageIdx)) {
            await _preloadPageAudio(pageIdx);
            debugPrint('✅ [FUNDAL] Pagina ${pageIdx + 1} gata!');
          }
        }
      });
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

    // 🎯 CALIBRARE EXACTĂ: Căutăm cuvintele în textul real
    _wordHighlights = [];
    final pageContent = page.content;

    for (final mark in cachedResponse.speechMarks) {
      if (mark.type != 'word') continue;

      // Verificăm dacă mark-ul e în această pagină
      if (mark.start < page.startCharIndex || mark.start >= page.endCharIndex) {
        continue;
      }

      // Poziția relativă în pagină
      final localStart = mark.start - page.startCharIndex;

      // 🔍 Căutăm cuvântul în textul real
      // Polly dă poziții aproximative, trebuie să căutăm cuvântul real
      final searchWord =
          mark.value.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');

      // Căutăm în jurul poziției date de Polly (±50 caractere)
      final searchStart = (localStart - 50).clamp(0, pageContent.length);
      final searchEnd =
          (localStart + mark.value.length + 50).clamp(0, pageContent.length);
      final searchArea = pageContent.substring(searchStart, searchEnd);

      // Găsim toate cuvintele din zona de căutare
      final wordRegex = RegExp(r'\b\w+\b');
      final matches = wordRegex.allMatches(searchArea);

      // Găsim cel mai apropiat match
      int bestMatchStart = localStart;
      int bestMatchEnd = localStart + mark.value.length;
      int bestDistance = 999999;

      for (final match in matches) {
        final matchWord = match.group(0)!.toLowerCase();
        if (matchWord == searchWord ||
            (matchWord.length >= 3 &&
                searchWord.startsWith(matchWord.substring(0, 3)))) {
          final absoluteStart = searchStart + match.start;
          final distance = (absoluteStart - localStart).abs();

          if (distance < bestDistance) {
            bestDistance = distance;
            bestMatchStart = absoluteStart;
            bestMatchEnd = absoluteStart + match.group(0)!.length;
          }
        }
      }

      // Verificăm bounds
      if (bestMatchStart >= 0 &&
          bestMatchEnd <= pageContent.length &&
          bestMatchStart < bestMatchEnd) {
        _wordHighlights.add(WordHighlight(
          start: bestMatchStart,
          end: bestMatchEnd,
          word: pageContent.substring(bestMatchStart, bestMatchEnd),
        ));
      }
    }

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
                          _currentWordIndex = -1;
                          _speechMarks = [];
                          _wordHighlights = [];
                        });
                        _stopAudio();
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
    _saveProgress(); // Salvează progresul la ieșire
    _audioPlayer.dispose();
    _positionSubscription?.cancel();
    _progressSaveTimer?.cancel();
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
    // ✅ Loading overlay la deschidere carte
    if (_isLoading) {
      return Container(
        color: const Color(0xFFFFFDF7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
              ),
              const SizedBox(height: 24),
              Text(
                'Se încarcă cartea...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
      // ✅ Dezactivăm DOAR swipe manual când audio redă
      physics: _isPlaying
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      itemCount: _currentBook!.pages.length,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
          _currentWordIndex = -1;
          _speechMarks = [];
          _wordHighlights = [];
        });
        // Reset scroll position
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        // Salvează progresul (fără await pentru a nu bloca UI)
        _saveProgress();
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

                    // 🎯 Capitol header (doar dacă e începutul unui capitol)
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

                    // ✅ Afișăm elementele paginii (text + imagini)
                    ...page.elements
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
                                      Icon(Icons.broken_image,
                                          color: Colors.grey[400]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Imagine nu poate fi afișată',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
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
                    }),

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
          // ✅ Loading simplu când generăm audio
          if (_isLoadingAudio)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Generare audio...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ✅ Disabled când audio redă (doar navigare manuală)
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  size: 32,
                  color: (_currentPageIndex > 0 && !_isPlaying)
                      ? null
                      : Colors.grey[300],
                ),
                onPressed: (_currentPageIndex > 0 && !_isPlaying)
                    ? () {
                        _stopAudio(); // Stop audio dacă există
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
                onPressed: _isPlaying ? _stopAudio : null,
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
              // ✅ Disabled când audio redă (doar navigare manuală)
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 32,
                  color: (_currentPageIndex < _currentBook!.pages.length - 1 &&
                          !_isPlaying)
                      ? null
                      : Colors.grey[300],
                ),
                onPressed:
                    (_currentPageIndex < _currentBook!.pages.length - 1 &&
                            !_isPlaying)
                        ? () {
                            _stopAudio(); // Stop audio dacă există
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
