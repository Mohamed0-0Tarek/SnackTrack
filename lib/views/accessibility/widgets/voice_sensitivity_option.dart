import 'package:flutter/material.dart';

class VoiceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final ColorScheme scheme;
  final bool isDark;
  final VoidCallback onTap;

  const VoiceOption({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.scheme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == selected;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.transparent
                : (isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive
                    ? scheme.primary
                    : scheme.onSurface.withAlpha(100),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: tt.labelSmall?.copyWith(
                  color: isActive
                      ? scheme.primary
                      : scheme.onSurface.withAlpha(100),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
