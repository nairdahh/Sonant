// lib/utils/web_audio_player_stub.dart
// Stub implementation for non-web platforms

import 'dart:async';

class WebAudioPlayer {
  WebAudioPlayer();

  /// Callback when audio completes
  void Function()? onComplete;

  Future<Duration?> setUrl(String url) async => null;
  Future<void> play() async {}
  Future<void> pause() async {}
  Future<void> stop() async {}
  Future<void> seek(Duration position) async {}
  Future<void> setSpeed(double speed) async {}
  Duration? get duration => null;
  Stream<Duration> get positionStream => const Stream.empty();
  Stream<bool> get playingStream => const Stream.empty();
  void dispose() {}
}

/// Factory function to create WebAudioPlayer
WebAudioPlayer createWebAudioPlayer() => WebAudioPlayer();
