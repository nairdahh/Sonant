// test/providers/audio_state_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sonant/providers/audio/audio_state_provider.dart';

void main() {
  group('AudioState Provider', () {
    test('should initialize with default values', () {
      final container = ProviderContainer();
      final state = container.read(audioStateProvider);

      expect(state.isPlaying, false);
      expect(state.volume, 1.0);
      expect(state.playbackSpeed, 1.0);
      expect(state.selectedVoice, 'af_bella');
    });

    test('should toggle play state', () {
      final container = ProviderContainer();

      // Play
      container.read(audioStateProvider.notifier).play();
      expect(container.read(audioStateProvider).isPlaying, true);

      // Pause
      container.read(audioStateProvider.notifier).pause();
      expect(container.read(audioStateProvider).isPlaying, false);
    });

    test('should set volume with clamping', () {
      final container = ProviderContainer();

      // Valid volume
      container.read(audioStateProvider.notifier).setVolume(0.5);
      expect(container.read(audioStateProvider).volume, 0.5);

      // Clamp to max
      container.read(audioStateProvider.notifier).setVolume(2.0);
      expect(container.read(audioStateProvider).volume, 1.0);

      // Clamp to min
      container.read(audioStateProvider.notifier).setVolume(-1.0);
      expect(container.read(audioStateProvider).volume, 0.0);
    });

    test('should set playback speed with clamping', () {
      final container = ProviderContainer();

      // Valid speed
      container.read(audioStateProvider.notifier).setPlaybackSpeed(1.5);
      expect(container.read(audioStateProvider).playbackSpeed, 1.5);

      // Clamp to max
      container.read(audioStateProvider.notifier).setPlaybackSpeed(3.0);
      expect(container.read(audioStateProvider).playbackSpeed, 2.0);

      // Clamp to min
      container.read(audioStateProvider.notifier).setPlaybackSpeed(0.1);
      expect(container.read(audioStateProvider).playbackSpeed, 0.25);
    });

    test('should set voice selection', () {
      final container = ProviderContainer();

      container.read(audioStateProvider.notifier).setVoice('en_male');
      expect(container.read(audioStateProvider).selectedVoice, 'en_male');
    });

    test('should toggle play state', () {
      final container = ProviderContainer();

      expect(container.read(audioStateProvider).isPlaying, false);

      container.read(audioStateProvider.notifier).toggle();
      expect(container.read(audioStateProvider).isPlaying, true);

      container.read(audioStateProvider.notifier).toggle();
      expect(container.read(audioStateProvider).isPlaying, false);
    });
  });
}
