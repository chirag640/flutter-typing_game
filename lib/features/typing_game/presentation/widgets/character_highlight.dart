import 'package:flutter/material.dart';

class CharacterHighlight extends StatelessWidget {
  final String originalText;
  final String typedText;

  const CharacterHighlight({
    super.key,
    required this.originalText,
    required this.typedText,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _buildTextSpans(context),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              height: 1.5,
            ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final List<TextSpan> spans = [];
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    for (int i = 0; i < originalText.length; i++) {
      if (i < typedText.length) {
        // Character has been typed
        final bool isCorrect = typedText[i] == originalText[i];
        spans.add(
          TextSpan(
            text: originalText[i],
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              backgroundColor: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            ),
          ),
        );
      } else {
        // Character not yet typed
        spans.add(
          TextSpan(
            text: originalText[i],
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
      }
    }

    return spans;
  }
}
