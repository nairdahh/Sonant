// lib/screens/updated_book_reader_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../services/advanced_book_parser_service.dart';
import '../services/tts_service.dart';
import '../services/firestore_service.dart';
import '../services/highlight_manager.dart';
import '../models/polly_response.dart';
import '../models/saved_book.dart';
import '../widgets/highlighted_text_widget.dart';

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
  final TTSService _ttsService = TTSService();
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
  double _ttsProgress = 0.0;
  String _selectedVoice = 'af_bella';
  bool _isPlaying = false;
  String? _lastError;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;

  Map<int, PollyResponse> _audioCache = {};
  Timer? _progressSaveTimer;

  // Tracks pages currently being preloaded to prevent duplicate requests
  final Set<int> _preloadingPages = {};

  late HighlightManager _highlightManager;
  HighlightState _highlightState = HighlightState(
    currentPageIndex: -1,
    currentWordIndex: -1,
    wordHighlights: [],
    isActive: false,
  );

  @override
  void initState() {
    super.initState();

    _savedBook = widget.savedBook;

    _highlightManager = HighlightManager(
      audioPlayer: _audioPlayer,
      onStateChanged: (state) {
        if (mounted) {
          setState(() {
            _highlightState = state;
          });
        }
      },
    );

    if (widget.initialFileBytes != null && widget.initialFileName != null) {
      _loadInitialBook();
    }

    _progressSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveProgress();
    });

    _audioPlayer.setVolume(_volume);
    _audioPlayer.setSpeed(_playbackSpeed);

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
        _currentPageIndex = widget.savedBook?.lastPageIndex ?? 0;
        _isLoading = false;
      });

      if (book != null && _currentPageIndex > 0) {
        _pageController.jumpToPage(_currentPageIndex);
      }
    }
  }

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

    setState(() {
      _isPlaying = false;
    });

    _highlightManager.stop();

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
          _audioCache = {};
          _savedBook = null;
        });

        _highlightManager.stop();
        _audioPlayer.stop();

        if (book != null) {
          _pageController.jumpToPage(0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Book loaded: ${book.title}\n'
                '${book.chapters.length} chapters, ${book.pages.length} pages',
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
      _ttsProgress = 0.0;
      _lastError = null;
    });

    try {
      await _preloadPageAudio(_currentPageIndex);

      if (_audioCache.containsKey(_currentPageIndex) && mounted) {
        await _playFromCache(_currentPageIndex);
      } else if (mounted) {
        // TTS failed to generate audio
        setState(() {
          _lastError =
              'Could not generate audio for this page. Please try again.';
        });
      }

      Future.microtask(() async {
        for (int i = 1; i <= 2; i++) {
          final pageIdx = _currentPageIndex + i;
          if (pageIdx < _currentBook!.pages.length &&
              !_audioCache.containsKey(pageIdx)) {
            await _preloadPageAudio(pageIdx);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = 'Error: ${e.toString()}';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingAudio = false;
        _ttsProgress = 0.0;
      });
    }
  }

  Future<void> _playFromCache(int pageIndex) async {
    final cachedResponse = _audioCache[pageIndex]!;
    final page = _currentBook!.pages[pageIndex];

    await _audioPlayer.setUrl(cachedResponse.audioUrl!);
    await _audioPlayer.load();

    final actualDuration = _audioPlayer.duration;
    List<SpeechMark> calibratedMarks = cachedResponse.speechMarks;

    // Aggressive auto-calibration with predictive offset
    if (actualDuration != null && calibratedMarks.isNotEmpty) {
      final estimatedDuration = calibratedMarks.last.time;
      final actualDurationMs = actualDuration.inMilliseconds;

      final scaleFactor = actualDurationMs / estimatedDuration;

      // Reduced threshold from 3% to 0.5% for more accurate calibration
      // Global offset: -80ms advances highlights to compensate for audio pipeline latency
      const double calibrationThreshold = 0.005;
      const int globalOffsetMs = -80;

      if ((scaleFactor - 1.0).abs() > calibrationThreshold) {
        calibratedMarks = calibratedMarks.map((mark) {
          // Apply both scaling and global offset, then clamp to valid range
          final adjustedTime =
              ((mark.time * scaleFactor).round() + globalOffsetMs)
                  .clamp(0, actualDurationMs);

          return SpeechMark(
            time: adjustedTime,
            type: mark.type,
            start: mark.start,
            end: mark.end,
            value: mark.value,
          );
        }).toList();
      } else {
        // Even if scaling not needed, apply global offset for latency compensation
        calibratedMarks = calibratedMarks.map((mark) {
          return SpeechMark(
            time: (mark.time + globalOffsetMs).clamp(0, actualDurationMs),
            type: mark.type,
            start: mark.start,
            end: mark.end,
            value: mark.value,
          );
        }).toList();
      }
    }

    // Map speech marks to word highlights with exact position matching
    final wordHighlights = <WordHighlight>[];
    final pageContent = page.content;

    for (final mark in calibratedMarks) {
      if (mark.type != 'word') continue;

      if (mark.start < page.startCharIndex || mark.start >= page.endCharIndex) {
        continue;
      }

      final localStart = mark.start - page.startCharIndex;

      // Try exact position first
      if (localStart >= 0 && localStart < pageContent.length) {
        final expectedEnd =
            (localStart + mark.value.length).clamp(0, pageContent.length);
        final textAtPosition = pageContent.substring(localStart, expectedEnd);

        final cleanExpected =
            mark.value.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
        final cleanActual =
            textAtPosition.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');

        if (cleanExpected == cleanActual) {
          wordHighlights.add(WordHighlight(
            start: localStart,
            end: expectedEnd,
            word: textAtPosition,
          ));
          continue;
        }
      }

      // Fallback: fuzzy search within 25 char window
      final searchStart = (localStart - 25).clamp(0, pageContent.length);
      final searchEnd =
          (localStart + mark.value.length + 25).clamp(0, pageContent.length);
      final searchArea = pageContent.substring(searchStart, searchEnd);

      final cleanSearchWord =
          mark.value.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      final wordRegex = RegExp(r'\b\w+\b');
      final matches = wordRegex.allMatches(searchArea);

      int bestMatchStart = localStart;
      int bestMatchEnd = localStart + mark.value.length;
      int bestDistance = 999999;

      for (final match in matches) {
        final matchWord = match.group(0)!.toLowerCase();
        if (matchWord == cleanSearchWord) {
          final absoluteStart = searchStart + match.start;
          final distance = (absoluteStart - localStart).abs();

          if (distance < bestDistance) {
            bestDistance = distance;
            bestMatchStart = absoluteStart;
            bestMatchEnd = absoluteStart + match.group(0)!.length;
          }
        }
      }

      if (bestMatchStart >= 0 &&
          bestMatchEnd <= pageContent.length &&
          bestMatchStart < bestMatchEnd) {
        wordHighlights.add(WordHighlight(
          start: bestMatchStart,
          end: bestMatchEnd,
          word: pageContent.substring(bestMatchStart, bestMatchEnd),
        ));
      }
    }

    _highlightManager.initializeForPage(
      pageIndex: pageIndex,
      speechMarks: calibratedMarks,
      wordHighlights: wordHighlights,
    );

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

    if (_preloadingPages.contains(pageIndex)) {
      return;
    }

    _preloadingPages.add(pageIndex);

    try {
      final page = _currentBook!.pages[pageIndex];

      // Text length validation (silent in production)
      if (kDebugMode && page.content.length > TTSService.maxTextLength * 0.9) {
        debugPrint(
            'Page ${pageIndex + 1} near TTS limit: ${page.content.length}/${TTSService.maxTextLength} chars');
      }

      final ttsResponse = await _ttsService.synthesizeSpeech(
        page.content,
        voiceId: _selectedVoice,
        bookId: _savedBook?.id,
        pageIndex: pageIndex,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _ttsProgress = progress);
          }
        },
      );

      if (ttsResponse != null && ttsResponse.audioUrl != null) {
        final adjustedMarks = ttsResponse.speechMarks.map((mark) {
          return SpeechMark(
            time: mark.time,
            type: mark.type,
            start: mark.start + page.startCharIndex,
            end: mark.end + page.startCharIndex,
            value: mark.value,
          );
        }).toList();

        _audioCache[pageIndex] = PollyResponse(
          audioUrl: ttsResponse.audioUrl,
          speechMarks: adjustedMarks,
        );

        if (kDebugMode) {
          debugPrint('Page ${pageIndex + 1} cached successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error generating audio for page ${pageIndex + 1}: $e');
      }
    } finally {
      _preloadingPages.remove(pageIndex);
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
    final speechMarks = _highlightState.isActive
        ? _audioCache[_currentPageIndex]?.speechMarks ?? []
        : [];

    if (speechMarks.isEmpty ||
        wordIndex < 0 ||
        wordIndex >= speechMarks.length) {
      return;
    }

    final mark = speechMarks[wordIndex];

    if (_audioPlayer.duration == null &&
        _audioCache.containsKey(_currentPageIndex)) {
      final cachedResponse = _audioCache[_currentPageIndex]!;
      await _audioPlayer.setUrl(cachedResponse.audioUrl!);
    }

    await _audioPlayer.seek(Duration(milliseconds: mark.time));
    _audioPlayer.play();
  }

  void _stopAudio() {
    _audioPlayer.stop();
    _highlightManager.stop();
    _ttsService.cancelAllRequests();
  }

  Future<void> _restartPage() async {
    if (_audioPlayer.duration == null) {
      await _playCurrentPage();
    } else {
      await _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    }
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume.clamp(0.0, 1.0);
    });
    _audioPlayer.setVolume(_volume);
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed.clamp(0.5, 2.0);
    });
    _audioPlayer.setSpeed(_playbackSpeed);
  }

  Future<void> _changeVoice(String newVoice) async {
    if (newVoice == _selectedVoice) return;

    final wasPlaying = _isPlaying;
    final currentPosition = _audioPlayer.position;

    setState(() {
      _selectedVoice = newVoice;
    });

    _ttsService.cancelAllRequests();

    // Smart cache invalidation: clear only pages near current position
    final keysToRemove = _audioCache.keys.where((pageIdx) {
      final distance = (pageIdx - _currentPageIndex).abs();
      return distance <= 5;
    }).toList();

    for (final key in keysToRemove) {
      _audioCache.remove(key);
    }
    if (kDebugMode) {
      debugPrint(
          'Cleared ${keysToRemove.length} cached pages near current page');
    }

    if (_audioPlayer.duration != null) {
      await _audioPlayer.stop();
      _highlightManager.stop();

      setState(() {
        _isLoadingAudio = true;
      });

      await _preloadPageAudio(_currentPageIndex);

      if (_audioCache.containsKey(_currentPageIndex) && mounted) {
        await _playFromCache(_currentPageIndex);

        await _audioPlayer.seek(currentPosition);

        if (wasPlaying) {
          _audioPlayer.play();
        } else {
          _audioPlayer.pause();
        }
      }

      setState(() {
        _isLoadingAudio = false;
      });
    }
  }

  Widget _buildTableOfContentsDrawer() {
    if (_currentBook == null) return const SizedBox.shrink();

    return Drawer(
      child: Container(
        color: const Color(0xFFFFFDF7),
        child: Column(
          children: [
            Container(
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
                    _currentBook!.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _currentBook!.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _currentBook!.chapters[index];
                  final pageIndex = _currentBook!.pages.indexWhere(
                    (page) => page.chapterNumber == chapter.number,
                  );
                  final isCurrentChapter = pageIndex != -1 &&
                      _currentPageIndex >= pageIndex &&
                      (_currentPageIndex < _currentBook!.pages.length - 1 &&
                          _currentBook!
                                  .pages[_currentPageIndex].chapterNumber ==
                              chapter.number);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentChapter
                          ? const Color(0xFF8B4513)
                          : Colors.brown[100],
                      foregroundColor:
                          isCurrentChapter ? Colors.white : Colors.brown[700],
                      child: Text(
                        '${chapter.number}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        fontWeight: isCurrentChapter
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrentChapter
                            ? const Color(0xFF8B4513)
                            : Colors.black87,
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
                        setState(() {
                          _currentPageIndex = pageIndex;
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
  void deactivate() {
    _saveProgress();
    super.deactivate();
  }

  @override
  void dispose() {
    _highlightManager.dispose();
    _audioPlayer.dispose();
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
      drawer: _buildTableOfContentsDrawer(),
      appBar: AppBar(
        title: Text(_currentBook?.title ?? 'Sonant Reader'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        leading: _currentBook != null
            ? IconButton(
                icon: const Icon(Icons.menu_book),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                tooltip: 'Table of Contents',
              )
            : null,
        actions: [
          if (_currentBook != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _stopAudio();
                _saveProgress();
                Navigator.of(context).pop();
              },
              tooltip: 'Close book',
            ),
          if (_currentBook != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showBookInfo,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _currentBook != null ? _buildControls() : null,
      floatingActionButton: _currentBook == null
          ? FloatingActionButton(
              onPressed: _pickBook,
              backgroundColor: const Color(0xFF8B4513),
              child: const Icon(Icons.menu_book, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
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
                'Loading book...',
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
              'Press the button below\nto load a book',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Supported formats: EPUB, PDF, TXT',
              style: TextStyle(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      physics: _isPlaying
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      itemCount: _currentBook!.pages.length,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
        _highlightManager.stop();
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        _saveProgress();
      },
      itemBuilder: (context, index) {
        final page = _currentBook!.pages[index];
        return _buildPage(page);
      },
    );
  }

  Widget _buildPage(BookPage page) {
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
                              'Page ${page.pageNumber}',
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
                                        'Image cannot be displayed',
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
                    HighlightedText(
                      text: page.content,
                      highlights: _highlightState.wordHighlights,
                      currentHighlightIndex: _highlightState.currentWordIndex,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        color: Colors.black87,
                        fontFamily: 'serif',
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.justify,
                      onWordTap: (wordIndex) {
                        if (wordIndex < _highlightState.wordHighlights.length) {
                          final localHighlight =
                              _highlightState.wordHighlights[wordIndex];
                          final cachedResponse = _audioCache[_currentPageIndex];
                          if (cachedResponse != null) {
                            final globalIndex =
                                cachedResponse.speechMarks.indexWhere(
                              (mark) =>
                                  mark.start - page.startCharIndex ==
                                  localHighlight.start,
                            );
                            if (globalIndex != -1) {
                              _playFromWord(globalIndex);
                            }
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
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      value: _ttsProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8B4513)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generating audio... ${(_ttsProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          if (_lastError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: TextStyle(fontSize: 12, color: Colors.red[900]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _lastError = null);
                        _playCurrentPage();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child:
                          const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                        _stopAudio();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                tooltip: 'Previous page',
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restart_alt, size: 28),
                    onPressed:
                        _audioPlayer.duration != null ? _restartPage : null,
                    tooltip: 'Restart',
                  ),
                  Text(
                    'Restart',
                    style: TextStyle(
                      fontSize: 10,
                      color: _audioPlayer.duration != null
                          ? Colors.black54
                          : Colors.grey[300],
                    ),
                  ),
                ],
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
                    tooltip: isPlaying ? 'Pause' : 'Play',
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, size: 28),
                    onPressed: _isLoadingAudio ? null : _playCurrentPage,
                    tooltip: 'Read page',
                  ),
                  Text(
                    'Read from\nhere',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color:
                          _isLoadingAudio ? Colors.grey[300] : Colors.black54,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
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
                            _stopAudio();
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                tooltip: 'Next page',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over,
                        size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedVoice,
                      underline: Container(),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(
                          value: 'af_bella',
                          child: Text('Bella (US) ♀ ⭐'),
                        ),
                        DropdownMenuItem(
                          value: 'af_sarah',
                          child: Text('Sarah (US) ♀'),
                        ),
                        DropdownMenuItem(
                          value: 'af_nicole',
                          child: Text('Nicole (US) ♀'),
                        ),
                        DropdownMenuItem(
                          value: 'af_sky',
                          child: Text('Sky (US) ♀'),
                        ),
                        DropdownMenuItem(
                          value: 'am_adam',
                          child: Text('Adam (US) ♂'),
                        ),
                        DropdownMenuItem(
                          value: 'am_michael',
                          child: Text('Michael (US) ♂'),
                        ),
                        DropdownMenuItem(
                          value: 'bf_emma',
                          child: Text('Emma (UK) ♀'),
                        ),
                        DropdownMenuItem(
                          value: 'bf_isabella',
                          child: Text('Isabella (UK) ♀'),
                        ),
                        DropdownMenuItem(
                          value: 'bm_george',
                          child: Text('George (UK) ♂'),
                        ),
                        DropdownMenuItem(
                          value: 'bm_lewis',
                          child: Text('Lewis (UK) ♂'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _changeVoice(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _volume == 0
                      ? Icons.volume_off
                      : _volume < 0.5
                          ? Icons.volume_down
                          : Icons.volume_up,
                  size: 20,
                ),
                onPressed: () => _showVolumeControl(),
                tooltip: 'Volume: ${(_volume * 100).toInt()}%',
              ),
              IconButton(
                icon: const Icon(Icons.speed, size: 20),
                onPressed: () => _showSpeedControl(),
                tooltip: 'Speed: ${_playbackSpeed}x',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVolumeControl() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.volume_up, size: 24),
            SizedBox(width: 12),
            Text('Volume'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_down, size: 20),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        label: '${(_volume * 100).toInt()}%',
                        onChanged: (value) {
                          setState(() {
                            _setVolume(value);
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_volume * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSpeedControl() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.speed, size: 24),
            SizedBox(width: 12),
            Text('Playback Speed'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _playbackSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  label: '${_playbackSpeed}x',
                  onChanged: (value) {
                    setState(() {
                      _setPlaybackSpeed(value);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '${_playbackSpeed}x',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSpeedChip(0.5, setState),
                    _buildSpeedChip(0.75, setState),
                    _buildSpeedChip(1.0, setState),
                    _buildSpeedChip(1.25, setState),
                    _buildSpeedChip(1.5, setState),
                    _buildSpeedChip(2.0, setState),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(double speed, StateSetter setState) {
    final isSelected = (_playbackSpeed - speed).abs() < 0.01;
    return ChoiceChip(
      label: Text('${speed}x'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _setPlaybackSpeed(speed);
          });
        }
      },
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
            Text('Author: ${_currentBook!.author}'),
            const SizedBox(height: 8),
            Text('Format: ${_currentBook!.format.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Chapters: ${_currentBook!.chapters.length}'),
            const SizedBox(height: 8),
            Text('Total pages: ${_currentBook!.pages.length}'),
            const SizedBox(height: 8),
            Text('Current page: ${_currentPageIndex + 1}'),
            const SizedBox(height: 8),
            Text(
              'Progress: ${((_currentPageIndex + 1) / _currentBook!.pages.length * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            Text('Cached audio: ${_audioCache.length} pages'),
            const SizedBox(height: 8),
            const Text('Engine: Kokoro TTS'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
