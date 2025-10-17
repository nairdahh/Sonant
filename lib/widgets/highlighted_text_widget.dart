// lib/widgets/highlighted_text_widget.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Widget performant pentru highlight de cuvinte fără rebuild complet
class HighlightedText extends StatefulWidget {
  final String text;
  final List<WordHighlight> highlights;
  final int? currentHighlightIndex;
  final TextStyle? style;
  final TextAlign textAlign;
  final Function(int)? onWordTap;
  final ScrollController? scrollController;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlights,
    this.currentHighlightIndex,
    this.style,
    this.textAlign = TextAlign.justify,
    this.onWordTap,
    this.scrollController,
  });

  @override
  State<HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<HighlightedText> {
  double? _lastHighlightBottom;
  final GlobalKey _textKey = GlobalKey();

  @override
  void didUpdateWidget(HighlightedText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Scroll inteligent: doar când highlight-ul coboară rândul
    if (widget.currentHighlightIndex != null &&
        widget.currentHighlightIndex != oldWidget.currentHighlightIndex &&
        widget.scrollController != null &&
        widget.currentHighlightIndex! >= 0 &&
        widget.currentHighlightIndex! < widget.highlights.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _smartScroll());
    }
  }

  void _smartScroll() {
    if (!mounted ||
        widget.scrollController == null ||
        !widget.scrollController!.hasClients) {
      return;
    }

    final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final highlight = widget.highlights[widget.currentHighlightIndex!];

    // Creăm un TextPainter pentru a găsi poziția exactă
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      textAlign: widget.textAlign,
    );

    textPainter.layout(maxWidth: renderBox.size.width);

    // Găsim box-urile pentru cuvântul curent
    final boxes = textPainter.getBoxesForSelection(
      TextSelection(baseOffset: highlight.start, extentOffset: highlight.end),
    );

    if (boxes.isEmpty) return;

    final wordBox = boxes.first;
    final wordBottom = wordBox.bottom;

    // 🎯 Verificăm dacă am coborât rândul
    final needsScroll =
        _lastHighlightBottom == null || wordBottom > _lastHighlightBottom! + 5;

    _lastHighlightBottom = wordBottom;

    if (!needsScroll) return;

    final scrollController = widget.scrollController!;
    final currentScroll = scrollController.offset;
    final viewportHeight = scrollController.position.viewportDimension;

    // Poziția cuvântului în viewport
    final wordPositionInViewport = wordBottom - currentScroll;

    // 🎯 Scroll doar dacă cuvântul e sub 75% din viewport
    final threshold = viewportHeight * 0.75;

    if (wordPositionInViewport > threshold) {
      // Poziționăm cuvântul la 25% din top
      final targetScroll =
          currentScroll + (wordPositionInViewport - viewportHeight * 0.25);

      scrollController.animateTo(
        targetScroll.clamp(0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<InlineSpan> _buildTextSpans() {
    if (widget.text.isEmpty) {
      return [TextSpan(text: widget.text, style: widget.style)];
    }

    if (widget.highlights.isEmpty) {
      return [TextSpan(text: widget.text, style: widget.style)];
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    // Sortăm highlights după poziție
    final sortedHighlights = List<WordHighlight>.from(widget.highlights)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (int i = 0; i < sortedHighlights.length; i++) {
      final highlight = sortedHighlights[i];

      // Verificăm bounds
      if (highlight.start < 0 || highlight.end > widget.text.length) continue;
      if (highlight.start >= highlight.end) continue;

      // Text înainte de highlight
      if (highlight.start > lastEnd) {
        spans.add(TextSpan(
          text: widget.text.substring(lastEnd, highlight.start),
          style: widget.style,
        ));
      }

      // Cuvântul highlight-at - FOLOSIM TEXT ORIGINAL, NU mark.value
      final isCurrentWord = i == widget.currentHighlightIndex;
      final wordText = widget.text.substring(highlight.start, highlight.end);

      spans.add(TextSpan(
        text: wordText,
        style: widget.style?.copyWith(
          backgroundColor: isCurrentWord
              ? Colors.yellow.withOpacity(0.6)
              : Colors.transparent,
          fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.normal,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => widget.onWordTap?.call(i),
      ));

      lastEnd = highlight.end;
    }

    // Text rămas după ultimul highlight
    if (lastEnd < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(lastEnd),
        style: widget.style,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      key: _textKey,
      textAlign: widget.textAlign,
      text: TextSpan(
        style: widget.style ?? const TextStyle(fontSize: 18, height: 1.8),
        children: _buildTextSpans(),
      ),
    );
  }
}

class WordHighlight {
  final int start;
  final int end;
  final String word;

  WordHighlight({
    required this.start,
    required this.end,
    required this.word,
  });
}
