import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color primary;
  final Color secondary;
  final VoidCallback onTap;
  final bool enabled;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.primary,
    required this.secondary,
    required this.onTap,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDisabled = isLoading || !enabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: enabled
                ? [primary, secondary]
                : [scheme.onSurface.withAlpha(60), scheme.onSurface.withAlpha(40)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: enabled && !isLoading
              ? [
                  BoxShadow(
                    color: primary.withAlpha(80),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: tt.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, color: Colors.white, size: 18),
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}

