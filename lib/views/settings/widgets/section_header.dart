import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isDark;
  const SectionHeader({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
