// lib/widgets/speed_volume_dialogs.dart

import 'package:flutter/material.dart';

/// Dialog pentru ajustarea volumului audio.
/// 
/// Oferă:
/// - Slider pentru control fin (0-100%)
/// - Afișare procent curent
class VolumeDialog extends StatelessWidget {
  final double initialVolume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeDialog({
    super.key,
    required this.initialVolume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.volume_up, size: 24),
          SizedBox(width: 12),
          Text('Volume'),
        ],
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          double volume = initialVolume;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.volume_down, size: 20),
                  Expanded(
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(volume * 100).toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          volume = value;
                        });
                        onVolumeChanged(value);
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${(volume * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class SpeedDialog extends StatelessWidget {
  final double initialSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedDialog({
    super.key,
    required this.initialSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.speed, size: 24),
          SizedBox(width: 12),
          Text('Playback Speed'),
        ],
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          double speed = initialSpeed;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: speed,
                min: 0.5,
                max: 2.0,
                divisions: 6,
                label: '${speed}x',
                onChanged: (value) {
                  setState(() {
                    speed = value;
                  });
                  onSpeedChanged(value);
                },
              ),
              const SizedBox(height: 12),
              Text(
                '${speed}x',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _buildSpeedChip(0.5, speed, setState, onSpeedChanged),
                  _buildSpeedChip(0.75, speed, setState, onSpeedChanged),
                  _buildSpeedChip(1.0, speed, setState, onSpeedChanged),
                  _buildSpeedChip(1.25, speed, setState, onSpeedChanged),
                  _buildSpeedChip(1.5, speed, setState, onSpeedChanged),
                  _buildSpeedChip(2.0, speed, setState, onSpeedChanged),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildSpeedChip(
    double speed,
    double currentSpeed,
    StateSetter setState,
    ValueChanged<double> onChanged,
  ) {
    final isSelected = (currentSpeed - speed).abs() < 0.01;
    return ChoiceChip(
      label: Text('${speed}x'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            onChanged(speed);
          });
        }
      },
    );
  }
}
