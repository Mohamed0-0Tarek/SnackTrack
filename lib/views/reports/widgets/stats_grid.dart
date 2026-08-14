import 'package:flutter/material.dart';

/// Stats grid — `avgCalories` is now real data from WeeklyReportController.
/// Hydration/Sleep quality remain placeholders since those aren't tracked.
class StatsGrid extends StatelessWidget {
  final int avgCalories;

  const StatsGrid({super.key, required this.avgCalories});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatTile(
          icon: Icons.local_fire_department_outlined,
          iconColor: scheme.tertiary,
          label: 'AVG CALORIES',
          value: avgCalories > 0
              ? '${_formatNumber(avgCalories)} kcal'
              : '–',
        ),
        _StatTile(
          icon: Icons.bolt,
          iconColor: scheme.primary,
          label: 'ENERGY PEAK',
          value: '–',
        ),
        _StatTile(
          icon: Icons.water_drop_outlined,
          iconColor: scheme.primary,
          label: 'HYDRATION',
          value: '–',
        ),
        _StatTile(
          icon: Icons.bedtime_outlined,
          iconColor: scheme.secondary,
          label: 'SLEEP QUALITY',
          value: '–',
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: tt.labelSmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: tt.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
