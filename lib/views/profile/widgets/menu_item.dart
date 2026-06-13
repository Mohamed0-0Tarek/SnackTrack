// ── Menu item — Material + InkWell for reliable tap ───────────────────────────
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuItem({super.key, 
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      // ← Material needed for InkWell
      color: isDark ? const Color(0xFF1A2236) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        // ← InkWell is reliably tappable
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.withAlpha(150),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
