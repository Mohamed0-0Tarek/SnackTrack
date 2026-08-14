import 'package:flutter/material.dart';
import 'shared_card.dart';

class WeightCard extends StatelessWidget {
  final double? latestWeight;
  final double? weightChange;
  final String trendDirection;
  final VoidCallback onTap;

  const WeightCard({
    super.key,
    required this.latestWeight,
    required this.weightChange,
    required this.trendDirection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Color trendColor;
    IconData trendIcon;
    switch (trendDirection) {
      case 'down':
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
      case 'up':
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
      default:
        trendColor = scheme.onSurface.withAlpha(100);
        trendIcon = Icons.trending_flat;
    }

    return GestureDetector(
      onTap: onTap,
      child: ReportCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT WEIGHT',
                  style: tt.labelSmall?.copyWith(
                    color: scheme.onSurface.withAlpha(100),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      latestWeight != null
                          ? latestWeight!.toStringAsFixed(1)
                          : '–',
                      style: tt.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('kg', style: tt.bodyMedium),
                    ),
                  ],
                ),
              ],
            ),
            if (weightChange != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: trendColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, color: trendColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${weightChange! >= 0 ? '+' : ''}${weightChange!.toStringAsFixed(1)}',
                      style: tt.labelLarge?.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withAlpha(120),
              ),
          ],
        ),
      ),
    );
  }
}
