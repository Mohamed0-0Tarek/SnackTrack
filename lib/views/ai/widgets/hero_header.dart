import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroHeader extends StatelessWidget {
  final int avgCalories;
  final int mealCount;

  const HeroHeader({super.key, this.avgCalories = 0, this.mealCount = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));

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
          '${_format(weekAgo)} — ${_format(today)}',
          style: tt.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$mealCount meals logged this week. '
          'Average $avgCalories kcal/day.',
          style: tt.bodyMedium?.copyWith(
            color: scheme.onSurface.withAlpha(160),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  String _format(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }
}
