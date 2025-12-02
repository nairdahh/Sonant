// lib/services/sync_service_interface.dart
//
// Platform-agnostic sync service interface.

import 'dart:async';

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final bool skipped;

  SyncResult({
    required this.synced,
    required this.failed,
    required this.skipped,
  });

  bool get hasErrors => failed > 0;
  bool get isSuccess => !hasErrors && !skipped;
}

/// Abstract sync service interface
abstract class SyncServiceInterface {
  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatus;

  /// Whether this is a no-op service (used on Web)
  bool get isNoOp;

  /// Start periodic sync
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)});

  /// Stop periodic sync
  void stopPeriodicSync();

  /// Process all pending sync operations
  Future<SyncResult> syncPendingOperations();

  /// Pull latest data from Firestore
  Future<void> pullFromFirestore(String userId);

  /// Dispose resources
  void dispose();
}
