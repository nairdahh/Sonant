// lib/widgets/text_enhancement_guide.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Guide for Kokoro TTS text enhancement features
class TextEnhancementGuide extends StatelessWidget {
  const TextEnhancementGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
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
            '✨ Text Enhancement',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control pronunciation and intonation with Kokoro TTS',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Content
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildSection(
                  icon: '🔤',
                  title: 'Custom Pronunciation',
                  description:
                      'Use IPA (International Phonetic Alphabet) to control how words are pronounced',
                  examples: [
                    const _ExampleItem(
                      code: '[Kokoro](/kˈOkəɹO/)',
                      description: 'Custom pronunciation using IPA notation',
                    ),
                    const _ExampleItem(
                      code: '[data](/ˈdeɪtə/)',
                      description:
                          'Pronounce as "day-tuh" instead of "dah-tuh"',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  icon: '🎭',
                  title: 'Intonation Control',
                  description:
                      'Use punctuation to adjust tone, pauses, and expression',
                  examples: [
                    const _ExampleItem(
                      code: 'Hello; how are you?',
                      description: 'Semicolon adds a subtle pause',
                    ),
                    const _ExampleItem(
                      code: 'Wait... what?',
                      description: 'Ellipsis creates dramatic pause',
                    ),
                    const _ExampleItem(
                      code: 'Amazing!',
                      description: 'Exclamation adds excitement',
                    ),
                    const _ExampleItem(
                      code: 'Really—truly amazing',
                      description: 'Em dash for emphasis',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  icon: '⬇️',
                  title: 'Lower Stress',
                  description: 'Reduce emphasis on specific words',
                  examples: [
                    const _ExampleItem(
                      code: 'This is [very](-1) important',
                      description: 'Lower stress by 1 level',
                    ),
                    const _ExampleItem(
                      code: 'The [most](-2) critical part',
                      description: 'Lower stress by 2 levels (softer)',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  icon: '⬆️',
                  title: 'Raise Stress',
                  description:
                      'Increase emphasis (works best on short, unstressed words)',
                  examples: [
                    const _ExampleItem(
                      code: 'I [do](+1) believe it',
                      description: 'Raise stress by 1 level',
                    ),
                    const _ExampleItem(
                      code: 'This [is](+2) the one',
                      description: 'Raise stress by 2 levels (stronger)',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  icon: '💡',
                  title: 'Pro Tips',
                  description: '',
                  examples: [
                    const _ExampleItem(
                      code: 'Combine techniques',
                      description:
                          'Use multiple enhancements in the same sentence for precise control',
                    ),
                    const _ExampleItem(
                      code: 'Test with preview',
                      description:
                          'Use voice preview to hear how your enhancements sound',
                    ),
                    const _ExampleItem(
                      code: 'Start simple',
                      description:
                          'Begin with punctuation, then experiment with stress and IPA',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String description,
    required List<_ExampleItem> examples,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...examples.map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.code,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      example.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _ExampleItem {
  final String code;
  final String description;

  const _ExampleItem({
    required this.code,
    required this.description,
  });
}

/// Show text enhancement guide
void showTextEnhancementGuide(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadiusXL),
      ),
    ),
    builder: (context) => const TextEnhancementGuide(),
  );
}
