// Horizontal row of time-range filter chips (Today · Week · Month)
// with a trailing filter/sort icon button.
//
// ## Chip toggle pattern
// Rather than using Flutter's built-in [FilterChip] / [ChoiceChip]
// (which carry opinionated Material styles), we build custom chips
// from scratch with [GestureDetector] + [AnimatedContainer].  This
// gives full control over border radius, colour transitions, and
// padding to match the Figma design precisely.
//
// ## AnimatedContainer
// When [isActive] changes, [AnimatedContainer] automatically tweens
// the background colour and border over [duration].  No explicit
// [AnimationController] or [Tween] needed — Flutter handles it.
//
// ## Spacer widget
// [Spacer] expands to fill all remaining horizontal space in a [Row],
// pushing the filter icon button to the far right without hard-coding
// any widths.
import 'package:flutter/material.dart';

import '../../../controllers/meal_controller.dart';
import '../../../core/constants/app_dimensions.dart';

/// Displays three selectable time-range chips and a trailing sort icon.
///
/// [selected] highlights the active chip; [onSelected] reports taps
/// back to the parent so it can update [MealController.selectedFilter].
class HistoryFilterChips extends StatelessWidget {
  /// Currently selected filter chip.
  final HistoryFilter selected;

  /// Callback when the user taps a different chip.
  final ValueChanged<HistoryFilter> onSelected;

  const HistoryFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── The three time-range chips ────────────────────────────────
        // Each chip checks whether it's the active one by comparing
        // [selected] against its own enum value.
        _Chip(
          label: 'Today',
          isActive: selected == HistoryFilter.today,
          onTap: () => onSelected(HistoryFilter.today),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Week',
          isActive: selected == HistoryFilter.week,
          onTap: () => onSelected(HistoryFilter.week),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Month',
          isActive: selected == HistoryFilter.month,
          onTap: () => onSelected(HistoryFilter.month),
        ),

        // Pushes the filter icon to the far right
        const Spacer(),

        // ── Trailing filter/sort icon ────────────────────────────────
        _FilterIconButton(),
      ],
    );
  }
}

// ── Single chip toggle ─────────────────────────────────────────────────────────
//
// Private widget (underscore prefix) because it's only used inside
// [HistoryFilterChips].  Keeping small helpers private reduces the
// public API surface of the file — other developers see [HistoryFilterChips]
// as the sole entry point.
class _Chip extends StatelessWidget {
  /// Display text (e.g. "Today").
  final String      label;

  /// Whether this chip is currently selected.
  final bool        isActive;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // [GestureDetector] is the simplest tap handler — use it when you
    // don't need Material ripple/splash feedback.  For ink effects,
    // use [InkWell] instead (requires a [Material] ancestor).
    return GestureDetector(
      onTap: onTap,
      // [AnimatedContainer] smoothly tweens between the active (filled)
      // and inactive (outlined) visual states over 200 ms.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          // Active → filled with primary colour; inactive → surface fill
          color: isActive
              ? scheme.primary
              : (isDark ? const Color(0xFF1A2236) : Colors.white),
          // `radiusFull` (100) produces a fully rounded "pill" shape.
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          // Active chips drop the border (filled bg is enough contrast);
          // inactive chips use a subtle border for definition.
          border: isActive
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF2D3C57)
                      : const Color(0xFFE2E8F0),
                ),
        ),
        child: Text(
          label,
          style: tt.labelLarge?.copyWith(
            // Active text uses `onPrimary` (e.g. white on teal);
            // inactive uses `onSurface` (e.g. dark gray on white).
            color: isActive
                ? scheme.onPrimary
                : scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Trailing filter/sort icon ──────────────────────────────────────────────────
//
// Placeholder button for a future sort/filter bottom sheet.
// Currently non-interactive — ready to hook up with an `onTap` callback
// when the feature is implemented.
class _FilterIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3C57) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Icon(
        Icons.tune_rounded,
        size: 18,
        color: scheme.onSurface.withAlpha(160),
      ),
    );
  }
}
