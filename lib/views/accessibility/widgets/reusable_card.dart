import 'package:flutter/material.dart';

class ReCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const ReCard({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}
