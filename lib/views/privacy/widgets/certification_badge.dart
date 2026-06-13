import 'package:flutter/material.dart';

class CertBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const CertBadge({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: scheme.onSurface.withOpacity(0.5), size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurface.withOpacity(0.4),
            fontSize: 9,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
