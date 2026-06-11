import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const ReportCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : Border.all(color: theme.dividerColor),
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
      child: child,
    );
  }
}
