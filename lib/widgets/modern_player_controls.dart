// lib/widgets/modern_player_controls.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Modern, intuitive player controls for audiobook/TTS playback
class ModernPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final bool hasSavedPosition;
  final int currentPage;
  final int totalPages;
  final int? savedPage;
  final double playbackSpeed;
  final VoidCallback? onPlayPause;
  final VoidCallback? onResume; // Resume from saved position
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final VoidCallback? onSpeedTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onSettingsTap;

  const ModernPlayerControls({
    super.key,
    required this.isPlaying,
    this.isLoading = false,
    this.hasSavedPosition = false,
    this.currentPage = 0,
    this.totalPages = 0,
    this.savedPage,
    this.playbackSpeed = 1.0,
    this.onPlayPause,
    this.onResume,
    this.onPreviousPage,
    this.onNextPage,
    this.onSpeedTap,
    this.onVoiceTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            _buildProgressBar(),
            const SizedBox(height: 16),

            // Main controls row with optional resume hint on left
            Row(
              children: [
                // Resume hint on the left (same width as right spacer for symmetry)
                SizedBox(
                  width: 72,
                  child: (hasSavedPosition &&
                          !isPlaying &&
                          savedPage != null &&
                          savedPage != currentPage)
                      ? _buildCompactResumeHint()
                      : null,
                ),

                // Center controls - takes remaining space
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Audio settings (speed/volume) button with icon
                      _ControlButton(
                        icon: Icons.tune_rounded,
                        onTap: onSpeedTap,
                        size: 44,
                      ),

                      const SizedBox(width: 16),

                      // Previous page
                      _ControlButton(
                        icon: Icons.skip_previous_rounded,
                        onTap: currentPage > 0 ? onPreviousPage : null,
                        size: 48,
                      ),

                      const SizedBox(width: 12),

                      // Main play/pause button
                      _buildMainPlayButton(),

                      const SizedBox(width: 12),

                      // Next page
                      _ControlButton(
                        icon: Icons.skip_next_rounded,
                        onTap: currentPage < totalPages - 1 ? onNextPage : null,
                        size: 48,
                      ),

                      const SizedBox(width: 16),

                      // Voice selector
                      _ControlButton(
                        icon: Icons.record_voice_over_outlined,
                        onTap: onVoiceTap,
                        size: 44,
                      ),

                      const SizedBox(width: 12),

                      // Settings (font, size, etc.)
                      _ControlButton(
                        icon: Icons.text_fields_rounded,
                        onTap: onSettingsTap,
                        size: 44,
                      ),
                    ],
                  ),
                ),

                // Right spacer for symmetry
                const SizedBox(width: 72),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = totalPages > 0 ? (currentPage + 1) / totalPages : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Page ${currentPage + 1}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$totalPages pages',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMainPlayButton() {
    return GestureDetector(
      onTap: isLoading ? null : onPlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isLoading ? AppTheme.surfaceAlt : AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    size: 32,
                    color: AppTheme.textOnPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCompactResumeHint() {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.highlight,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 16,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 2),
            Text(
              'p.${(savedPage ?? 0) + 1}',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: unused_element
/// Individual control button with consistent styling
class _ControlButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onTap;
  final double size;

  const _ControlButton({
    this.icon,
    this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.5,
            color: isDisabled ? AppTheme.textMuted : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Modern speed selector with slider
class SpeedSelectorSheet extends StatefulWidget {
  final double currentSpeed;
  final double currentVolume;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onVolumeChanged;

  const SpeedSelectorSheet({
    super.key,
    required this.currentSpeed,
    required this.currentVolume,
    required this.onSpeedChanged,
    required this.onVolumeChanged,
  });

  @override
  State<SpeedSelectorSheet> createState() => _SpeedSelectorSheetState();
}

class _SpeedSelectorSheetState extends State<SpeedSelectorSheet> {
  late double _speed;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _speed = widget.currentSpeed;
    _volume = widget.currentVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Audio Controls',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // === SPEED SECTION ===
          Row(
            children: [
              const Icon(Icons.speed, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Playback Speed',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.highlight,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  '${_speed.toStringAsFixed(1)}x',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Speed Slider
          Row(
            children: [
              Text(
                '0.5x',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _speed,
                  min: 0.5,
                  max: 2.5,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() => _speed = value);
                    widget.onSpeedChanged(value);
                  },
                ),
              ),
              Text(
                '2.5x',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          // Speed Preset buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              final isSelected = (_speed - speed).abs() < 0.05;
              return GestureDetector(
                onTap: () {
                  setState(() => _speed = speed);
                  widget.onSpeedChanged(speed);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    '${speed}x',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.textOnPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // === VOLUME SECTION ===
          Row(
            children: [
              Icon(
                _volume == 0 ? Icons.volume_off : Icons.volume_up,
                size: 20,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Volume',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.highlight,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  '${(_volume * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Volume Slider
          Row(
            children: [
              const Icon(Icons.volume_mute,
                  size: 16, color: AppTheme.textMuted),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() => _volume = value);
                    widget.onVolumeChanged(value);
                  },
                ),
              ),
              const Icon(Icons.volume_up, size: 16, color: AppTheme.textMuted),
            ],
          ),

          // Volume Preset buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [0.25, 0.5, 0.75, 1.0].map((vol) {
              final isSelected = (_volume - vol).abs() < 0.05;
              return GestureDetector(
                onTap: () {
                  setState(() => _volume = vol);
                  widget.onVolumeChanged(vol);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    '${(vol * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.textOnPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // === READING MODE PRESETS ===
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Reading Modes',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reading Mode Preset Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ReadingModeButton(
                icon: Icons.self_improvement,
                label: 'Relaxed',
                description: 'Slow & calm',
                onTap: () {
                  setState(() {
                    _speed = 0.85;
                    _volume = 0.8;
                  });
                  widget.onSpeedChanged(0.85);
                  widget.onVolumeChanged(0.8);
                },
              ),
              _ReadingModeButton(
                icon: Icons.menu_book,
                label: 'Normal',
                description: 'Balanced',
                onTap: () {
                  setState(() {
                    _speed = 1.0;
                    _volume = 1.0;
                  });
                  widget.onSpeedChanged(1.0);
                  widget.onVolumeChanged(1.0);
                },
              ),
              _ReadingModeButton(
                icon: Icons.flash_on,
                label: 'Quick',
                description: 'Faster pace',
                onTap: () {
                  setState(() {
                    _speed = 1.35;
                    _volume = 1.0;
                  });
                  widget.onSpeedChanged(1.35);
                  widget.onVolumeChanged(1.0);
                },
              ),
              _ReadingModeButton(
                icon: Icons.speed,
                label: 'Speed Read',
                description: 'Maximum pace',
                onTap: () {
                  setState(() {
                    _speed = 1.75;
                    _volume = 1.0;
                  });
                  widget.onSpeedChanged(1.75);
                  widget.onVolumeChanged(1.0);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Button widget for reading mode presets
class _ReadingModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ReadingModeButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: AppTheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern voice selector
class VoiceSelectorSheet extends StatelessWidget {
  final String currentVoice;
  final List<VoiceOption> voices;
  final ValueChanged<String> onVoiceChanged;
  final ValueChanged<String>? onPreviewVoice;

  const VoiceSelectorSheet({
    super.key,
    required this.currentVoice,
    required this.voices,
    required this.onVoiceChanged,
    this.onPreviewVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Choose Voice',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the voice for reading',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Voice list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: voices.length,
              itemBuilder: (context, index) {
                final voice = voices[index];
                final isSelected = voice.id == currentVoice;

                return GestureDetector(
                  onTap: () {
                    onVoiceChanged(voice.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppTheme.highlight : AppTheme.surfaceAlt,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: isSelected
                          ? Border.all(color: AppTheme.primary, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppTheme.primary : AppTheme.border,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              voice.name.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.textOnPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voice.name,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (voice.description != null)
                                Text(
                                  voice.description!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Don't show preview button for currently selected voice
                        if (onPreviewVoice != null && !isSelected)
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            color: AppTheme.primary,
                            onPressed: () => onPreviewVoice!(voice.id),
                            tooltip: 'Preview voice',
                          ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceOption {
  final String id;
  final String name;
  final String? description;
  final String? locale;

  const VoiceOption({
    required this.id,
    required this.name,
    this.description,
    this.locale,
  });
}

/// Font size selector with slider
class FontSizeSelector extends StatefulWidget {
  final double currentSize;
  final double minSize;
  final double maxSize;
  final ValueChanged<double> onSizeChanged;

  const FontSizeSelector({
    super.key,
    required this.currentSize,
    this.minSize = 14,
    this.maxSize = 28,
    required this.onSizeChanged,
  });

  @override
  State<FontSizeSelector> createState() => _FontSizeSelectorState();
}

class _FontSizeSelectorState extends State<FontSizeSelector> {
  late double _size;

  @override
  void initState() {
    super.initState();
    _size = widget.currentSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Text Size',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Text(
              'The quick brown fox jumps over the lazy dog.',
              style: GoogleFonts.literata(
                fontSize: _size,
                height: 1.6,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Slider with icons
          Row(
            children: [
              const Icon(
                Icons.text_decrease_rounded,
                size: 20,
                color: AppTheme.textMuted,
              ),
              Expanded(
                child: Slider(
                  value: _size,
                  min: widget.minSize,
                  max: widget.maxSize,
                  onChanged: (value) {
                    setState(() => _size = value);
                    widget.onSizeChanged(value);
                  },
                ),
              ),
              const Icon(
                Icons.text_increase_rounded,
                size: 24,
                color: AppTheme.textMuted,
              ),
            ],
          ),

          // Size label
          Center(
            child: Text(
              '${_size.round()}pt',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
