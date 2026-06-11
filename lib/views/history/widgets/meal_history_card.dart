// Full meal card shown in the history timeline.
//
// ## Image fallback chain
// Not every meal will have a photo.  [_buildImage] handles three cases:
//   1. Network URL (starts with "http") → [Image.network] with error
//      fallback.
//   2. Local asset path → [Image.asset] with error fallback.
//   3. Null / empty → gradient placeholder with a utensils icon.
//
// Both Image builders use [errorBuilder] so a missing or corrupt file
// degrades gracefully to the placeholder instead of crashing.
//
// ## ClipRRect for rounded images
// [ClipRRect] clips its child to a rounded rectangle.  Here we round
// only the *top* corners of the image so it sits flush against the
// card's rounded top edge while the bottom remains sharp where the
// text content begins.
//
// ## _NutrientChip: Expanded inside Row
// Each chip is wrapped in [Expanded] inside a [Row] so all four chips
// share the available width equally, regardless of label length.
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// A rich meal card with food image, name, subtitle, and nutrient chips.
///
/// Used inside date sections on the history screen.
class MealHistoryCard extends StatelessWidget {
  /// Display name of the food (e.g. "Grilled Salmon & Avocado").
  final String name;

  /// Meal category — "breakfast", "lunch", "dinner", or "snack".
  final String type;

  /// How the meal was prepared (e.g. "Restaurant", "Homemade").
  /// Shown in the subtitle; omitted when `null`.
  final String? source;

  /// Optional URL or asset path for the food photo.
  /// Falls back to a gradient placeholder when `null`.
  final String? imageUrl;

  /// Total kilocalories for this meal.
  final int    calories;

  /// Grams of protein.
  final double protein;

  /// Grams of carbohydrates.
  final double carbs;

  /// Grams of fat.
  final double fat;

  /// Timestamp when the meal was logged.
  final DateTime loggedAt;

  const MealHistoryCard({
    super.key,
    required this.name,
    required this.type,
    this.source,
    this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Capitalised type label ("lunch" → "Lunch") for display
    final typeLabel = type[0].toUpperCase() + type.substring(1);
    // Formatted time string ("12:30 PM")
    final timeStr   = _formatTime(loggedAt);

    return Container(
      // Bottom margin separates consecutive cards
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        // Light-mode shadow for depth; dark mode skips it
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Food image (or placeholder) ───────────────────────────────
          // [ClipRRect] rounds only the top corners so the image fits
          // the card's rounded top while the bottom stays straight.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLG),
            ),
            child: _buildImage(scheme, isDark),
          ),

          // ── Text content area ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + time row ─────────────────────────────────────
                // [Expanded] on the name lets it shrink/wrap while the
                // time label stays at its intrinsic width on the right.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(timeStr, style: tt.bodySmall),
                  ],
                ),

                const SizedBox(height: 4),

                // ── Category + source subtitle ──────────────────────────
                // The `•` dot separator only appears when [source] is
                // provided.  The muted alpha keeps this line secondary.
                Text(
                  source != null ? '$typeLabel • $source' : typeLabel,
                  style: tt.bodySmall?.copyWith(
                    color: scheme.onSurface.withAlpha(120),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Nutrient chips row ──────────────────────────────────
                // Four [_NutrientChip] widgets, each wrapped in
                // [Expanded] internally, so they divide width equally.
                Row(
                  children: [
                    _NutrientChip(
                      label: 'CALS',
                      value: '$calories',
                      color: scheme.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _NutrientChip(
                      label: 'PROTEIN',
                      value: '${protein.round()}g',
                      color: scheme.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _NutrientChip(
                      label: 'CARBS',
                      value: '${carbs.round()}g',
                      color: scheme.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _NutrientChip(
                      label: 'FATS',
                      value: '${fat.round()}g',
                      color: scheme.primary,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Image builder with fallback chain ─────────────────────────────────────

  /// Decides which image source to use and falls back to a placeholder
  /// on null, empty, or load error.
  Widget _buildImage(ColorScheme scheme, bool isDark) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Branch on URL scheme: network vs local asset
      if (imageUrl!.startsWith('http')) {
        return Image.network(
          imageUrl!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          // `errorBuilder` catches network failures and shows the
          // placeholder instead of a red error widget.
          errorBuilder: (_, __, ___) => _placeholder(scheme, isDark),
        );
      }
      return Image.asset(
        imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        // Catches missing or corrupt asset files
        errorBuilder: (_, __, ___) => _placeholder(scheme, isDark),
      );
    }
    // No image URL at all → placeholder
    return _placeholder(scheme, isDark);
  }

  /// Gradient placeholder with a centred utensils icon.
  ///
  /// The gradient blends two very faint theme colours so the
  /// placeholder feels integrated rather than jarring.
  Widget _placeholder(ColorScheme scheme, bool isDark) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF232E45), const Color(0xFF1A2236)]
              : [scheme.primary.withAlpha(20), scheme.secondary.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.restaurant_rounded,
        size: 48,
        color: scheme.primary.withAlpha(isDark ? 80 : 60),
      ),
    );
  }

  /// Formats a [DateTime] to "hh:mm AM/PM" (12-hour clock).
  static String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }
}

// ── Small outlined chip displaying a single nutrient value ─────────────────────
//
// ## Why Expanded is inside the chip (not outside)
// The [Expanded] wrapper lives in the chip's own [build] method rather
// than at the call site.  This means anywhere you place a
// [_NutrientChip] inside a [Row], it automatically claims equal flex
// space — one less thing for the caller to remember.
class _NutrientChip extends StatelessWidget {
  /// Nutrient label (e.g. "CALS", "PROTEIN").
  final String label;

  /// Formatted value (e.g. "540", "38g").
  final String value;

  /// Outline and text accent colour.
  final Color  color;

  /// Whether the current theme is dark — affects border/text alpha.
  final bool   isDark;

  const _NutrientChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // [Expanded] inside the chip so it auto-distributes width in a Row.
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          // Outlined style — border only, no fill
          border: Border.all(
            color: color.withAlpha(isDark ? 60 : 80),
          ),
        ),
        child: Column(
          children: [
            // Tiny uppercase label
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: color.withAlpha(isDark ? 160 : 180),
              ),
            ),
            const SizedBox(height: 2),
            // Bold numeric value
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
