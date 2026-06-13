import 'package:flutter/material.dart';
import 'custom_card.dart';

class MetabolicHealthCard extends StatelessWidget {
  const MetabolicHealthCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      accentBorder: scheme.primary.withAlpha(80),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Watermark icon
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.trending_up_rounded,
              size: 80,
              color: scheme.primary.withAlpha(isDark ? 18 : 12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_on_rounded, color: scheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Metabolic Health Index', style: tt.headlineMedium),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'EFFICIENCY',
                style: tt.labelSmall?.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                '94.2%',
                style: tt.displayLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your insulin sensitivity is trending upward. Excellent macro-timing observed on Wednesday.',
                style: tt.bodyMedium?.copyWith(
                  color: scheme.onSurface.withAlpha(160),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
