// lib/widgets/audio_controls_widget.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio/audio_state_provider.dart';
import '../providers/audio/audio_player_provider.dart';

/// Widget pentru controlul audio playback-ului cu Riverpod state management.
///
/// Afișează controale pentru:
/// - Play/Pause/Restart audio
/// - Navigare între pagini (Previous/Next)
/// - Selecție voce TTS
/// - Control volum și viteză
/// - Progress indicator pentru generare audio
/// - Error handling cu retry
class AudioControlsWidget extends ConsumerWidget {
  final bool isLoadingAudio;
  final String? lastError;
  final double ttsProgress;
  final int currentPageIndex;
  final int totalPages;
  final VoidCallback onPlayCurrentPage;
  final VoidCallback onRestartPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onShowVolumeControl;
  final VoidCallback onShowSpeedControl;
  final VoidCallback onRetryError;

  const AudioControlsWidget({
    super.key,
    required this.isLoadingAudio,
    required this.lastError,
    required this.ttsProgress,
    required this.currentPageIndex,
    required this.totalPages,
    required this.onPlayCurrentPage,
    required this.onRestartPage,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onShowVolumeControl,
    required this.onShowSpeedControl,
    required this.onRetryError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoadingAudio) _buildLoadingIndicator(),
          if (lastError != null) _buildErrorWidget(context),
          _buildMainControls(audioState, audioPlayer),
          const SizedBox(height: 12),
          _buildSecondaryControls(audioState, ref),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: LinearProgressIndicator(
              value: ttsProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generating audio... ${(ttsProgress * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lastError!,
                style: TextStyle(fontSize: 12, color: Colors.red[900]),
              ),
            ),
            TextButton(
              onPressed: onRetryError,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainControls(AudioStateData audioState, AudioPlayer audioPlayer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 32,
            color: (currentPageIndex > 0 && !audioState.isPlaying) ? null : Colors.grey[300],
          ),
          onPressed: (currentPageIndex > 0 && !audioState.isPlaying) ? onPreviousPage : null,
          tooltip: 'Previous page',
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restart_alt, size: 28),
              onPressed: audioPlayer.duration != null ? onRestartPage : null,
              tooltip: 'Restart',
            ),
            Text(
              'Restart',
              style: TextStyle(
                fontSize: 10,
                color: audioPlayer.duration != null ? Colors.black54 : Colors.grey[300],
              ),
            ),
          ],
        ),
        StreamBuilder<PlayerState>(
          stream: audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final isPlaying = playerState?.playing ?? false;
            final processingState = playerState?.processingState;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const CircularProgressIndicator();
            }

            return IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 56,
                color: const Color(0xFF8B4513),
              ),
              onPressed: () {
                if (isPlaying) {
                  audioPlayer.pause();
                } else {
                  if (audioPlayer.duration == null) {
                    onPlayCurrentPage();
                  } else {
                    audioPlayer.play();
                  }
                }
              },
              tooltip: isPlaying ? 'Pause' : 'Play',
            );
          },
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 28),
              onPressed: isLoadingAudio ? null : onPlayCurrentPage,
              tooltip: 'Read page',
            ),
            Text(
              'Read from\nhere',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: isLoadingAudio ? Colors.grey[300] : Colors.black54,
                height: 1.1,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            size: 32,
            color: (currentPageIndex < totalPages - 1 && !audioState.isPlaying) ? null : Colors.grey[300],
          ),
          onPressed: (currentPageIndex < totalPages - 1 && !audioState.isPlaying) ? onNextPage : null,
          tooltip: 'Next page',
        ),
      ],
    );
  }

  Widget _buildSecondaryControls(AudioStateData audioState, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.record_voice_over, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: audioState.selectedVoice,
                underline: Container(),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                items: const [
                  DropdownMenuItem(value: 'af_bella', child: Text('Bella (US) ♀ ⭐')),
                  DropdownMenuItem(value: 'af_sarah', child: Text('Sarah (US) ♀')),
                  DropdownMenuItem(value: 'af_nicole', child: Text('Nicole (US) ♀')),
                  DropdownMenuItem(value: 'af_sky', child: Text('Sky (US) ♀')),
                  DropdownMenuItem(value: 'am_adam', child: Text('Adam (US) ♂')),
                  DropdownMenuItem(value: 'am_michael', child: Text('Michael (US) ♂')),
                  DropdownMenuItem(value: 'bf_emma', child: Text('Emma (UK) ♀')),
                  DropdownMenuItem(value: 'bf_isabella', child: Text('Isabella (UK) ♀')),
                  DropdownMenuItem(value: 'bm_george', child: Text('George (UK) ♂')),
                  DropdownMenuItem(value: 'bm_lewis', child: Text('Lewis (UK) ♂')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(audioStateProvider.notifier).setVoice(value);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            audioState.volume == 0
                ? Icons.volume_off
                : audioState.volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
            size: 20,
          ),
          onPressed: onShowVolumeControl,
          tooltip: 'Volume: ${(audioState.volume * 100).toInt()}%',
        ),
        IconButton(
          icon: const Icon(Icons.speed, size: 20),
          onPressed: onShowSpeedControl,
          tooltip: 'Speed: ${audioState.playbackSpeed}x',
        ),
      ],
    );
  }
}
