// lib/providers/audio/tts_service_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import '../../services/tts_service.dart';

part 'tts_service_provider.g.dart';

/// Provides a singleton TTSService instance
/// keepAlive: true ensures the HTTP client is not closed prematurely
@Riverpod(keepAlive: true)
TTSService ttsService(Ref ref) {
  final service = TTSService();

  // Cleanup only when app is fully disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
