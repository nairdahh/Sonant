// lib/screens/updated_book_reader_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/advanced_book_parser_service.dart';
import '../services/book_cache_service.dart';
import '../services/highlight_manager.dart' hide HighlightState;
import '../services/sentence_parser.dart';
import '../services/sentence_tts_controller.dart';
import '../models/tts_response.dart';
import '../models/saved_book.dart';
import '../models/sentence_segment.dart';
import '../widgets/highlighted_text_widget.dart';
import '../widgets/modern_player_controls.dart';
import '../utils/lru_cache.dart';
import '../utils/web_audio_player.dart';
import '../theme.dart';
import '../providers/audio/audio_state_provider.dart';
import '../providers/audio/audio_player_provider.dart';
import '../providers/audio/tts_service_provider.dart';
import '../providers/audio/highlight_state_provider.dart';
import '../providers/services/firestore_service_provider.dart';
import '../providers/services/book_parser_provider.dart';
import '../providers/reader/reader_settings_provider.dart';
import '../providers/reader/book_state_provider.dart';
import '../providers/database_provider.dart';
import '../services/tts_service.dart';
import '../widgets/loading_dialog.dart';

class UpdatedBookReaderScreen extends ConsumerStatefulWidget {
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
  ConsumerState<UpdatedBookReaderScreen> createState() =>
      _UpdatedBookReaderScreenState();
}

class _UpdatedBookReaderScreenState
    extends ConsumerState<UpdatedBookReaderScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Local state that's NOT managed by providers
  bool _isLoadingAudio = false;
  // ignore: unused_field - stored for future progress display
  double _ttsProgress = 0.0;
  // ignore: unused_field - stored for future error display
  String? _lastError;

  // LRU Cache with max 15 pages to prevent memory leaks
  // Enough for: current page + 2 preloaded next + 2 preloaded prev + 10 history
  final LRUCache<int, TtsResponse> _audioCache = LRUCache(15);
  Timer? _progressSaveTimer;

  // Tracks pages currently being preloaded to prevent duplicate requests
  final Set<int> _preloadingPages = {};

  late HighlightManager _highlightManager;

  // Web audio player for HTML5 Audio on Web platform
  WebAudioPlayer? _webAudioPlayer;
  StreamSubscription<Duration>? _webPositionSubscription;
  StreamSubscription<bool>? _webPlayingSubscription;

  // Separate audio player for voice preview - completely isolated from book playback
  AudioPlayer? _previewAudioPlayer;
  WebAudioPlayer? _previewWebAudioPlayer;
  // ignore: unused_field - state for preview playback
  bool _isPreviewPlaying = false;

  // Sentence-based TTS controller for incremental generation
  SentenceTTSController? _sentenceTTSController;
  List<SentenceSegment> _currentPageSentences = [];
  int _currentSentenceIndex = 0;
  bool _sentenceTTSActive = false;

  // Advanced TTS settings
  double _volume = 1.0;
  // Normalization is applied by default under the hood in TTS service

  TextStyle _readerTextStyle(
    BuildContext context, {
    ReaderTypeface? typeface,
    double? fontScale,
    double? lineHeight,
  }) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;
    final readerSettings = ref.read(readerSettingsNotifierProvider);

    TextStyle baseStyle;
    final selectedTypeface = typeface ?? readerSettings.typeface;
    final selectedFontScale = fontScale ?? readerSettings.fontScale;
    final selectedLineHeight = lineHeight ?? readerSettings.lineHeightScale;

    switch (selectedTypeface) {
      case ReaderTypeface.sans:
        baseStyle = GoogleFonts.outfit(
          textStyle: textTheme ?? const TextStyle(fontSize: 18, height: 1.7),
          letterSpacing: 0.15,
        );
        break;
      case ReaderTypeface.serif:
        baseStyle = GoogleFonts.playfairDisplay(
          textStyle: textTheme ?? const TextStyle(fontSize: 18, height: 1.8),
          letterSpacing: 0.3,
        );
        break;
    }

    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 18) * selectedFontScale,
      height: (baseStyle.height ?? 1.6) * selectedLineHeight,
      color: Colors.black87,
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize Web Audio Player on Web platform
    if (kIsWeb) {
      _webAudioPlayer = createWebAudioPlayer();
    }

    // Initialize saved book in provider
    if (widget.savedBook != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(bookStateNotifierProvider.notifier)
            .updateSavedBook(widget.savedBook!);
      });
    }

    // Initialize HighlightManager with audio player from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final audioPlayer = ref.read(audioPlayerProvider);
      _audioPlayerRef = audioPlayer; // Cache for dispose
      final audioState = ref.read(audioStateProvider);
      final ttsService = ref.read(ttsServiceProvider);

      // Initialize sentence-based TTS controller
      _sentenceTTSController = SentenceTTSController(ttsService: ttsService);
      _sentenceTTSController!.voiceId = audioState.selectedVoice;
      _sentenceTTSController!.speed = audioState.playbackSpeed;
      _sentenceTTSController!.onError = (error) {
        if (mounted && kDebugMode) {
          debugPrint('❌ SentenceTTS error: $error');
        }
      };

      _highlightManager = HighlightManager(
        audioPlayer: audioPlayer,
        onStateChanged: (state) {
          if (mounted) {
            final highlightNotifier = ref.read(highlightStateProvider.notifier);
            // Update word index for real-time highlighting
            highlightNotifier.updateWordIndex(state.currentWordIndex);
          }
        },
      );

      // On Web, use manual position updates (WebAudioPlayer provides position)
      if (kIsWeb) {
        _highlightManager.setManualUpdateMode(true);
      }

      // Set initial audio settings
      audioPlayer.setVolume(audioState.volume);
      audioPlayer.setSpeed(audioState.playbackSpeed);

      // On Web, also set speed for web audio player
      if (kIsWeb && _webAudioPlayer != null) {
        _webAudioPlayer!.setSpeed(audioState.playbackSpeed);
      }

      // Listen to player state changes
      audioPlayer.playerStateStream.listen((playerState) {
        if (mounted) {
          if (playerState.playing) {
            ref.read(audioStateProvider.notifier).play();
          } else {
            ref.read(audioStateProvider.notifier).pause();
          }
        }

        if (playerState.processingState == ProcessingState.completed) {
          if (audioPlayer.position >= (audioPlayer.duration ?? Duration.zero)) {
            _handleAudioComplete();
          }
        }
      });
    });

    if (widget.initialFileBytes != null && widget.initialFileName != null) {
      // Delay to avoid modifying provider during build
      Future.microtask(() => _loadInitialBook());
    }

    _progressSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveProgressIfChanged();
    });
  }

  // Track last saved page to avoid duplicate saves
  int _lastSavedPage = -1;

  /// Saves progress only if page changed since last save
  Future<void> _saveProgressIfChanged() async {
    if (!mounted) return;
    final bookState = ref.read(bookStateNotifierProvider);
    final currentPage = bookState.currentPageIndex;

    // Skip if page hasn't changed
    if (currentPage == _lastSavedPage) return;

    await _saveProgress();
    _lastSavedPage = currentPage;
  }

  Future<void> _loadInitialBook() async {
    if (!mounted) return;

    // Capture all providers before async operation
    final bookNotifier = ref.read(bookStateNotifierProvider.notifier);
    final bookParser = ref.read(bookParserProvider);
    final readerSettingsNotifier =
        ref.read(readerSettingsNotifierProvider.notifier);

    // Try to get cached parsed book first
    final bookId = widget.savedBook?.id;
    ParsedBook? book;

    if (bookId != null) {
      final cacheService = BookCacheService();
      book = cacheService.getParsedBookFromMemory(bookId);
      if (book != null && kDebugMode) {
        debugPrint('⚡ Using cached parsed book: ${book.title}');
      }
    }

    // Parse if not in cache - with progress dialog
    if (book == null && widget.initialFileBytes != null) {
      // Show loading dialog
      final dialogController = LoadingDialogController();
      dialogController.update(
        title: 'Opening Book',
        message: 'Starting...',
        progress: 0.0,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (dialogContext) => AnimatedBuilder(
          animation: dialogController,
          builder: (context, _) => LoadingDialog(
            title: dialogController.title,
            message: dialogController.message,
            progress: dialogController.progress,
            showProgress: dialogController.showProgress,
          ),
        ),
      );

      book = await bookParser.parseBook(
        widget.initialFileBytes!,
        widget.initialFileName!,
        onProgress: (progress, status) {
          dialogController.update(
            message: status,
            progress: progress,
          );
        },
      );

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Cache the parsed book for next time
      if (book != null && bookId != null) {
        final cacheService = BookCacheService();
        cacheService.cacheParsedBookInMemory(bookId, book);
      }
    }

    if (mounted && book != null) {
      bookNotifier.setBook(book, widget.savedBook);
      final pageIndex = widget.savedBook?.lastPageIndex ?? 0;
      bookNotifier.setCurrentPage(pageIndex);
      bookNotifier.setLoading(false);

      // Ensure immersive mode is off initially
      if (ref.read(readerSettingsNotifierProvider).immersiveMode) {
        readerSettingsNotifier.toggleImmersiveMode();
      }

      if (pageIndex > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(pageIndex);
          }
        });
      }
    } else if (mounted) {
      bookNotifier.setLoading(false);
    }
  }

  /// Saves reading progress - Drift first (instant), then Firestore (queued)
  Future<void> _saveProgress() async {
    // Read all needed values BEFORE any async operation
    if (!mounted) return;

    final bookState = ref.read(bookStateNotifierProvider);
    if (bookState.savedBook == null || bookState.currentBook == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookId = bookState.savedBook!.id;
    final pageIndex = bookState.currentPageIndex;

    // Capture providers before async operations
    final db = ref.read(appDatabaseProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    // 1. Save to Drift FIRST (instant, local)
    try {
      await db.updateBookLastPage(bookId, pageIndex);
      // Only log in debug mode and only occasionally
      if (kDebugMode && pageIndex % 5 == 0) {
        debugPrint('📱 Progress saved: page $pageIndex');
      }
    } catch (e) {
      debugPrint('⚠️ Local save failed: $e');
    }

    // 2. Queue Firestore update (async, can fail without affecting UX)
    try {
      await firestoreService.updateReadingProgress(
        userId: user.uid,
        bookId: bookId,
        lastPageIndex: pageIndex,
      );
    } catch (e) {
      // Firestore failed - no problem, local data is saved (silent)
    }
  }

  void _handleAudioComplete() {
    if (!mounted) return;

    // Capture providers before any operations
    final audioStateNotifier = ref.read(audioStateProvider.notifier);
    final bookStateNotifier = ref.read(bookStateNotifierProvider.notifier);
    final bookState = ref.read(bookStateNotifierProvider);

    audioStateNotifier.pause();
    _highlightManager.stop();

    // Reset sentence TTS state
    _sentenceTTSActive = false;
    _sentenceTTSController?.stop();
    _currentPageSentences = [];
    _currentSentenceIndex = 0;

    // Stop web audio player
    if (kIsWeb && _webAudioPlayer != null) {
      _webAudioPlayer!.onComplete = null;
    }

    final currentPageIndex = bookState.currentPageIndex;
    final totalPages = bookState.currentBook?.pages.length ?? 0;

    if (currentPageIndex < totalPages - 1) {
      bookStateNotifier.nextPage();
      final newPageIndex = currentPageIndex + 1;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          newPageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }

      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          // Always use sentence-based TTS for new pages
          await _playCurrentPage();
        }
      });
    }
  }

  Future<void> _pickBook() async {
    if (!mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'txt'],
    );

    if (!mounted) return;

    if (result != null && result.files.first.bytes != null) {
      // Capture providers before async operation
      final bookNotifier = ref.read(bookStateNotifierProvider.notifier);
      final readerSettingsNotifier =
          ref.read(readerSettingsNotifierProvider.notifier);
      final audioPlayer = ref.read(audioPlayerProvider);
      final bookParser = ref.read(bookParserProvider);

      // Show loading dialog with progress
      final dialogController = LoadingDialogController();
      dialogController.update(
        title: 'Loading Book',
        message: 'Starting...',
        progress: 0.0,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (dialogContext) => AnimatedBuilder(
          animation: dialogController,
          builder: (context, _) => LoadingDialog(
            title: dialogController.title,
            message: dialogController.message,
            progress: dialogController.progress,
            showProgress: dialogController.showProgress,
          ),
        ),
      );

      final book = await bookParser.parseBook(
        result.files.first.bytes!,
        result.files.first.name,
        onProgress: (progress, status) {
          dialogController.update(
            message: status,
            progress: progress,
          );
        },
      );

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted && book != null) {
        bookNotifier.setBook(book, null);
        bookNotifier.setCurrentPage(0);
        _audioCache.clear();

        // Ensure immersive mode is off
        if (ref.read(readerSettingsNotifierProvider).immersiveMode) {
          readerSettingsNotifier.toggleImmersiveMode();
        }

        _highlightManager.stop();
        audioPlayer.stop();

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

  /// Play current page using sentence-by-sentence TTS
  /// First sentence starts immediately, rest preload in background
  Future<void> _playCurrentPage() async {
    if (!mounted) return;

    final bookState = ref.read(bookStateNotifierProvider);
    final currentBook = bookState.currentBook;
    final currentPageIndex = bookState.currentPageIndex;
    final savedBook = bookState.savedBook;

    if (currentBook == null || currentPageIndex >= currentBook.pages.length) {
      return;
    }

    final page = currentBook.pages[currentPageIndex];

    // Show loading dialog
    final dialogController = LoadingDialogController();
    dialogController.update(
      title: 'Generating Audio',
      message: 'Preparing sentences...',
      progress: 0.1,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AnimatedBuilder(
        animation: dialogController,
        builder: (context, _) => LoadingDialog(
          title: dialogController.title,
          message: dialogController.message,
          progress: dialogController.progress,
          showProgress: dialogController.showProgress,
        ),
      ),
    );

    setState(() {
      _isLoadingAudio = true;
      _ttsProgress = 0.0;
      _lastError = null;
      _sentenceTTSActive = true;
    });

    try {
      // Parse page into sentences
      dialogController.update(
        message: 'Parsing text...',
        progress: 0.2,
      );

      _currentPageSentences = SentenceParser.parse(
        text: page.content,
        pageIndex: currentPageIndex,
        pageStartIndex: page.startCharIndex,
        bookId: savedBook?.id ?? 'unknown',
      );

      if (_currentPageSentences.isEmpty) {
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          setState(() {
            _isLoadingAudio = false;
            _lastError = 'No sentences found on this page.';
          });
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
            '📝 Page $currentPageIndex: ${_currentPageSentences.length} sentences');
      }

      dialogController.update(
        message: 'Initializing TTS...',
        progress: 0.3,
      );

      // Initialize controller with sentences
      await _sentenceTTSController!.initialize(_currentPageSentences);
      _sentenceTTSController!.voiceId =
          ref.read(audioStateProvider).selectedVoice;
      _sentenceTTSController!.speed =
          ref.read(audioStateProvider).playbackSpeed;

      dialogController.update(
        message: 'Generating first sentence...',
        progress: 0.5,
      );

      // Start from first sentence
      _currentSentenceIndex = 0;
      final firstAudio = await _sentenceTTSController!.startFrom(0);

      // Close dialog before playing
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (firstAudio != null && mounted) {
        await _playSentenceAudio(firstAudio, 0);
      } else if (mounted) {
        setState(() {
          _lastError = 'Could not generate audio. Please try again.';
        });
      }
    } catch (e) {
      // Close dialog on error
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _lastError = 'Error: ${e.toString()}';
        });
        if (kDebugMode) {
          debugPrint('❌ TTS error: $e');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingAudio = false;
        _ttsProgress = 0.0;
      });
    }
  }

  /// Play audio for a single sentence with highlight sync
  Future<void> _playSentenceAudio(
      SentenceAudio audio, int sentenceIndex) async {
    if (!mounted || !_sentenceTTSActive) return;

    final bookState = ref.read(bookStateNotifierProvider);
    final currentBook = bookState.currentBook;
    if (currentBook == null) return;

    final pageIndex = bookState.currentPageIndex;
    final page = currentBook.pages[pageIndex];
    final sentence = _currentPageSentences[sentenceIndex];

    if (kDebugMode) {
      debugPrint(
          '🎧 Playing sentence $sentenceIndex: "${sentence.text.substring(0, sentence.text.length.clamp(0, 40))}..."');
    }

    // Create audio URL from base64
    final audioUrl = _sentenceTTSController!.getAudioUrl(audio);
    if (audioUrl.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ Empty audio URL for sentence $sentenceIndex');
      }
      // Try to move to next sentence
      await _playNextSentence();
      return;
    }

    // Prepare word highlights for this sentence
    // Speech marks are relative to sentence text, we need to offset them
    final wordHighlights = <WordHighlight>[];
    for (final mark in audio.speechMarks) {
      if (mark.type != 'word') continue;
      // The speech marks from synthesizeSentence are relative to sentence start
      // We need to adjust them to be relative to page start for highlighting
      final pageRelativeStart =
          sentence.startIndex - page.startCharIndex + mark.start;
      final pageRelativeEnd =
          sentence.startIndex - page.startCharIndex + mark.end;

      if (pageRelativeStart >= 0 && pageRelativeEnd <= page.content.length) {
        wordHighlights.add(WordHighlight(
          start: pageRelativeStart,
          end: pageRelativeEnd,
          word: mark.value,
        ));
      }
    }

    // Initialize highlight manager for this sentence
    _highlightManager.initializeForPage(
      pageIndex: pageIndex,
      speechMarks: audio.speechMarks,
      wordHighlights: wordHighlights,
    );

    ref.read(highlightStateProvider.notifier).initializeForPage(
          pageIndex: pageIndex,
          wordHighlights: wordHighlights,
        );

    // Play using appropriate player
    if (kIsWeb && _webAudioPlayer != null) {
      try {
        await _webAudioPlayer!.setUrl(audioUrl);

        // Set up position stream for highlights
        _webPositionSubscription?.cancel();
        _webPositionSubscription =
            _webAudioPlayer!.positionStream.listen((position) {
          if (mounted) {
            _highlightManager.updatePositionManually(position);
          }
        });

        // Listen for playback completion
        _webPlayingSubscription?.cancel();
        _webPlayingSubscription =
            _webAudioPlayer!.playingStream.listen((playing) {
          if (mounted) {
            if (playing) {
              ref.read(audioStateProvider.notifier).play();
            } else {
              ref.read(audioStateProvider.notifier).pause();
            }
          }
        });

        // Listen for sentence completion
        _webAudioPlayer!.onComplete = () {
          if (mounted && _sentenceTTSActive) {
            _playNextSentence();
          }
        };

        await _webAudioPlayer!.play();

        if (kDebugMode) {
          debugPrint('   ✅ WebAudioPlayer playing sentence $sentenceIndex');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ❌ WebAudioPlayer error: $e');
        }
      }
    } else {
      // Use just_audio on native
      final audioPlayer = ref.read(audioPlayerProvider);
      try {
        await audioPlayer.setUrl(audioUrl);
        await audioPlayer.play();

        // Listen for completion
        audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed &&
              mounted &&
              _sentenceTTSActive) {
            _playNextSentence();
          }
        });

        if (kDebugMode) {
          debugPrint('   ✅ just_audio playing sentence $sentenceIndex');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ❌ just_audio error: $e');
        }
      }
    }
  }

  /// Play next sentence, or move to next page if done
  Future<void> _playNextSentence() async {
    if (!mounted || !_sentenceTTSActive) return;

    _currentSentenceIndex++;

    if (_currentSentenceIndex >= _currentPageSentences.length) {
      // All sentences on this page are done
      if (kDebugMode) {
        debugPrint('✅ Page complete, moving to next page');
      }
      _handleAudioComplete();
      return;
    }

    // Preload next page when we're near the end
    if (_sentenceTTSController != null &&
        _sentenceTTSController!.isNearPageEnd) {
      _preloadNextPageInBackground();
    }

    // Get next sentence audio
    final nextAudio = await _sentenceTTSController!.nextSentence();
    if (nextAudio != null && mounted) {
      await _playSentenceAudio(nextAudio, _currentSentenceIndex);
    } else if (mounted) {
      // Failed to get audio, try next
      if (kDebugMode) {
        debugPrint(
            '⚠️ Failed to get sentence $_currentSentenceIndex, trying next');
      }
      await _playNextSentence();
    }
  }

  /// Preload next page sentences in background for smoother transitions
  void _preloadNextPageInBackground() {
    final bookState = ref.read(bookStateNotifierProvider);
    final currentBook = bookState.currentBook;
    final currentPageIndex = bookState.currentPageIndex;
    final savedBook = bookState.savedBook;

    if (currentBook == null) return;

    final nextPageIndex = currentPageIndex + 1;
    if (nextPageIndex >= currentBook.pages.length) return;

    final nextPage = currentBook.pages[nextPageIndex];

    // Parse sentences for next page
    final nextPageSentences = SentenceParser.parse(
      text: nextPage.content,
      pageIndex: nextPageIndex,
      pageStartIndex: nextPage.startCharIndex,
      bookId: savedBook?.id ?? 'unknown',
    );

    if (nextPageSentences.isNotEmpty && _sentenceTTSController != null) {
      if (kDebugMode) {
        debugPrint(
            '⏩ Preloading ${nextPageSentences.length} sentences from page $nextPageIndex');
      }
      // Fire and forget - runs in background
      _sentenceTTSController!.preloadNextPageSentences(nextPageSentences);
    }
  }

  // ignore: unused_element - kept for potential future use
  Future<void> _playFromCache(int pageIndex) async {
    if (!mounted) return;

    final bookState = ref.read(bookStateNotifierProvider);
    final currentBook = bookState.currentBook;
    if (currentBook == null) return;

    final cachedResponse = _audioCache[pageIndex]!;
    final page = currentBook.pages[pageIndex];

    if (kDebugMode) {
      debugPrint('🎧 Playing from cache: page $pageIndex');
      debugPrint(
          '   Audio URL: ${cachedResponse.audioUrl?.substring(0, 50)}...');
    }

    Duration? actualDuration;

    // Use Web Audio Player on Web platform (just_audio doesn't work well with Blob URLs)
    if (kIsWeb && _webAudioPlayer != null) {
      try {
        debugPrint('   ⏳ Using WebAudioPlayer...');
        actualDuration =
            await _webAudioPlayer!.setUrl(cachedResponse.audioUrl!);
        debugPrint('   ✅ WebAudioPlayer loaded, duration: $actualDuration');
      } catch (e) {
        debugPrint('   ❌ WebAudioPlayer error: $e');
        return;
      }
    } else {
      // Use just_audio on native platforms
      final audioPlayer = ref.read(audioPlayerProvider);

      try {
        debugPrint('   ⏳ Using just_audio...');
        await audioPlayer.setUrl(cachedResponse.audioUrl!);
        await audioPlayer.load();
        actualDuration = audioPlayer.duration;
        debugPrint('   ✅ just_audio loaded, duration: $actualDuration');
      } catch (e) {
        debugPrint('   ❌ just_audio error: $e');
        await audioPlayer.stop();
        return;
      }
    }

    final speechMarks = cachedResponse.speechMarks;

    // Kokoro timestamps are in "base time" (same as just_audio position)
    // No calibration needed - timestamps match audio position at all playback speeds
    // Platform-specific lag is handled in HighlightManager
    if (actualDuration != null && speechMarks.isNotEmpty) {
      final lastTimestamp = speechMarks.last.time;
      final actualDurationMs = actualDuration.inMilliseconds;
      final difference = (actualDurationMs - lastTimestamp).abs();

      // Log significant duration mismatches for debugging (shouldn't happen with Kokoro)
      if (difference > 100) {
        if (kDebugMode) {
          debugPrint(
              'Duration mismatch: audio=${actualDurationMs}ms, last_timestamp=${lastTimestamp}ms, diff=${difference}ms');
        }
      }
    }

    // Map speech marks to word highlights with exact position matching
    final wordHighlights = <WordHighlight>[];
    final pageContent = page.content;

    for (final mark in speechMarks) {
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
      speechMarks: speechMarks,
      wordHighlights: wordHighlights,
    );

    // Initialize provider with word highlights for this page
    ref.read(highlightStateProvider.notifier).initializeForPage(
          pageIndex: pageIndex,
          wordHighlights: wordHighlights,
        );

    if (kDebugMode) {
      debugPrint('   ▶️ Calling play()');
    }

    // Play using appropriate player
    if (kIsWeb && _webAudioPlayer != null) {
      // Set up position stream for highlights on Web
      _webPositionSubscription?.cancel();
      int positionUpdateCount = 0;
      _webPositionSubscription =
          _webAudioPlayer!.positionStream.listen((position) {
        if (mounted) {
          positionUpdateCount++;
          if (positionUpdateCount % 20 == 1) {
            debugPrint(
                '🎯 Position update #$positionUpdateCount: ${position.inMilliseconds}ms');
          }
          _highlightManager.updatePositionManually(position);
        }
      });

      // Listen for playback completion
      _webPlayingSubscription?.cancel();
      _webPlayingSubscription =
          _webAudioPlayer!.playingStream.listen((playing) {
        if (mounted) {
          if (playing) {
            ref.read(audioStateProvider.notifier).play();
          } else {
            ref.read(audioStateProvider.notifier).pause();
          }
        }
      });

      await _webAudioPlayer!.play();

      if (kDebugMode) {
        debugPrint('   ✅ WebAudioPlayer playing');
      }
    } else {
      // Use just_audio on native
      final audioPlayer = ref.read(audioPlayerProvider);
      await audioPlayer.play();

      if (kDebugMode) {
        debugPrint('   ✅ just_audio playing: ${audioPlayer.playing}');
      }
    }

    _preloadNext2Pages();
  }

  Future<void> _preloadPageAudio(int pageIndex) async {
    if (!mounted) return;

    final bookState = ref.read(bookStateNotifierProvider);
    final currentBook = bookState.currentBook;

    if (currentBook == null || pageIndex >= currentBook.pages.length) {
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
      final page = currentBook.pages[pageIndex];
      final ttsService = ref.read(ttsServiceProvider);
      final audioState = ref.read(audioStateProvider);
      final savedBook = bookState.savedBook;

      // Text length validation (silent in production)
      if (kDebugMode && page.content.length > TTSService.maxTextLength * 0.9) {
        debugPrint(
            'Page ${pageIndex + 1} near TTS limit: ${page.content.length}/${TTSService.maxTextLength} chars');
      }

      final ttsResponse = await ttsService.synthesizeSpeech(
        page.content,
        voiceId: audioState.selectedVoice,
        speed: audioState.playbackSpeed,
        volume: _volume,
        bookId: savedBook?.id,
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

        _audioCache[pageIndex] = TtsResponse(
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
    if (!mounted) return;

    final bookState = ref.read(bookStateNotifierProvider);
    final currentBook = bookState.currentBook;
    if (currentBook == null) return;

    final currentPageIndex = bookState.currentPageIndex;
    final pagesToPreload = <int>[];
    for (int i = 1; i <= 2; i++) {
      final pageIdx = currentPageIndex + i;
      if (pageIdx < currentBook.pages.length &&
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
    if (!mounted) return;

    final bookState = ref.read(bookStateNotifierProvider);
    final currentPageIndex = bookState.currentPageIndex;
    final highlightState = ref.read(highlightStateProvider);
    final audioPlayer = ref.read(audioPlayerProvider);

    final speechMarks = highlightState.isActive
        ? _audioCache[currentPageIndex]?.speechMarks ?? []
        : [];

    if (speechMarks.isEmpty ||
        wordIndex < 0 ||
        wordIndex >= speechMarks.length) {
      return;
    }

    final mark = speechMarks[wordIndex];

    if (audioPlayer.duration == null &&
        _audioCache.containsKey(currentPageIndex)) {
      final cachedResponse = _audioCache[currentPageIndex]!;
      await audioPlayer.setUrl(cachedResponse.audioUrl!);
    }

    await audioPlayer.seek(Duration(milliseconds: mark.time.toInt()));
    audioPlayer.play();
  }

  void _stopAudio() {
    if (!mounted) return;

    // Stop sentence TTS
    _sentenceTTSActive = false;
    _sentenceTTSController?.stop();

    final audioPlayer = ref.read(audioPlayerProvider);
    final ttsService = ref.read(ttsServiceProvider);
    audioPlayer.stop();
    _highlightManager.stop();
    ttsService.cancelAllRequests();

    // Stop web audio player too
    if (kIsWeb && _webAudioPlayer != null) {
      _webAudioPlayer!.stop();
      _webAudioPlayer!.onComplete = null;
    }
  }

  /// Toggle play/pause for TTS playback
  /// Properly handles both web and native audio, plus highlighting
  void _togglePlayPause() {
    if (!mounted) return;

    final audioState = ref.read(audioStateProvider);
    final audioPlayer = ref.read(audioPlayerProvider);

    if (audioState.isPlaying) {
      // === PAUSE ===
      // Pause audio
      if (kIsWeb && _webAudioPlayer != null) {
        _webAudioPlayer!.pause();
      } else {
        audioPlayer.pause();
      }
      // Pause highlighting
      _highlightManager.pause();
      // Update state
      ref.read(audioStateProvider.notifier).pause();
    } else {
      // === PLAY/RESUME ===
      // Check if we have audio loaded
      final hasAudioLoaded = kIsWeb
          ? true // Web audio always has URL set
          : audioPlayer.duration != null;

      if (hasAudioLoaded && _sentenceTTSActive) {
        // Resume existing playback
        if (kIsWeb && _webAudioPlayer != null) {
          _webAudioPlayer!.play();
        } else {
          audioPlayer.play();
        }
        // Resume highlighting
        _highlightManager.resume();
        // Update state
        ref.read(audioStateProvider.notifier).play();
      } else {
        // Start fresh playback
        _playCurrentPage();
      }
    }
  }

  // ignore: unused_element
  Future<void> _restartPage() async {
    if (!mounted) return;

    final audioPlayer = ref.read(audioPlayerProvider);
    if (audioPlayer.duration == null) {
      await _playCurrentPage();
    } else {
      await audioPlayer.seek(Duration.zero);
      audioPlayer.play();
    }
  }

  // ignore: unused_element
  void _setVolume(double volume) {
    if (!mounted) return;
    final clampedVolume = volume.clamp(0.0, 1.0);
    ref.read(audioStateProvider.notifier).setVolume(clampedVolume);
    ref.read(audioPlayerProvider).setVolume(clampedVolume);
  }

  void _setPlaybackSpeed(double speed) {
    if (!mounted) return;
    final clampedSpeed = speed.clamp(0.25, 2.0);
    ref.read(audioStateProvider.notifier).setPlaybackSpeed(clampedSpeed);
    ref.read(audioPlayerProvider).setSpeed(clampedSpeed);
  }

  Future<void> _changeVoice(String newVoice) async {
    if (!mounted) return;

    // Capture all providers before any async operations
    final audioState = ref.read(audioStateProvider);
    if (newVoice == audioState.selectedVoice) return;

    final audioPlayer = ref.read(audioPlayerProvider);
    final ttsService = ref.read(ttsServiceProvider);
    final bookState = ref.read(bookStateNotifierProvider);
    final audioStateNotifier = ref.read(audioStateProvider.notifier);
    final currentPageIndex = bookState.currentPageIndex;

    // IMMEDIATELY stop playback when changing voice
    await audioPlayer.stop();
    _highlightManager.stop();
    audioStateNotifier.pause();

    // On web, also stop the web audio player
    if (kIsWeb) {
      await _webAudioPlayer?.stop();
    }

    audioStateNotifier.setVoice(newVoice);
    ttsService.cancelAllRequests();

    // Clear ALL cached audio - we need fresh audio with new voice
    _audioCache.clear();
    if (kDebugMode) {
      debugPrint('🔄 Voice changed to $newVoice - cleared all audio cache');
    }

    // Show loading state while regenerating
    if (!mounted) return;
    setState(() {
      _isLoadingAudio = true;
    });

    // Regenerate audio for current page with new voice
    await _preloadPageAudio(currentPageIndex);

    if (!mounted) return;
    setState(() {
      _isLoadingAudio = false;
    });
  }

  Widget _buildTableOfContentsDrawer() {
    final bookState = ref.watch(bookStateNotifierProvider);
    if (bookState.currentBook == null) return const SizedBox.shrink();

    return Drawer(
      child: Container(
        color: AppTheme.warmPaper,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: const BoxDecoration(
                color: AppTheme.espresso,
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
                    bookState.currentBook!.title,
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
                itemCount: bookState.currentBook!.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = bookState.currentBook!.chapters[index];
                  final pageIndex = bookState.currentBook!.pages.indexWhere(
                    (page) => page.chapterNumber == chapter.number,
                  );
                  final isCurrentChapter = pageIndex != -1 &&
                      bookState.currentPageIndex >= pageIndex &&
                      (bookState.currentPageIndex <
                              bookState.currentBook!.pages.length - 1 &&
                          bookState
                                  .currentBook!
                                  .pages[bookState.currentPageIndex]
                                  .chapterNumber ==
                              chapter.number);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentChapter
                          ? AppTheme.espresso
                          : AppTheme.caramel.withValues(alpha: 0.2),
                      foregroundColor: isCurrentChapter
                          ? AppTheme.warmPaper
                          : AppTheme.espresso,
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
                            ? AppTheme.espresso
                            : AppTheme.charcoal,
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
                        ref
                            .read(bookStateNotifierProvider.notifier)
                            .setCurrentPage(pageIndex);
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

  // Store audio player reference for dispose
  AudioPlayer? _audioPlayerRef;

  @override
  void deactivate() {
    // Save progress synchronously before deactivation
    _saveProgressSync();
    super.deactivate();
  }

  /// Synchronous progress save for deactivate - captures values immediately
  void _saveProgressSync() {
    if (!mounted) return;
    try {
      final bookState = ref.read(bookStateNotifierProvider);
      if (bookState.savedBook == null || bookState.currentBook == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bookId = bookState.savedBook!.id;
      final pageIndex = bookState.currentPageIndex;
      final db = ref.read(appDatabaseProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      // Fire and forget - don't await
      db.updateBookLastPage(bookId, pageIndex).catchError((e) {
        debugPrint('⚠️ Local save failed: $e');
      });

      firestoreService
          .updateReadingProgress(
        userId: user.uid,
        bookId: bookId,
        lastPageIndex: pageIndex,
      )
          .catchError((e) {
        debugPrint('☁️ Firestore sync will retry later: $e');
      });
    } catch (e) {
      debugPrint('⚠️ Progress save failed: $e');
    }
  }

  @override
  @override
  void dispose() {
    _highlightManager.dispose();
    // Use cached reference instead of ref.read
    _audioPlayerRef?.dispose();
    _progressSaveTimer?.cancel();
    _pageController.dispose();

    // Clean up sentence TTS controller
    _sentenceTTSController?.dispose();

    // Clean up web audio player
    _webPositionSubscription?.cancel();
    _webPlayingSubscription?.cancel();
    _webAudioPlayer?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookStateNotifierProvider);
    final readerSettings = ref.watch(readerSettingsNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.warmPaper,
      drawer: _buildTableOfContentsDrawer(),
      appBar: readerSettings.immersiveMode
          ? null
          : AppBar(
              title: Text(bookState.currentBook?.title ?? 'Sonant Reader'),
              backgroundColor: AppTheme.warmPaper,
              foregroundColor: AppTheme.espresso,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: AppTheme.espresso,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
              leading: bookState.currentBook != null
                  ? IconButton(
                      icon: const Icon(Icons.menu_book),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      tooltip: 'Table of Contents',
                    )
                  : null,
              actions: [
                if (bookState.currentBook != null)
                  IconButton(
                    icon: Icon(
                      readerSettings.immersiveMode
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                    ),
                    onPressed: () {
                      ref
                          .read(readerSettingsNotifierProvider.notifier)
                          .toggleImmersiveMode();
                    },
                    tooltip: readerSettings.immersiveMode
                        ? 'Exit immersive'
                        : 'Immersive reading',
                  ),
                if (bookState.currentBook != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _stopAudio();
                      _saveProgress();
                      // Turn off immersive mode if it's on
                      if (readerSettings.immersiveMode) {
                        ref
                            .read(readerSettingsNotifierProvider.notifier)
                            .toggleImmersiveMode();
                      }
                      Navigator.of(context).pop();
                    },
                    tooltip: 'Close book',
                  ),
                if (bookState.currentBook != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: _showBookInfo,
                  ),
              ],
            ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomChrome(),
      floatingActionButton: bookState.currentBook == null
          ? FloatingActionButton(
              onPressed: _pickBook,
              backgroundColor: const Color(0xFF8B4513),
              child: const Icon(Icons.menu_book, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    final bookState = ref.watch(bookStateNotifierProvider);
    final audioState = ref.watch(audioStateProvider);
    final readerSettings = ref.watch(readerSettingsNotifierProvider);

    if (bookState.isLoading) {
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

    if (bookState.currentBook == null) {
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

    final pageView = RepaintBoundary(
      child: PageView.builder(
        controller: _pageController,
        physics: audioState.isPlaying
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: bookState.currentBook!.pages.length,
        onPageChanged: (index) {
          ref.read(bookStateNotifierProvider.notifier).setCurrentPage(index);
          _highlightManager.stop();
          _saveProgress();
        },
        itemBuilder: (context, index) {
          final page = bookState.currentBook!.pages[index];
          return _buildPage(page, index);
        },
      ),
    );

    if (readerSettings.immersiveMode) {
      return Stack(
        children: [
          pageView,
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: () {
                    ref
                        .read(readerSettingsNotifierProvider.notifier)
                        .toggleImmersiveMode();
                  },
                  tooltip: 'Show navigation',
                ),
              ),
            ),
          ),
        ],
      );
    }

    return pageView;
  }

  Widget? _buildBottomChrome() {
    final bookState = ref.watch(bookStateNotifierProvider);
    final readerSettings = ref.watch(readerSettingsNotifierProvider);

    if (bookState.currentBook == null) return null;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      offset: readerSettings.immersiveMode ? const Offset(0, 1.2) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: readerSettings.immersiveMode ? 0.0 : 1.0,
        child: IgnorePointer(
          ignoring: readerSettings.immersiveMode,
          child: _buildControls(),
        ),
      ),
    );
  }

  Widget _buildPage(BookPage page, int index) {
    final bookState = ref.watch(bookStateNotifierProvider);
    final readerSettings = ref.watch(readerSettingsNotifierProvider);
    final highlightState = ref.watch(highlightStateProvider);

    final isChapterStart = index == 0 ||
        bookState.currentBook!.pages[index - 1].chapterNumber !=
            page.chapterNumber;

    return _BookPageItem(
      page: page,
      pageIndex: index,
      totalPages: bookState.currentBook!.pages.length,
      isChapterStart: isChapterStart,
      hasAudio: _audioCache.containsKey(page.pageNumber - 1),
      highlightState: highlightState,
      textStyle: _readerTextStyle(context),
      textAlign: readerSettings.useJustifyAlignment
          ? TextAlign.justify
          : TextAlign.left,
      onWordTap: (wordIndex) {
        if (wordIndex < highlightState.wordHighlights.length) {
          final localHighlight = highlightState.wordHighlights[wordIndex];
          final cachedResponse = _audioCache[bookState.currentPageIndex];
          if (cachedResponse != null) {
            final globalIndex = cachedResponse.speechMarks.indexWhere(
              (mark) =>
                  mark.start - page.startCharIndex == localHighlight.start,
            );
            if (globalIndex != -1) {
              _playFromWord(globalIndex);
            }
          }
        }
      },
    );
  }

  Widget _buildControls() {
    final bookState = ref.watch(bookStateNotifierProvider);
    final audioState = ref.watch(audioStateProvider);
    final audioPlayer = ref.read(audioPlayerProvider);

    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        // Use audioState.isPlaying for consistent state across web/native
        // This is updated by _togglePlayPause and playback handlers
        final isPlaying = audioState.isPlaying;
        final processingState = playerState?.processingState;
        final isLoading = processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering ||
            _isLoadingAudio;

        return ModernPlayerControls(
          isPlaying: isPlaying,
          isLoading: isLoading,
          hasSavedPosition: bookState.savedBook?.lastPageIndex != null &&
              bookState.savedBook!.lastPageIndex > 0,
          currentPage: bookState.currentPageIndex,
          totalPages: bookState.currentBook?.pages.length ?? 0,
          savedPage: bookState.savedBook?.lastPageIndex,
          playbackSpeed: audioState.playbackSpeed,
          onPlayPause: _togglePlayPause,
          onResume: bookState.savedBook?.lastPageIndex != null
              ? () {
                  final savedPage = bookState.savedBook!.lastPageIndex;
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(savedPage);
                    ref
                        .read(bookStateNotifierProvider.notifier)
                        .setCurrentPage(savedPage);
                    _playCurrentPage();
                  }
                }
              : null,
          onPreviousPage: bookState.currentPageIndex > 0 && !isPlaying
              ? () {
                  _stopAudio();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              : null,
          onNextPage: bookState.currentPageIndex <
                      (bookState.currentBook?.pages.length ?? 0) - 1 &&
                  !isPlaying
              ? () {
                  _stopAudio();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              : null,
          onSpeedTap: () => _showSpeedSelectorSheet(),
          onVoiceTap: () => _showVoiceSelectorSheet(),
          onSettingsTap: _showReaderSettingsSheet,
        );
      },
    );
  }

  /// Show modern speed/volume controls sheet
  void _showSpeedSelectorSheet() {
    final audioState = ref.read(audioStateProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXL),
        ),
      ),
      builder: (context) => SpeedSelectorSheet(
        currentSpeed: audioState.playbackSpeed,
        currentVolume: _volume,
        onSpeedChanged: (speed) {
          _setPlaybackSpeed(speed);
          // Also update sentence TTS controller speed
          _sentenceTTSController?.speed = speed;
        },
        onVolumeChanged: (volume) {
          setState(() => _volume = volume);
        },
      ),
    );
  }

  /// Show modern voice selector sheet
  void _showVoiceSelectorSheet() {
    final audioState = ref.read(audioStateProvider);
    final voices = [
      // 🇺🇸 American Female
      const VoiceOption(
        id: 'af_bella',
        name: 'Bella',
        description: 'Warm & Natural',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_sarah',
        name: 'Sarah',
        description: 'Clear & Professional',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_nicole',
        name: 'Nicole',
        description: '🎙️ ASMR Whisper • Soft & Relaxing',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_heart',
        name: 'Heart',
        description: 'Gentle & Caring',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_sky',
        name: 'Sky',
        description: 'Youthful & Bright',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_alloy',
        name: 'Alloy',
        description: 'Confident & Modern',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_nova',
        name: 'Nova',
        description: 'Energetic & Dynamic',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_jessica',
        name: 'Jessica',
        description: 'Friendly & Approachable',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'af_river',
        name: 'River',
        description: 'Calm & Soothing',
        locale: 'en-US',
      ),

      // 🇺🇸 American Male
      const VoiceOption(
        id: 'am_adam',
        name: 'Adam',
        description: 'Deep & Rich',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'am_michael',
        name: 'Michael',
        description: 'Clear & Friendly',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'am_echo',
        name: 'Echo',
        description: 'Smooth & Authoritative',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'am_onyx',
        name: 'Onyx',
        description: 'Deep & Cinematic',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'am_liam',
        name: 'Liam',
        description: 'Versatile & Natural',
        locale: 'en-US',
      ),
      const VoiceOption(
        id: 'am_eric',
        name: 'Eric',
        description: 'Strong & Confident',
        locale: 'en-US',
      ),

      // 🇬🇧 British Female
      const VoiceOption(
        id: 'bf_emma',
        name: 'Emma',
        description: 'Elegant & Refined',
        locale: 'en-GB',
      ),
      const VoiceOption(
        id: 'bf_alice',
        name: 'Alice',
        description: 'Sophisticated & Clear',
        locale: 'en-GB',
      ),
      const VoiceOption(
        id: 'bf_lily',
        name: 'Lily',
        description: 'Charming & Articulate',
        locale: 'en-GB',
      ),

      // 🇬🇧 British Male
      const VoiceOption(
        id: 'bm_george',
        name: 'George',
        description: 'Classic & Distinguished',
        locale: 'en-GB',
      ),
      const VoiceOption(
        id: 'bm_lewis',
        name: 'Lewis',
        description: 'Modern & Charismatic',
        locale: 'en-GB',
      ),
      const VoiceOption(
        id: 'bm_daniel',
        name: 'Daniel',
        description: 'Professional & Authoritative',
        locale: 'en-GB',
      ),
      const VoiceOption(
        id: 'bm_fable',
        name: 'Fable',
        description: 'Storytelling & Expressive',
        locale: 'en-GB',
      ),

      // 🇮🇳 Indian
      const VoiceOption(
        id: 'if_sara',
        name: 'Sara',
        description: 'Melodic & Clear',
        locale: 'en-IN',
      ),
      const VoiceOption(
        id: 'im_nicola',
        name: 'Nicola',
        description: 'Warm & Articulate',
        locale: 'en-IN',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXL),
        ),
      ),
      builder: (context) => VoiceSelectorSheet(
        currentVoice: audioState.selectedVoice,
        voices: voices,
        onVoiceChanged: (voiceId) {
          _changeVoice(voiceId);
        },
        onPreviewVoice: (voiceId) {
          _previewVoice(voiceId);
        },
      ),
    );
  }

  /// Preview a voice with a famous quote - uses SEPARATE audio player
  /// Does not affect book playback at all
  Future<void> _previewVoice(String voiceId) async {
    // Famous quote for voice preview
    const previewText =
        "You never really understand a person until you consider things from his point of view. That's what I learned.";

    final ttsService = ref.read(ttsServiceProvider);
    final audioState = ref.read(audioStateProvider);

    // Stop any existing preview
    _stopPreview();

    setState(() {
      _isPreviewPlaying = true;
    });

    try {
      final response = await ttsService.synthesizeSpeech(
        previewText,
        voiceId: voiceId,
        speed: audioState.playbackSpeed,
        volume: _volume,
      );

      if (response != null && response.audioUrl != null && mounted) {
        if (kIsWeb) {
          // Use separate preview web audio player
          _previewWebAudioPlayer ??= createWebAudioPlayer();
          _previewWebAudioPlayer!.onComplete = () {
            if (mounted) {
              setState(() => _isPreviewPlaying = false);
            }
          };
          await _previewWebAudioPlayer!.setUrl(response.audioUrl!);
          await _previewWebAudioPlayer!.play();
        } else {
          // Use separate preview native audio player
          _previewAudioPlayer ??= AudioPlayer();
          await _previewAudioPlayer!.setUrl(response.audioUrl!);
          await _previewAudioPlayer!.play();
          // Auto-stop preview when finished
          _previewAudioPlayer!.playerStateStream.listen((state) {
            if (state.processingState == ProcessingState.completed && mounted) {
              setState(() => _isPreviewPlaying = false);
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Preview voice error: $e');
      }
      setState(() {
        _isPreviewPlaying = false;
      });
    }
  }

  /// Stop voice preview without affecting book playback
  void _stopPreview() {
    if (kIsWeb) {
      _previewWebAudioPlayer?.stop();
    } else {
      _previewAudioPlayer?.stop();
    }
    if (mounted) {
      setState(() {
        _isPreviewPlaying = false;
      });
    }
  }

  void _showReaderSettingsSheet() {
    final readerSettings = ref.read(readerSettingsNotifierProvider);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        ReaderTypeface tempTypeface = readerSettings.typeface;
        double tempFontScale = readerSettings.fontScale;
        double tempLineHeight = readerSettings.lineHeightScale;
        bool tempJustify = readerSettings.useJustifyAlignment;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void updateTypefaceState(ReaderTypeface value) {
              setSheetState(() {
                tempTypeface = value;
              });
              ref
                  .read(readerSettingsNotifierProvider.notifier)
                  .setTypeface(value);
            }

            void updateFontScale(double value) {
              setSheetState(() {
                tempFontScale = value;
              });
              ref
                  .read(readerSettingsNotifierProvider.notifier)
                  .setFontScale(value);
            }

            void updateLineHeight(double value) {
              setSheetState(() {
                tempLineHeight = value;
              });
              ref
                  .read(readerSettingsNotifierProvider.notifier)
                  .setLineHeightScale(value);
            }

            void updateJustify(bool value) {
              setSheetState(() {
                tempJustify = value;
              });
              ref
                  .read(readerSettingsNotifierProvider.notifier)
                  .setJustifyAlignment(value);
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Reader settings',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setSheetState(() {
                              tempTypeface = ReaderTypeface.serif;
                              tempFontScale = 1.0;
                              tempLineHeight = 1.0;
                              tempJustify = true;
                            });
                            ref
                                .read(readerSettingsNotifierProvider.notifier)
                                .setTypeface(ReaderTypeface.serif);
                            ref
                                .read(readerSettingsNotifierProvider.notifier)
                                .setFontScale(1.0);
                            ref
                                .read(readerSettingsNotifierProvider.notifier)
                                .setLineHeightScale(1.0);
                            if (!readerSettings.useJustifyAlignment) {
                              ref
                                  .read(readerSettingsNotifierProvider.notifier)
                                  .toggleJustifyAlignment();
                            }
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Typeface',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Serif'),
                          selected: tempTypeface == ReaderTypeface.serif,
                          onSelected: (value) {
                            if (value) {
                              updateTypefaceState(ReaderTypeface.serif);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Sans'),
                          selected: tempTypeface == ReaderTypeface.sans,
                          onSelected: (value) {
                            if (value) {
                              updateTypefaceState(ReaderTypeface.sans);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Font size',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: tempFontScale,
                      min: 0.85,
                      max: 1.35,
                      label: '${(tempFontScale * 100).round()}%',
                      onChanged: (value) {
                        updateFontScale(value);
                      },
                    ),
                    Text(
                      'Line height',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: tempLineHeight,
                      min: 0.8,
                      max: 1.4,
                      label: tempLineHeight.toStringAsFixed(2),
                      onChanged: (value) {
                        updateLineHeight(value);
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Justify paragraphs'),
                      value: tempJustify,
                      onChanged: (value) {
                        updateJustify(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Fixed height preview - does not resize when adjusting settings
                    SizedBox(
                      height: 140,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            'In that moment, she realized that the beauty of reading lies not just in the words themselves, but in the quiet spaces between them where imagination takes flight.',
                            style: _readerTextStyle(
                              context,
                              typeface: tempTypeface,
                              fontScale: tempFontScale,
                              lineHeight: tempLineHeight,
                            ),
                            textAlign:
                                tempJustify ? TextAlign.justify : TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBookInfo() {
    final bookState = ref.read(bookStateNotifierProvider);
    if (bookState.currentBook == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bookState.currentBook!.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${bookState.currentBook!.author}'),
            const SizedBox(height: 8),
            Text('Format: ${bookState.currentBook!.format.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Chapters: ${bookState.currentBook!.chapters.length}'),
            const SizedBox(height: 8),
            Text('Total pages: ${bookState.currentBook!.pages.length}'),
            const SizedBox(height: 8),
            Text('Current page: ${bookState.currentPageIndex + 1}'),
            const SizedBox(height: 8),
            Text(
              'Progress: ${((bookState.currentPageIndex + 1) / bookState.currentBook!.pages.length * 100).toStringAsFixed(1)}%',
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

class _BookPageItem extends StatefulWidget {
  final BookPage page;
  final int pageIndex;
  final int totalPages;
  final bool isChapterStart;
  final bool hasAudio;
  final HighlightData highlightState;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final Function(int) onWordTap;

  const _BookPageItem({
    required this.page,
    required this.pageIndex,
    required this.totalPages,
    required this.isChapterStart,
    required this.hasAudio,
    required this.highlightState,
    required this.textStyle,
    required this.textAlign,
    required this.onWordTap,
  });

  @override
  State<_BookPageItem> createState() => _BookPageItemState();
}

class _BookPageItemState extends State<_BookPageItem> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show highlights if this page is the one currently being read/highlighted
    final showHighlights =
        widget.highlightState.currentPageIndex == widget.pageIndex;
    final highlights = showHighlights
        ? widget.highlightState.wordHighlights
        : <WordHighlight>[];
    final currentIndex =
        showHighlights ? widget.highlightState.currentWordIndex : -1;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Row(
                        key: ValueKey(
                            'chapter-${widget.page.chapterNumber}-${widget.page.pageNumber}'),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.page.chapterTitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.espresso.withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              if (widget.hasAudio)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.volume_up,
                                    size: 14,
                                    color: AppTheme.sage,
                                  ),
                                ),
                              Text(
                                'Page ${widget.page.pageNumber} / ${widget.totalPages}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppTheme.espresso.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    if (widget.isChapterStart) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              widget.page.chapterTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.espresso,
                                fontFamily: 'serif',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 2,
                              width: 100,
                              color: AppTheme.caramel,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ...widget.page.elements
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
                    RepaintBoundary(
                      child: HighlightedText(
                        text: widget.page.content,
                        highlights: highlights,
                        currentHighlightIndex: currentIndex,
                        style: widget.textStyle,
                        textAlign: widget.textAlign,
                        onWordTap: widget.onWordTap,
                        scrollController: _scrollController,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
