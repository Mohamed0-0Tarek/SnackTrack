import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
  final String time;
  final String message;

  const UserMessage({required this.time, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(time, style: tt.labelSmall),
            const SizedBox(width: 8),
            Text(
              'YOU',
              style: tt.labelSmall?.copyWith(
                color: scheme.secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? scheme.secondary.withAlpha(40)
                : scheme.secondary.withAlpha(20),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border(
              right: BorderSide(color: scheme.secondary, width: 3),
            ),
          ),
          child: Text(message, style: tt.bodyLarge),
        ),
      ],
    );
  }
}
