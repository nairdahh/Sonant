// lib/screens/library_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../models/saved_book.dart';
import '../services/firestore_service.dart'; // ✅ Înapoi la Firestore
import '../services/advanced_book_parser_service.dart';
import 'updated_book_reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final FirestoreService _firestoreService =
      FirestoreService(); // ✅ Înapoi la Firestore
  final AdvancedBookParser _bookParser = AdvancedBookParser();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _testFirestore() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🧪 TESTARE FIRESTORE CONNECTION');
    debugPrint('═══════════════════════════════════════');

    final isConnected = await _firestoreService.testFirestoreConnection();

    debugPrint('═══════════════════════════════════════');

    if (!mounted) return;

    if (isConnected) {
      debugPrint('✅ ✅ ✅ FIRESTORE FUNCȚIONEAZĂ! ✅ ✅ ✅');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Firestore funcționează corect!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      debugPrint('❌ ❌ ❌ FIRESTORE NU FUNCȚIONEAZĂ! ❌ ❌ ❌');
      debugPrint('');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ Firestore Problem'),
          content: const Text(
            'Firestore nu funcționează.\n\n'
            'Verifică:\n'
            '1. Firebase Console → Firestore Database\n'
            '2. Rules → allow read, write: if true;\n'
            '3. Console browser pentru erori detaliate',
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
  }

  Future<void> _pickAndUploadBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'txt'],
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      try {
        final fileBytes = result.files.first.bytes!;
        final fileName = result.files.first.name;

        // Parsăm cartea
        final parsedBook = await _bookParser.parseBook(fileBytes, fileName);

        if (parsedBook == null) {
          throw Exception('Nu s-a putut parsa cartea');
        }

        setState(() => _uploadProgress = 0.3);

        // Extragem coperta
        final coverImage = _extractCoverImage(parsedBook);

        setState(() => _uploadProgress = 0.5);

        // Upload în Firebase
        final savedBook = await _firestoreService.addBook(
          userId: user.uid,
          title: parsedBook.title,
          author: parsedBook.author,
          format: parsedBook.format.name,
          fileBytes: fileBytes,
          fileName: fileName,
          totalPages: parsedBook.pages.length,
          coverImageBytes: coverImage,
        );

        setState(() => _uploadProgress = 1.0);

        if (savedBook != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carte adăugată: ${savedBook.title}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eroare: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() => _isUploading = false);
    }
  }

  /// Extrage prima imagine din carte pentru copertă
  dynamic _extractCoverImage(dynamic parsedBook) {
    try {
      // Căutăm prima imagine în capitole
      for (final chapter in parsedBook.chapters) {
        for (final element in chapter.elements) {
          if (element.type.toString().contains('image') &&
              element.imageData != null) {
            return element.imageData;
          }
        }
      }
    } catch (e) {
      // Ignorăm erorile, vom folosi placeholder
    }
    return null;
  }

  Future<void> _openBook(SavedBook book) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
        ),
      ),
    );

    // Download fișier din Storage
    final fileBytes = await _firestoreService.downloadBookFile(book.fileUrl);

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (fileBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nu s-a putut descărca cartea'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Navighează la reader
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdatedBookReaderScreen(
            initialFileBytes: fileBytes,
            initialFileName: '${book.title}.${book.format}',
            savedBook: book,
          ),
        ),
      );
    }
  }

  Future<void> _deleteBook(SavedBook book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge cartea?'),
        content: Text('Sigur vrei să ștergi "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteBook(user.uid, book.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carte ștearsă'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text('Biblioteca Mea'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Nu ești autentificat'))
          : StreamBuilder<List<SavedBook>>(
              stream: _firestoreService.getUserBooks(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Eroare: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _testFirestore(),
                          child: const Text('Test Firestore'),
                        ),
                      ],
                    ),
                  );
                }

                final books = snapshot.data ?? [];

                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books,
                            size: 100, color: Colors.brown[300]),
                        const SizedBox(height: 24),
                        const Text(
                          'Biblioteca ta e goală',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Apasă + pentru a adăuga o carte',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _buildBookCard(book);
                  },
                );
              },
            ),
      floatingActionButton: _isUploading
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(
                value: _uploadProgress,
                color: Colors.white,
              ),
            )
          : FloatingActionButton(
              onPressed: _pickAndUploadBook,
              backgroundColor: const Color(0xFF8B4513),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildBookCard(SavedBook book) {
    return InkWell(
      onTap: () => _openBook(book),
      onLongPress: () => _deleteBook(book),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Copertă
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: book.coverImageUrl != null
                    ? Image.network(
                        book.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderCover(),
                      )
                    : _buildPlaceholderCover(),
              ),
            ),

            // Info carte
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Progress bar
                    LinearProgressIndicator(
                      value: book.progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8B4513)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.brown[100],
      child: const Center(
        child: Icon(
          Icons.book,
          size: 60,
          color: Colors.brown,
        ),
      ),
    );
  }
}
