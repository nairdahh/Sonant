// lib/screens/library_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/app_database.dart';
import '../models/saved_book.dart';
import '../models/user_profile.dart';
import '../providers/database_provider.dart';
import '../services/firestore_service.dart';
import '../services/sync_service.dart';
import '../services/user_service.dart';
import '../services/advanced_book_parser_service.dart';
import '../services/book_cache_service.dart';
import '../services/persistent_cache_service.dart';
import '../theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/loading_dialog.dart';
import 'updated_book_reader_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  final AdvancedBookParser _bookParser = AdvancedBookParser();
  final BookCacheService _cacheService = BookCacheService();
  // ignore: prefer_final_fields
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Trigger initial sync from Firestore when screen loads
    _syncFromFirestore();
  }

  /// Sync books from Firestore to local Drift database
  Future<void> _syncFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Use FirestoreService stream to get books (more reliable)
      final books = await _firestoreService.getUserBooks(user.uid).first;
      debugPrint('📚 FirestoreService found ${books.length} books');

      if (books.isNotEmpty) {
        final db = ref.read(appDatabaseProvider);
        for (final book in books) {
          debugPrint('   📖 Syncing: ${book.title}');
          final entry = SavedBookEntry(
            id: book.id,
            userId: book.userId,
            title: book.title,
            author: book.author,
            format: book.format,
            fileUrl: book.fileUrl,
            totalPages: book.totalPages,
            coverImageUrl: book.coverImageUrl,
            lastPageIndex: book.lastPageIndex,
            contentHash: book.contentHash,
            lastReadAt: book.lastReadAt,
            addedAt: book.addedAt,
            syncedWithFirestore: true,
            lastSyncedAt: DateTime.now(),
          );
          await db.upsertBook(entry);
        }
        debugPrint('✅ Synced ${books.length} books to Drift');
      }
    } catch (e) {
      debugPrint('Initial sync failed: $e');
    }
  }

  Future<void> _testFirestore() async {
    // ... (existing implementation)
    final isConnected = await _firestoreService.testFirestoreConnection();
    if (!mounted) return;
    if (isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Firestore Connected'),
            backgroundColor: AppTheme.sage),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❌ Firestore Disconnected'),
            backgroundColor: AppTheme.clay),
      );
    }
  }

  Future<void> _showCacheManagement() async {
    // ... (existing implementation, updated colors)
    final stats = await _cacheService.getCacheStats();
    final persistentCache = PersistentCacheService();
    final audioSize = await persistentCache.getTotalAudioSize();
    final audioSizeMB = (audioSize / (1024 * 1024)).toStringAsFixed(2);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.softCream,
        title: Row(
          children: [
            const Icon(Icons.storage, color: AppTheme.espresso),
            const SizedBox(width: 8),
            Text('Storage', style: AppTheme.themeData.textTheme.titleLarge),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Book Cache',
                  style: AppTheme.themeData.textTheme.labelLarge
                      ?.copyWith(color: AppTheme.espresso)),
              const SizedBox(height: 8),
              _buildStatRow('Total Size', '${stats['totalSizeMB']} MB'),
              _buildStatRow('Books Cached', '${stats['bookCount']}'),
              const SizedBox(height: 16),
              Text('Audio Cache',
                  style: AppTheme.themeData.textTheme.labelLarge
                      ?.copyWith(color: AppTheme.espresso)),
              const SizedBox(height: 8),
              _buildStatRow('Audio Size', '$audioSizeMB MB'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCache();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.clay),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.themeData.textTheme.bodyMedium),
          Text(value,
              style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: AppTheme.caramel)),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    // ... (existing implementation)
    try {
      await _cacheService.clearAllCache();
      final persistentCache = PersistentCacheService();
      await persistentCache.clearAudioCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cache cleared'), backgroundColor: AppTheme.sage),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  // ignore: unused_element
  Future<void> _invalidateBookCache(SavedBook book) async {
    // ... (existing implementation)
    final fileName = '${book.title}.${book.format}';
    await _cacheService.invalidateBook(
        bookId: book.id, originalFileName: fileName);
  }

  Future<void> _pickAndUploadBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'txt'],
    );

    if (result != null && result.files.first.bytes != null) {
      if (!mounted) return;

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

      try {
        final fileBytes = result.files.first.bytes!;
        final fileName = result.files.first.name;

        // Parse book with progress callback
        final parsedBook = await _bookParser.parseBook(
          fileBytes,
          fileName,
          onProgress: (progress, status) {
            dialogController.update(
              title: 'Loading Book',
              message: status,
              progress: progress * 0.7, // 70% for parsing
            );
          },
        );

        if (parsedBook == null) throw Exception('Failed to parse book');

        dialogController.update(
          title: 'Saving Book',
          message: 'Uploading to cloud...',
          progress: 0.8,
        );

        final coverImage = _extractCoverImage(parsedBook);

        // Use HybridBookService for local-first + cloud sync
        final hybridService = ref.read(hybridBookServiceProvider);
        await hybridService.addBook(
          userId: user.uid,
          title: parsedBook.title,
          author: parsedBook.author,
          format: parsedBook.format.name,
          fileBytes: fileBytes,
          fileName: fileName,
          totalPages: parsedBook.pages.length,
          coverImageBytes: coverImage,
        );

        dialogController.update(
          title: 'Done!',
          message: '${parsedBook.title} added successfully',
          progress: 1.0,
        );

        // Brief delay to show completion
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.clay,
            ),
          );
        }
      }
    }
  }

  dynamic _extractCoverImage(dynamic parsedBook) {
    // ... (existing implementation)
    try {
      for (final chapter in parsedBook.chapters) {
        for (final element in chapter.elements) {
          if (element.type.toString().contains('image') &&
              element.imageData != null) {
            return element.imageData;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading book cover: $e');
    }
    return null;
  }

  Future<void> _openBook(SavedBook book) async {
    if (!mounted) return;

    final fileName = '${book.title}.${book.format}';

    // Check cache FIRST before showing loading
    final cachedBytes = await _cacheService.loadBookFromCache(
      bookId: book.id,
      originalFileName: fileName,
    );

    if (cachedBytes != null) {
      // Instant open from cache - no loading dialog needed
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdatedBookReaderScreen(
            initialFileBytes: cachedBytes,
            initialFileName: fileName,
            savedBook: book,
          ),
        ),
      );
      return;
    }

    // Only show loading dialog when actually downloading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.caramel),
      ),
    );

    try {
      // Download from Firebase
      final downloadedBytes =
          await _firestoreService.downloadBookFile(book.fileUrl);
      if (downloadedBytes == null) throw Exception('Download failed');

      // Save to cache for next time
      await _cacheService.saveBookToCache(
        bookId: book.id,
        originalFileName: fileName,
        fileBytes: downloadedBytes,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdatedBookReaderScreen(
            initialFileBytes: downloadedBytes,
            initialFileName: fileName,
            savedBook: book,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.clay),
        );
      }
    }
  }

  Future<void> _deleteBook(SavedBook book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Use HybridBookService for local-first deletion
    final hybridService = ref.read(hybridBookServiceProvider);
    await hybridService.deleteBook(user.uid, book.id);
  }

  Widget _buildUserMenu(UserProfile? profile) {
    final initials = _initialsForProfile(profile);
    return PopupMenuButton<String>(
      offset: const Offset(0, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.softCream,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.caramel,
        foregroundColor: AppTheme.warmPaper,
        child: Text(initials,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text('Hello, ${profile?.displayName ?? "Reader"}',
              style: AppTheme.themeData.textTheme.titleSmall),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'cache', child: Text('Storage')),
        const PopupMenuItem(
            value: 'logout',
            child: Text('Logout', style: TextStyle(color: AppTheme.clay))),
      ],
      onSelected: (value) {
        if (value == 'settings') _showSettings();
        if (value == 'cache') _showCacheManagement();
        if (value == 'logout') FirebaseAuth.instance.signOut();
      },
    );
  }

  String _initialsForProfile(UserProfile? profile) {
    // ... (existing implementation)
    final displayName = profile?.displayName.trim() ?? '';
    if (displayName.isEmpty) return 'SR';
    return displayName.substring(0, 1).toUpperCase();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.softCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTheme.themeData.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Consumer(builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              final isDark = mode == ThemeMode.dark;
              return ListTile(
                leading: const Icon(Icons.dark_mode_outlined,
                    color: AppTheme.espresso),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                  activeThumbColor: AppTheme.caramel,
                ),
              );
            }),
            ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: AppTheme.espresso),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.espresso),
              title: const Text('Language'),
              trailing: const Text('English'),
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showBookOptions(SavedBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXL),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                book.title,
                style: AppTheme.themeData.textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.author}',
              style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _BookOptionTile(
              icon: Icons.play_arrow_rounded,
              title: 'Continue Reading',
              subtitle: book.lastPageIndex > 0
                  ? 'Page ${book.lastPageIndex + 1} of ${book.totalPages}'
                  : 'Start from beginning',
              onTap: () {
                Navigator.pop(context);
                _openBook(book);
              },
            ),
            _BookOptionTile(
              icon: Icons.info_outline,
              title: 'Book Details',
              onTap: () {
                Navigator.pop(context);
                _showBookDetails(book);
              },
            ),
            const Divider(height: 1),
            _BookOptionTile(
              icon: Icons.delete_outline,
              title: 'Remove from Library',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(book);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBookDetails(SavedBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXL),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                book.title,
                style: AppTheme.themeData.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'by ${book.author}',
                style: AppTheme.themeData.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'Format', value: book.format.toUpperCase()),
              _DetailRow(label: 'Total Pages', value: '${book.totalPages}'),
              _DetailRow(
                label: 'Progress',
                value: '${book.progressPercentage.toStringAsFixed(1)}%',
              ),
              _DetailRow(
                label: 'Added',
                value: _formatDate(book.addedAt),
              ),
              _DetailRow(
                label: 'Last Read',
                value: _formatDate(book.lastReadAt),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(SavedBook book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        title: const Text('Remove Book?'),
        content: Text(
          'Are you sure you want to remove "${book.title}" from your library? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteBook(book);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    if (_isUploading) {
      return const FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: AppTheme.primary,
        label: Text('Uploading...',
            style: TextStyle(color: AppTheme.textOnPrimary)),
        icon: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return FloatingActionButton.extended(
      onPressed: _pickAndUploadBook,
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.textOnPrimary,
      icon: const Icon(Icons.add),
      label: const Text('Add Book'),
    );
  }

  int _shelfColumnsForWidth(double width) {
    // Compact web layout: more columns to keep cards smaller
    if (width > 1200) return 10; // Was 8
    if (width > 800) return 8; // Was 6
    if (width > 600) return 6; // Was 4
    return 4; // Mobile (was 3)
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Use theme background to respect light/dark mode
      // backgroundColor: AppTheme.warmPaper,
      floatingActionButton: _buildFloatingActionButton(Theme.of(context)),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please sign in'))
            : _buildLibraryContent(user),
      ),
    );
  }

  /// Build library content using Drift local database with Firestore fallback
  Widget _buildLibraryContent(User user) {
    // Watch local Drift database for books
    final booksAsync = ref.watch(userBooksStreamProvider(user.uid));

    // Also watch sync status
    final syncStatus = ref.watch(syncStatusProvider);

    return booksAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.caramel)),
      error: (error, stack) {
        // Fallback to Firestore if Drift fails
        debugPrint('Drift error, falling back to Firestore: $error');
        return _buildFirestoreFallback(user);
      },
      data: (driftBooks) {
        // Convert SavedBookEntry to SavedBook for compatibility
        final books = driftBooks.map(_convertToSavedBook).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = _shelfColumnsForWidth(constraints.maxWidth);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: StreamBuilder<UserProfile?>(
                      stream: _userService.watchUserProfile(user.uid),
                      builder: (context, profileSnapshot) {
                        return _LibraryHeader(
                          profile: profileSnapshot.data,
                          bookCount: books.length,
                          onCachePressed: _showCacheManagement,
                          onTestFirestore: _testFirestore,
                          userMenuBuilder: _buildUserMenu,
                          syncStatus: syncStatus.valueOrNull,
                        );
                      },
                    ),
                  ),
                ),
                if (books.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ShelfEmptyState(onAddBook: _pickAndUploadBook),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 24,
                      childCount: books.length,
                      itemBuilder: (context, index) {
                        return _buildBookCard(books[index])
                            .animate(delay: (50 * index).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Fallback to Firestore stream if Drift fails
  Widget _buildFirestoreFallback(User user) {
    return StreamBuilder<List<SavedBook>>(
      stream: _firestoreService.getUserBooks(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.caramel));
        }

        final books = snapshot.data ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = _shelfColumnsForWidth(constraints.maxWidth);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: StreamBuilder<UserProfile?>(
                      stream: _userService.watchUserProfile(user.uid),
                      builder: (context, profileSnapshot) {
                        return _LibraryHeader(
                          profile: profileSnapshot.data,
                          bookCount: books.length,
                          onCachePressed: _showCacheManagement,
                          onTestFirestore: _testFirestore,
                          userMenuBuilder: _buildUserMenu,
                          syncStatus: null,
                        );
                      },
                    ),
                  ),
                ),
                if (books.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ShelfEmptyState(onAddBook: _pickAndUploadBook),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 24,
                      childCount: books.length,
                      itemBuilder: (context, index) {
                        return _buildBookCard(books[index])
                            .animate(delay: (50 * index).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Convert SavedBookEntry (Drift) to SavedBook (existing model)
  SavedBook _convertToSavedBook(SavedBookEntry entry) {
    return SavedBook(
      id: entry.id,
      userId: entry.userId,
      title: entry.title,
      author: entry.author ?? 'Unknown',
      format: entry.format,
      coverImageUrl: entry.coverImageUrl,
      fileUrl: entry.fileUrl ?? '',
      lastPageIndex: entry.lastPageIndex,
      totalPages: entry.totalPages,
      lastReadAt: entry.lastReadAt ?? DateTime.now(),
      addedAt: entry.addedAt,
      contentHash: entry.contentHash,
    );
  }

  Widget _buildBookCard(SavedBook book) {
    return GestureDetector(
      onTap: () => _openBook(book),
      onLongPress: () => _showBookOptions(book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Book Cover Effect
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.espresso.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(6, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Cover Image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      child: book.coverImageUrl != null
                          ? Image.network(
                              book.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderCover(book),
                            )
                          : _buildPlaceholderCover(book),
                    ),
                  ),
                  // Spine Shadow Overlay (Left side)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            style: AppTheme.themeData.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(
              color: AppTheme.charcoal.withValues(alpha: 0.7),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _ReadingProgressBar(progress: book.progressPercentage),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(SavedBook book) {
    return Container(
      color: AppTheme.warmPaper,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.espresso,
            ),
          ),
          Icon(
            Icons.book,
            size: 32,
            color: AppTheme.espresso.withValues(alpha: 0.2),
          ),
          Text(
            'by: ${book.author}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.espresso.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.profile,
    required this.bookCount,
    required this.onCachePressed,
    required this.onTestFirestore,
    required this.userMenuBuilder,
    this.syncStatus,
  });

  final UserProfile? profile;
  final int bookCount;
  final VoidCallback onCachePressed;
  final VoidCallback onTestFirestore;
  final Widget Function(UserProfile? profile) userMenuBuilder;
  final SyncStatus? syncStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTheme.themeData.textTheme.displayMedium?.copyWith(
                  fontSize: 32,
                  color: AppTheme.primary,
                ),
                children: [
                  const TextSpan(
                    text: 'Good evening, ',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: profile?.displayName ?? 'Reader',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$bookCount stories waiting.',
                  style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.normal,
                  ),
                ),
                if (syncStatus == SyncStatus.syncing) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.caramel,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        userMenuBuilder(profile),
      ],
    );
  }
}

class _ShelfEmptyState extends StatelessWidget {
  const _ShelfEmptyState({required this.onAddBook});
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_books_outlined,
              size: 64, color: AppTheme.espresso.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Your shelves are empty',
              style: AppTheme.themeData.textTheme.titleLarge),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddBook,
            icon: const Icon(Icons.add),
            label: const Text('Add First Book'),
          ),
        ],
      ),
    );
  }
}

class _ReadingProgressBar extends StatelessWidget {
  const _ReadingProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final normalized = (progress / 100).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: normalized,
        backgroundColor: AppTheme.espresso.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.caramel),
        minHeight: 4,
      ),
    );
  }
}

/// A styled option tile for book actions
class _BookOptionTile extends StatelessWidget {
  const _BookOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.error : AppTheme.textPrimary;
    final iconColor = isDestructive ? AppTheme.error : AppTheme.textSecondary;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// A row for displaying book details
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
