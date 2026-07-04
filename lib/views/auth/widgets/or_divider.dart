import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final ColorScheme scheme;
  final TextTheme   tt;
  const OrDivider({super.key, required this.scheme, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: scheme.onSurface.withValues(alpha: 0.15))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: tt.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.4)),
          ),
        ),
        Expanded(child: Divider(color: scheme.onSurface.withValues(alpha: 0.15))),
      ],
    );
  }
}