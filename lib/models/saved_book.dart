// lib/models/saved_book.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SavedBook {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String format;
  final String? coverImageUrl; // URL imagine copertă din Storage
  final String fileUrl; // URL fișier din Storage
  final int lastPageIndex;
  final int totalPages;
  final DateTime lastReadAt;
  final DateTime addedAt;

  SavedBook({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.format,
    this.coverImageUrl,
    required this.fileUrl,
    this.lastPageIndex = 0,
    required this.totalPages,
    required this.lastReadAt,
    required this.addedAt,
  });

  double get progressPercentage {
    if (totalPages == 0) return 0;
    return (lastPageIndex / totalPages) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'author': author,
      'format': format,
      'coverImageUrl': coverImageUrl,
      'fileUrl': fileUrl,
      'lastPageIndex': lastPageIndex,
      'totalPages': totalPages,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory SavedBook.fromMap(Map<String, dynamic> map) {
    return SavedBook(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Untitled',
      author: map['author'] ?? 'Unknown',
      format: map['format'] ?? 'epub',
      coverImageUrl: map['coverImageUrl'],
      fileUrl: map['fileUrl'] ?? '',
      lastPageIndex: map['lastPageIndex'] ?? 0,
      totalPages: map['totalPages'] ?? 0,
      lastReadAt: (map['lastReadAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  SavedBook copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    String? format,
    String? coverImageUrl,
    String? fileUrl,
    int? lastPageIndex,
    int? totalPages,
    DateTime? lastReadAt,
    DateTime? addedAt,
  }) {
    return SavedBook(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      totalPages: totalPages ?? this.totalPages,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
