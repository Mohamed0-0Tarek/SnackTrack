import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme scheme;
  final TextTheme tt;
  const SectionLabel({
    super.key,
    required this.label,
    required this.scheme,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: scheme.onSurface.withAlpha(26), thickness: 1),
        ),
      ],
    );
  }
}
