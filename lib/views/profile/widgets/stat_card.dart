import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Widget child;
  final bool hasBorder;
  final Color? borderColor;

  const StatCard({
    super.key,
    required this.label,
    required this.labelColor,
    required this.child,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: hasBorder
            ? Border.all(color: borderColor ?? Colors.transparent, width: 1.5)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
