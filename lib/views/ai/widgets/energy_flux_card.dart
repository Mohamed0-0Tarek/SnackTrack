import 'package:flutter/material.dart';
import 'custom_card.dart';

class EnergyFluxCard extends StatelessWidget {
  const EnergyFluxCard();

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
              Icon(Icons.bolt, color: scheme.tertiary, size: 20),
              const SizedBox(width: 6),
              Text('Energy Flux', style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Sustained vitality levels across 16-hour active windows.',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STABILITY',
                style: tt.labelSmall?.copyWith(letterSpacing: 1.2),
              ),
              Text(
                'High',
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
              value: 0.82,
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
