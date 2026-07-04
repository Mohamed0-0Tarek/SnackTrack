import 'package:flutter/material.dart';

class DataSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final String displayValue;
  final Color primary;
  final ColorScheme scheme;
  final TextTheme tt;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const DataSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.displayValue,
    required this.primary,
    required this.scheme,
    required this.tt,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: displayValue,
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [primary, primary],
                        ).createShader(const Rect.fromLTWH(0, 0, 60, 30)),
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: tt.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: primary,
            inactiveTrackColor: primary.withValues(alpha: 0.15),
            thumbColor: primary,
            overlayColor: primary.withValues(alpha: 0.15),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
