// Individual meal entry widget for the daily log section.
//
// ## Visual structure
// ┌─ timeline ─┬─────────────── card ───────────────────┐
// │     ●      │ [icon]  Breakfast        340 Kcal      │
// │     │      │         Oatmeal…         08:30 AM      │
// │     │      └────────────────────────────────────────-┘
// │     │
// │     ●  ← next item
//
// The left column renders a **timeline indicator** (coloured dot +
// vertical connecting line).  The [isLast] flag hides the line beneath
// the final entry so it doesn't dangle into empty space.
//
// ## IntrinsicHeight
// The timeline line needs to stretch the full height of the card.
// A normal [Row] doesn't enforce equal heights on its children, so we
// wrap the Row in [IntrinsicHeight] which measures the tallest child
// first, then forces all children to that height.  This lets
// `Expanded` inside the timeline Column fill the exact card height.
//
// Caution: [IntrinsicHeight] adds an extra layout pass. It's fine for
// small lists (< ~50 items) but can be expensive in very long lists.
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// A single meal row in the dashboard's Daily Log section.
///
/// Shows a timeline dot, meal-type icon, food name, calories, and time.
class DailyLogItem extends StatelessWidget {
  /// Meal category key — "breakfast", "lunch", "dinner", or "snack".
  /// Used to look up the icon asset and tint colour via [_iconForType]
  /// and [_bgColorForType].
  final String mealType;

  /// Descriptive food name (e.g. "Oatmeal & Berries").
  final String foodName;

  /// Total kilocalories for this meal.
  final int calories;

  /// Timestamp when the meal was logged.
  final DateTime loggedAt;

  /// Set to `true` for the last entry so the connecting line is hidden.
  final bool isLast;

  const DailyLogItem({
    super.key,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.loggedAt,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve display values from the raw type key
    final iconPath  = _iconForType(mealType);
    final timeStr   = _formatTime(loggedAt);
    // Capitalise first letter: "breakfast" → "Breakfast"
    final typeLabel = mealType[0].toUpperCase() + mealType.substring(1);

    // [IntrinsicHeight] — see file-level comment above for why this is
    // needed to make the timeline line fill the card's height.
    return IntrinsicHeight(
      child: Row(
        // `stretch` makes the timeline Column as tall as the card
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline indicator (dot + vertical line) ────────────────
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Top padding aligns the dot with the middle of the card
                const SizedBox(height: 20),
                // Primary-coloured dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                // Connecting line — `Expanded` stretches it to fill the
                // remaining vertical space.  Hidden for the last entry.
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: scheme.primary.withAlpha(51),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Meal card ───────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(AppDimensions.paddingMD - 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2236) : Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLG),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  // Meal-type icon inside a tinted rounded square.
                  // The tint colour varies by type (see [_bgColorForType]).
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _bgColorForType(mealType, scheme, isDark),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Center(
                      child: Image.asset(iconPath,
                          width: 28, height: 28),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Food details — type label + food name.
                  // [Expanded] absorbs the remaining width so the right
                  // side (calories + time) can hug the edge.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          typeLabel,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // `TextOverflow.ellipsis` truncates long food
                        // names with "…" instead of overflowing.
                        Text(
                          foodName,
                          style: tt.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Calories + timestamp (right-aligned)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$calories Kcal',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(timeStr, style: tt.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Static helper methods ─────────────────────────────────────────────────
  //
  // These are `static` because they don't access `this` — they're pure
  // functions that map an input to an output.  Making them static
  // communicates this and allows calling them without an instance.

  /// Maps a meal-type key to its corresponding asset icon path.
  ///
  /// "dinner" reuses the lunch icon because no dedicated dinner asset
  /// exists yet — a pragmatic default until the design team provides one.
  static String _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast': return 'assets/images/breakfast.png';
      case 'lunch':     return 'assets/images/lunch.png';
      case 'dinner':    return 'assets/images/lunch.png';
      case 'snack':     return 'assets/images/snack.png';
      default:          return 'assets/images/snack.png';
    }
  }

  /// Returns a subtle tinted background colour keyed to meal type.
  ///
  /// Each type gets a different hue so users can quickly scan the log
  /// and distinguish meals at a glance.
  static Color _bgColorForType(
      String type, ColorScheme scheme, bool isDark) {
    final alpha = isDark ? 38 : 20;
    switch (type.toLowerCase()) {
      case 'breakfast': return scheme.primary.withAlpha(alpha);
      case 'lunch':     return scheme.secondary.withAlpha(alpha);
      case 'snack':     return Colors.orange.withAlpha(alpha);
      default:          return scheme.tertiary.withAlpha(alpha);
    }
  }

  /// Formats a [DateTime] to "hh:mm AM/PM" (12-hour clock).
  ///
  /// `hour == 0` is midnight which should display as "12:00 AM".
  /// `hour > 12` is afternoon — subtract 12 for the 12-hour value.
  static String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }
}
