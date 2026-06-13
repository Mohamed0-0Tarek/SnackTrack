// Macro-nutrient display card.
//
// ## Design pattern: parameterised reusable widget
// Rather than creating three separate widgets for protein, carbs, and
// fats, we built one [MacroCard] that accepts [label], [value], [color],
// [progress], and [iconAsset] as parameters.  The dashboard screen
// simply instantiates three of them with different arguments.
// This "configure, don't duplicate" approach is a core Flutter idiom.
//
// ## Layout structure (vertical)
// ┌────────────────────┐
// │   ● icon circle    │  ← tinted with [color]
// │     PROTEIN        │  ← [label]
// │      92g           │  ← [value]
// │ ▓▓▓▓▓▓▓░░░░░░░░░ │  ← [LinearProgressIndicator]
// └────────────────────┘
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// A compact card that visualises a single macro nutrient.
///
/// Used in a [Row] of three on the dashboard — one each for protein,
/// carbs, and fats.  The [color] parameter tints both the icon
/// background and the progress bar so each macro has a distinct accent.
class MacroCard extends StatelessWidget {
  /// Nutrient label shown below the icon (e.g. "PROTEIN").
  final String label;

  /// Formatted value string (e.g. "92g").
  final String value;

  /// Progress fraction toward the daily goal (0.0 – 1.0).
  /// Clamped internally so values > 1.0 don't break the indicator.
  final double progress;

  /// Accent colour for the icon circle and progress bar fill.
  final Color color;

  /// Asset path for the nutrient icon (e.g. "assets/images/protein.png").
  final String iconAsset;

  const MacroCard({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM + 4, // 12 px
        vertical:   AppDimensions.paddingMD,      // 16 px
      ),
      decoration: BoxDecoration(
        // Card surface: dark surface colour in dark mode, white in light
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        // Subtle drop shadow in light mode only — dark mode relies on
        // surface colour contrast instead of shadows.
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Tinted icon circle ──────────────────────────────────────
          // `withAlpha` creates a faint wash of the accent colour behind
          // the icon.  Higher alpha in dark mode (38) for visibility,
          // lower in light mode (26) to stay subtle.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 38 : 26),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(iconAsset, width: 22, height: 22),
            ),
          ),

          const SizedBox(height: 10),

          // ── Label (e.g. "PROTEIN") ──────────────────────────────────
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // ── Value (e.g. "92g") ──────────────────────────────────────
          Text(
            value,
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // ── Thin progress bar ───────────────────────────────────────
          // [ClipRRect] clips the indicator's sharp corners to match
          // our rounded card aesthetic.
          //
          // [LinearProgressIndicator] is a Material widget — we override
          // its background and fill colours to match the macro's accent.
          // `AlwaysStoppedAnimation` provides a static colour (no
          // animation controller needed for a simple colour override).
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: color.withAlpha(isDark ? 31 : 38),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
