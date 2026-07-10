import 'package:flutter/material.dart';

class WaterTrackerWidget extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;

  const WaterTrackerWidget({
    super.key,
    required this.currentMl,
    required this.goalMl,
    required this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Water Intake', style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${(currentMl / 1000).toStringAsFixed(1)}L',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${(goalMl / 1000).toStringAsFixed(1)}L',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
