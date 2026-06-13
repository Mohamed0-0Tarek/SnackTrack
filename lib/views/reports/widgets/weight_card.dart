import 'package:flutter/material.dart';
import 'shared_card.dart';

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportCard(
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
                    '174.2',
                    style: tt.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 38,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('lbs', style: tt.bodyMedium),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_down, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  '0.8',
                  style: tt.labelLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
