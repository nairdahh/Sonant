// lib/providers/services/firestore_service_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import '../../services/firestore_service.dart';

part 'firestore_service_provider.g.dart';

/// Provides a singleton FirestoreService instance
@riverpod
FirestoreService firestoreService(Ref ref) {
  return FirestoreService();
}
