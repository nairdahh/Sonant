// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http; // NOU
import 'package:crypto/crypto.dart';
import '../models/saved_book.dart';

class FirestoreService {
  late final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Static flag to prevent repeated init logs
  static bool _initialized = false;

  FirestoreService() {
    try {
      if (kIsWeb) {
        _firestore = FirebaseFirestore.instanceFor(
          app: FirebaseFirestore.instance.app,
          databaseId: 'sonantdb',
        );

        // Settings pentru Web
        _firestore.settings = const Settings(
          persistenceEnabled: false,
        );

        // Only log once
        if (!_initialized && kDebugMode) {
          debugPrint('✅ Firestore inițializat cu database: sonantdb');
          _initialized = true;
        }
      } else {
        // Pentru mobile, poate folosi default
        _firestore = FirebaseFirestore.instance;
        if (!_initialized && kDebugMode) {
          debugPrint('✅ Firestore inițializat cu database default');
          _initialized = true;
        }
      }
    } catch (e) {
      debugPrint('❌ Eroare inițializare Firestore: $e');
      rethrow;
    }
  }

  // ============ DEBUG TEST ============

  /// Test conexiune Firestore
  Future<bool> testFirestoreConnection() async {
    try {
      debugPrint('🧪 Testare conexiune Firestore...');
      debugPrint('   Database ID: ${kIsWeb ? "sonantdb" : "(default)"}');
      debugPrint('   App Name: ${_firestore.app.name}');

      // Test simplu: citim un document inexistent (nu va da eroare, doar null)
      final testDoc =
          await _firestore.collection('_test').doc('connection_test').get();

      debugPrint(
          '   ✅ Citire testată cu succes (doc exists: ${testDoc.exists})');

      // Test scriere
      await _firestore.collection('_test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'connection test',
      }, SetOptions(merge: true));

      debugPrint('   ✅ Scriere testată cu succes');

      final verifyDoc =
          await _firestore.collection('_test').doc('connection_test').get();

      if (verifyDoc.exists) {
        debugPrint('   ✅ Verificare reușită: ${verifyDoc.data()}');

        await _firestore.collection('_test').doc('connection_test').delete();

        return true;
      } else {
        debugPrint('   ❌ Document-ul nu a fost salvat');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Test Firestore eșuat: $e');

      final stackString = stackTrace.toString();
      final maxLength = stackString.length < 500 ? stackString.length : 500;
      debugPrint('Stack: ${stackString.substring(0, maxLength)}...');

      if (e.toString().contains('permission-denied')) {
        debugPrint('');
        debugPrint('⚠️ PERMISSION DENIED - Verifică regulile Firestore!');
        debugPrint('Database: sonantdb');
        debugPrint('Path: /databases/sonantdb/documents');
      }

      return false;
    }
  }

  // ============ BOOKS CRUD ============

  /// Adaugă o carte nouă în biblioteca user-ului
  Future<SavedBook?> addBook({
    required String userId,
    required String title,
    required String author,
    required String format,
    required Uint8List fileBytes,
    required String fileName,
    required int totalPages,
    Uint8List? coverImageBytes,
  }) async {
    try {
      final bookId = _uuid.v4();

      debugPrint('📚 Adăugăm carte: $title');
      debugPrint('   User ID: $userId');
      debugPrint('   Book ID: $bookId');

      debugPrint('   Upload fișier în Storage...');
      final fileRef =
          _storage.ref().child('users/$userId/books/$bookId/$fileName');
      final uploadTask = await fileRef.putData(
        fileBytes,
        SettableMetadata(contentType: _getContentType(format)),
      );
      final fileUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('   ✅ Fișier uploadat: $fileUrl');

      // Compute content hash for cache invalidation
      final contentHash = sha256.convert(fileBytes).toString();
      debugPrint('   📝 Content hash: $contentHash');

      String? coverImageUrl;
      if (coverImageBytes != null) {
        debugPrint('   Upload copertă...');
        final coverRef =
            _storage.ref().child('users/$userId/books/$bookId/cover.jpg');
        final coverUploadTask = await coverRef.putData(
          coverImageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        coverImageUrl = await coverUploadTask.ref.getDownloadURL();
        debugPrint('   ✅ Copertă uploadată: $coverImageUrl');
      }

      // 3. Salvează metadata în Firestore
      debugPrint('   Salvare metadata în Firestore...');
      final book = SavedBook(
        id: bookId,
        userId: userId,
        title: title,
        author: author,
        format: format,
        coverImageUrl: coverImageUrl,
        fileUrl: fileUrl,
        lastPageIndex: 0,
        totalPages: totalPages,
        lastReadAt: DateTime.now(),
        addedAt: DateTime.now(),
        contentHash: contentHash,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(bookId)
          .set(book.toMap());

      debugPrint('   ✅ Metadata salvată în Firestore');
      debugPrint('📚 Carte adăugată cu succes!');

      return book;
    } catch (e, stackTrace) {
      debugPrint('❌ Eroare la adăugarea cărții: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Obține toate cărțile unui user
  Stream<List<SavedBook>> getUserBooks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .orderBy('lastReadAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SavedBook.fromMap(doc.data())).toList());
  }

  /// Actualizează progresul de citire
  Future<void> updateReadingProgress({
    required String userId,
    required String bookId,
    required int lastPageIndex,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(bookId)
          .update({
        'lastPageIndex': lastPageIndex,
        'lastReadAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Eroare la actualizarea progresului: $e');
    }
  }

  /// Șterge o carte
  Future<void> deleteBook(String userId, String bookId) async {
    try {
      // 1. Șterge fișierele din Storage
      final bookRef = _storage.ref().child('users/$userId/books/$bookId');
      final files = await bookRef.listAll();
      for (final file in files.items) {
        await file.delete();
      }

      // 2. Șterge metadata din Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(bookId)
          .delete();
    } catch (e) {
      debugPrint('Eroare la ștergerea cărții: $e');
    }
  }

  /// Obține o carte după ID
  Future<SavedBook?> getBook(String userId, String bookId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(bookId)
          .get();

      if (doc.exists) {
        return SavedBook.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Eroare la obținerea cărții: $e');
      return null;
    }
  }

  /// Download fișier carte din Storage
  Future<Uint8List?> downloadBookFile(String fileUrl) async {
    try {
      debugPrint('📥 Descărcăm carte din: $fileUrl');

      if (kIsWeb) {
        // Pentru Web, folosim HTTP fetch direct
        debugPrint('   Folosim HTTP fetch pentru Web...');

        // Import necesar: dart:html (doar pentru Web)
        // Dar să evităm asta și să folosim un workaround

        // Alternativ, folosim getData cu maxSize mai mare
        final ref = _storage.refFromURL(fileUrl);
        debugPrint('   Ref path: ${ref.fullPath}');

        // Specificăm maxSize explicit (100MB)
        const maxSize = 100 * 1024 * 1024; // 100MB
        final data = await ref.getData(maxSize);

        if (data != null) {
          debugPrint('   ✅ Carte descărcată: ${data.length} bytes');
          return data;
        } else {
          debugPrint('   ❌ getData() a returnat null');

          // Fallback: Încercăm download direct prin URL
          debugPrint('   Încercăm download HTTP direct...');
          return await _downloadViaHttp(fileUrl);
        }
      } else {
        // Pentru mobile, getData() funcționează normal
        final ref = _storage.refFromURL(fileUrl);
        final data = await ref.getData();

        if (data != null) {
          debugPrint('   ✅ Carte descărcată: ${data.length} bytes');
        }

        return data;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Eroare la descărcarea fișierului: $e');
      debugPrint('   URL: $fileUrl');

      final stackString = stackTrace.toString();
      final maxLength = stackString.length < 300 ? stackString.length : 300;
      debugPrint('   Stack: ${stackString.substring(0, maxLength)}');

      // Încercăm fallback la HTTP
      if (kIsWeb) {
        debugPrint('   Încercăm fallback la HTTP...');
        try {
          return await _downloadViaHttp(fileUrl);
        } catch (e2) {
          debugPrint('   ❌ Fallback HTTP eșuat: $e2');
        }
      }

      return null;
    }
  }

  /// Download fișier prin HTTP (pentru Web)
  Future<Uint8List?> _downloadViaHttp(String url) async {
    try {
      debugPrint('   📡 HTTP download: $url');

      // Folosim package http pentru download
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        debugPrint(
            '   ✅ HTTP download reușit: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        debugPrint('   ❌ HTTP status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('   ❌ HTTP download error: $e');
      return null;
    }
  }

  // ============ HELPERS ============

  String _getContentType(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return 'application/epub+zip';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
