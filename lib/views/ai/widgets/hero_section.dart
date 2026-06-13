import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withAlpha(200),
                scheme.secondary.withAlpha(200),
              ],
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
            ),
            child: Icon(
              Icons.psychology_outlined,
              color: scheme.primary,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your digital oracle for metabolic precision. Analyzing\nreal-time performance and nutritional velocity.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            color: scheme.onSurface.withAlpha(160),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
