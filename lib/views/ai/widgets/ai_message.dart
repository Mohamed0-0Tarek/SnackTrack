import 'package:flutter/material.dart';
import 'highlighted_text.dart';

class AiMessage extends StatelessWidget {
  final String time;
  final String message;

  const AiMessage({required this.time, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SNAKE AI',
              style: tt.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(time, style: tt.labelSmall),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border(left: BorderSide(color: scheme.primary, width: 3)),
            boxShadow: isDark
                ? null
                : [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6)],
          ),
          child: HighlightedText(
            raw: message,
            baseStyle: tt.bodyLarge!,
            highlightStyle: tt.bodyLarge!.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
