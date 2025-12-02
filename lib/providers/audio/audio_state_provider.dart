// lib/providers/audio/audio_state_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_state_provider.freezed.dart';
part 'audio_state_provider.g.dart';

/// Audio playback state (volume, speed, voice selection)
@freezed
class AudioStateData with _$AudioStateData {
  const factory AudioStateData({
    @Default(false) bool isPlaying,
    @Default(1.0) double volume,
    @Default(1.0) double playbackSpeed,
    @Default('af_bella') String selectedVoice,
  }) = _AudioStateData;
}

/// StateNotifier provider for audio state
@riverpod
class AudioState extends _$AudioState {
  @override
  AudioStateData build() => const AudioStateData();

  void play() => state = state.copyWith(isPlaying: true);
  void pause() => state = state.copyWith(isPlaying: false);

  void setVolume(double volume) =>
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));

  void setPlaybackSpeed(double speed) =>
    state = state.copyWith(playbackSpeed: speed.clamp(0.25, 2.0));

  void setVoice(String voice) =>
    state = state.copyWith(selectedVoice: voice);

  void toggle() => state = state.copyWith(isPlaying: !state.isPlaying);
}
