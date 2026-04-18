// Meal history screen — browse, search, and filter past meal entries.
//
// ## Layout (top to bottom)
//   1. [MealSearchBar]       — free-text search field.
//   2. [HistoryFilterChips]  — Today / Week / Month toggle + sort icon.
//   3. Date-grouped sections — each with a [DateSectionHeader] followed
//      by a list of [MealHistoryCard]s.
//
// ## Flat-mapping a grouped Map into a ListView
// [MealController.groupedHistory] returns a `Map<String, List<MealModel>>`
// — date labels as keys and meal lists as values.  [ListView.builder]
// expects a flat integer index, so we need a mapping strategy:
//
//   Index 0 → DateSectionHeader("Today")
//   Index 1 → MealHistoryCard(salmon)
//   Index 2 → MealHistoryCard(smoothie)
//   Index 3 → DateSectionHeader("Yesterday")
//   Index 4 → MealHistoryCard(poke bowl)
//   …
//
// [_itemCount] sums `1 + meals.length` per section to get the total.
// [_buildItem] walks the grouped map with a running cursor to decide
// whether a given index is a header or a card.
//
// This approach avoids building the entire list up front (unlike
// putting everything in a Column) — [ListView.builder] lazily creates
// only the visible items, which matters for long meal histories.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/meal_controller.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../models/meal_model.dart';
import 'widgets/date_section_header.dart';
import 'widgets/history_filter_chips.dart';
import 'widgets/meal_history_card.dart';
import 'widgets/meal_search_bar.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final _searchCtrl = TextEditingController();

  static const Map<String, String> _mealImages = {
    'grilled salmon & avocado': 'assets/images/grilled_salmon_avocado.png',
    'berry blast smoothie bowl': 'assets/images/berry_blast_smoothie.png',
    'spicy ahi poke bowl': 'assets/images/spicy_ahi_poke.png',
  };

  String? _imageFor(MealModel meal) => _mealImages[meal.name.toLowerCase()];

  @override
  void initState() {
    super.initState();
    // Defer the API call until the widget tree is ready.
    // See dashboard_screen.dart for a detailed explanation of why
    // `addPostFrameCallback` is necessary here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealController>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `watch` — rebuilds whenever MealController calls notifyListeners().
    final controller = context.watch<MealController>();
    final tt         = Theme.of(context).textTheme;

    // ── Loading state ──────────────────────────────────────────────────────────
    if (controller.isLoading) {
      return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
    }

    // The controller's computed getter already applies the active filter
    // and search query, then groups by date — we just read the result.
    final groups = controller.groupedHistory;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── 1. Search bar ───────────────────────────────────────────────────
          // `controller.setSearchQuery` is passed directly as the callback.
          // Every keystroke updates the controller's `searchQuery`, which
          // triggers `notifyListeners()`, which re-runs this build method,
          // which re-reads `groupedHistory` — reactive filtering with no
          // manual plumbing.
          MealSearchBar(
            onChanged: controller.setSearchQuery,
          ),

          const SizedBox(height: 14),

          // ── 2. Filter chips row ─────────────────────────────────────────────
          HistoryFilterChips(
            selected: controller.selectedFilter,
            onSelected: controller.setFilter,
          ),

          const SizedBox(height: 8),

          // ── 3. Scrollable date-grouped meal list ────────────────────────────
          // `Expanded` gives the ListView all remaining vertical space
          // below the search bar and chips.
          Expanded(
            child: groups.isEmpty
                // Show a friendly empty state instead of a blank screen
                ? _EmptyState(textTheme: tt)
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.paddingSM,
                      // Extra bottom padding clears the bottom nav bar
                      bottom: AppDimensions.paddingXL,
                    ),
                    // Total flat items = Σ(1 header + N cards) per section
                    itemCount: _itemCount(groups),
                    // Each call resolves the flat index to a widget
                    itemBuilder: (context, index) =>
                        _buildItem(context, groups, index),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Flattened-list helpers ────────────────────────────────────────────────
  //
  // These two methods convert between the Map-based group structure
  // and the flat integer indices that [ListView.builder] expects.

  /// Counts the total number of widgets (headers + cards) across all
  /// date sections.
  ///
  /// Each section contributes `1` (the header) + `entry.value.length`
  /// (the meal cards).
  int _itemCount(Map<String, List<MealModel>> groups) {
    int count = 0;
    for (final entry in groups.entries) {
      count += 1 + entry.value.length;
    }
    return count;
  }

  /// Maps a flat [index] into either a [DateSectionHeader] or a
  /// [MealHistoryCard] by walking the grouped map with a running cursor.
  ///
  /// ### Algorithm
  /// ```
  /// cursor = 0
  /// for each section:
  ///   if index == cursor → it's this section's header
  ///   cursor++
  ///   if index < cursor + sectionLength → it's a card at (index - cursor)
  ///   cursor += sectionLength
  /// ```
  Widget _buildItem(
    BuildContext context,
    Map<String, List<MealModel>> groups,
    int index,
  ) {
    int cursor = 0;
    for (final entry in groups.entries) {
      // ── Header position ───────────────────────────────────────────
      if (index == cursor) {
        // Sum calories for the section using `fold`:
        // start at 0, accumulate each meal's calories.
        final totalCals =
            entry.value.fold<int>(0, (sum, m) => sum + m.calories);
        return DateSectionHeader(
          label: entry.key,
          totalCalories: totalCals,
        );
      }
      cursor++;

      // ── Card position ─────────────────────────────────────────────
      if (index < cursor + entry.value.length) {
        final meal = entry.value[index - cursor];
        return MealHistoryCard(
          name:     meal.name,
          type:     meal.type,
          source:   meal.source,
          imageUrl: meal.imageUrl,
          calories: meal.calories,
          protein:  meal.protein,
          carbs:    meal.carbs,
          fat:      meal.fat,
          loggedAt: meal.loggedAt,
        );
      }
      cursor += entry.value.length;
    }
    // Safety fallback — should never be reached if _itemCount is correct.
    return const SizedBox.shrink();
  }
}

// ── Empty state placeholder ────────────────────────────────────────────────────
//
// Shown when no meals match the current filter + search combination.
// A muted icon and message reassure the user that the screen isn't
// broken — there's just nothing to show.
class _EmptyState extends StatelessWidget {
  final TextTheme textTheme;
  const _EmptyState({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.no_meals_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
          ),
          const SizedBox(height: 12),
          Text(
            'No meals found',
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
