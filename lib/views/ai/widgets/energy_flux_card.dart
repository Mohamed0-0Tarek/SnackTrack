import 'package:flutter/material.dart';
import 'custom_card.dart';

class EnergyFluxCard extends StatelessWidget {
  final int avgCalories;

  const EnergyFluxCard({super.key, this.avgCalories = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final stability = avgCalories > 0
        ? (avgCalories / 2200).clamp(0.0, 1.0)
        : 0.0;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: scheme.tertiary, size: 20),
              const SizedBox(width: 6),
              Text('Energy Flux', style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Average $avgCalories kcal/day this week.',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CALORIC INTAKE',
                style: tt.labelSmall?.copyWith(letterSpacing: 1.2),
              ),
              Text(
                '$avgCalories kcal',
                style: tt.headlineMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stability,
              minHeight: 5,
              backgroundColor: scheme.primary.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
