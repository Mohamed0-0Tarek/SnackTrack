import 'package:flutter/material.dart';
import 'custom_card.dart';

class SystemLogsCard extends StatelessWidget {
  final String? topMeal;
  final int streak;

  const SystemLogsCard({super.key, this.topMeal, this.streak = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: scheme.primary, size: 20),
              const SizedBox(width: 6),
              Text('System Logs', style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 14),
          _LogRow(
            icon: Icons.restaurant_menu_rounded,
            label: 'Top Meal',
            value: topMeal ?? '—',
            color: scheme.primary,
          ),
          const SizedBox(height: 10),
          _LogRow(
            icon: Icons.local_fire_department_rounded,
            label: 'Entries',
            value: '$streak meals',
            color: scheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _LogRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: tt.bodySmall?.copyWith(color: color)),
        const Spacer(),
        Text(value, style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
