import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE OVERVIEW',
          style: tt.labelSmall?.copyWith(
            color: scheme.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Weekly ',
                style: tt.displayLarge?.copyWith(fontWeight: FontWeight.w300),
              ),
              TextSpan(
                text: 'Report',
                style: tt.displayLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: tt.bodyMedium,
            children: [
              const TextSpan(text: 'Your metabolic velocity increased by '),
              TextSpan(
                text: '4.2%',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                text:
                    ' this week. Tracking consistency remains in the 95th percentile.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
