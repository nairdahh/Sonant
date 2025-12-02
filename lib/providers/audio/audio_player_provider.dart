// lib/providers/audio/audio_player_provider.dart

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'audio_player_provider.g.dart';

/// Provides a singleton AudioPlayer instance
@riverpod
AudioPlayer audioPlayer(Ref ref) {
  final player = AudioPlayer();

  // Cleanup when provider is disposed
  ref.onDispose(() {
    player.dispose();
  });

  return player;
}
