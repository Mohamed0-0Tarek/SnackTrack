import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        Text(
          'WEEKLY PERFORMANCE SUMMARY',
          style: tt.labelSmall?.copyWith(
            color: scheme.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Oct 23 — Oct 29',
          style: tt.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your metabolic efficiency is operating at peak levels. The AI has identified a 12% improvement in glucose stability compared to last week.',
          style: tt.bodyMedium?.copyWith(
            color: scheme.onSurface.withAlpha(160),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
