// lib/providers/services/book_parser_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import '../../services/advanced_book_parser_service.dart';

part 'book_parser_provider.g.dart';

/// Provides a singleton AdvancedBookParser instance
@riverpod
AdvancedBookParser bookParser(Ref ref) {
  return AdvancedBookParser();
}
