// Manages meal analysis, persistence, and history browsing.
//
// ## Responsibilities
// 1. **Analyse** — sends a free-text meal description to the AI backend
//    and stores the returned [MealModel] in [analyzedMeal].
// 2. **Save** — persists the analysed meal to the server.
// 3. **History** — loads the full meal log, then exposes filtered and
//    date-grouped views for the history screen.
//
// ## Reactive filtering
// [selectedFilter] and [searchQuery] are plain fields.  When they
// change via [setFilter] / [setSearchQuery], `notifyListeners()` fires
// and every widget watching this controller rebuilds.  The computed
// getters [filteredHistory] and [groupedHistory] re-derive on every
// access, so the UI always reflects the latest filter state.
//
// ## Why computed getters instead of cached lists?
// Caching would require invalidating the cache whenever `history`,
// `selectedFilter`, or `searchQuery` changes.  For the number of meals
// a user logs per day (typically < 50), re-filtering on rebuild is
// negligibly cheap and avoids a whole class of stale-cache bugs.
import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';

/// Available time-range filters for the history view.
///
/// Each value maps to a different cutoff date in [filteredHistory]:
/// - [today]  — only meals logged after midnight today.
/// - [week]   — meals from the last 7 calendar days.
/// - [month]  — meals from the last 30 calendar days.
enum HistoryFilter { today, week, month }
enum MealInputMethod { text, photo, barcode, voice }

class FavoriteMealModel {
  final String id;
  final String name;
  final int calories;
  final double protein;

  const FavoriteMealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
  });
}

class MealController extends ChangeNotifier {
  /// Injected data-layer dependency (see also: `app.dart` Provider setup).
  final MealService _mealService;

  MealController(this._mealService);

  /// Holds the most recently analysed (but not yet saved) meal.
  /// The add-meal screen reads this to show the nutritional breakdown.
  MealModel? analyzedMeal;

  /// Complete unfiltered meal history fetched from the backend.
  ///
  /// This is the **raw** list — the UI should read [filteredHistory] or
  /// [groupedHistory] instead, which apply the active filter and search.
  List<MealModel> history = [];

  /// Standard loading / error state fields (see DashboardController for
  /// a detailed explanation of the loading pattern).
  bool    isLoading = false;
  String? error;

  /// Currently active time-range filter chip on the history screen.
  HistoryFilter selectedFilter = HistoryFilter.today;

  /// Free-text search string applied against meal names and types.
  String searchQuery = '';

  // ── Analysis & persistence ────────────────────────────────────────────────

  /// Sends [description] to the AI backend for nutritional analysis.
  ///
  /// Returns `true` on success so the caller can navigate forward,
  /// or `false` on failure so it can show an error.
  Future<bool> analyzeMeal(String description) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      analyzedMeal = await _mealService.analyzeMeal(description);
      return true;
    } catch (e) {
      error = 'Could not analyze meal. Try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Persists the currently analysed meal to the server.
  ///
  /// Guard: silently returns if [analyzedMeal] is null (nothing to save).
  Future<void> saveMeal() async {
    if (analyzedMeal == null) return;
    isLoading = true;
    notifyListeners();
    try {
      await _mealService.saveMeal(analyzedMeal!);
    } catch (e) {
      error = 'Could not save meal.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── History loading ───────────────────────────────────────────────────────

  /// Fetches the user's full meal history from the API.
  ///
  /// Falls back to [_mockHistory] during development when the backend
  /// is unreachable, so the history screen can still be worked on.
  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      history = await _mealService.getMealHistory();
    } catch (e) {
      history = _mockHistory;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Filtering helpers ─────────────────────────────────────────────────────

  /// Called when the user taps a different time-range chip.
  ///
  /// `notifyListeners()` causes every `context.watch<MealController>()`
  /// widget to rebuild, which re-evaluates [filteredHistory] with the
  /// new cutoff.
  void setFilter(HistoryFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  /// Called on every keystroke in the search bar.
  ///
  /// Because [filteredHistory] is a computed getter, the filtered list
  /// updates automatically on the next build cycle — no extra work needed.
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  /// Returns meals that satisfy **both** the time-range filter and the
  /// search query, sorted newest-first.
  ///
  /// ### Algorithm
  /// 1. Compute a `cutoff` DateTime from the selected chip.
  /// 2. Walk every meal in [history]:
  ///    - Skip if `loggedAt` is before the cutoff.
  ///    - Skip if the search query doesn't match the name or type.
  /// 3. Sort survivors descending by `loggedAt`.
  ///
  /// ### Performance note
  /// `..sort(...)` is a **cascade operator** — it calls `sort` on the
  /// list returned by `toList()` and then returns the same list, avoiding
  /// a temporary variable.
  List<MealModel> get filteredHistory {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Determine the earliest date to include based on the active chip.
    // Dart 3 **switch expression** — exhaustive over the enum values.
    final DateTime cutoff = switch (selectedFilter) {
      HistoryFilter.today => today,
      HistoryFilter.week  => today.subtract(const Duration(days: 7)),
      HistoryFilter.month => today.subtract(const Duration(days: 30)),
    };

    return history.where((m) {
      // Time-range gate
      if (m.loggedAt.isBefore(cutoff)) return false;
      // Free-text search gate (case-insensitive)
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!m.name.toLowerCase().contains(q) &&
            !m.type.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  /// Partitions [filteredHistory] into date buckets keyed by a
  /// human-readable label ("Today", "Yesterday", or "Mon, Apr 10").
  ///
  /// ### Why a `Map<String, List<MealModel>>`?
  /// A `LinkedHashMap` (Dart's default `Map`) preserves insertion order,
  /// so the sections appear in the same chronological order as the
  /// sorted input.  The history screen iterates this map to build
  /// alternating header + card items in a single flat `ListView`.
  Map<String, List<MealModel>> get groupedHistory {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<MealModel>> groups = {};

    for (final meal in filteredHistory) {
      // Strip the time component so we can compare dates only
      final date = DateTime(meal.loggedAt.year, meal.loggedAt.month, meal.loggedAt.day);

      // Assign a friendly label
      final String label;
      if (date == today) {
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else {
        label = _formatDate(meal.loggedAt);
      }

      // `putIfAbsent` creates the list on first encounter, then `add`
      // appends the meal.  This is a common grouping idiom in Dart.
      groups.putIfAbsent(label, () => []).add(meal);
    }
    return groups;
  }

  /// Resets the analysis state (e.g. when the user cancels mid-flow).
  void clearAnalysis() { analyzedMeal = null; notifyListeners(); }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Produces a short date label like "Mon, Apr 10".
  ///
  /// Hand-rolled rather than using the `intl` package to avoid an
  /// extra dependency for a single formatting call.
  static String _formatDate(DateTime dt) {
    const days   = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    // `dt.weekday` is 1-based (Monday = 1) so subtract 1 for the index.
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  // ── Mock data used when the real API is unavailable ─────────────────────
  //
  // `static final` caches the "now" snapshot so all mock entries use a
  // consistent reference date within a single app session.

  static final DateTime _today     = DateTime.now();
  static final DateTime _todayDate = DateTime(_today.year, _today.month, _today.day);

  static List<MealModel> get _mockHistory => [
    // ── Today's meals ───────────────────────────────────────────────────
    MealModel(
      id: 'h1',
      name: 'Grilled Salmon & Avocado',
      type: 'lunch',
      calories: 540,
      protein: 38,
      carbs: 12,
      fat: 22,
      loggedAt: _todayDate.add(const Duration(hours: 12, minutes: 30)),
      source: 'Restaurant',
    ),
    MealModel(
      id: 'h2',
      name: 'Berry Blast Smoothie Bowl',
      type: 'breakfast',
      calories: 320,
      protein: 15,
      carbs: 45,
      fat: 8,
      loggedAt: _todayDate.add(const Duration(hours: 8, minutes: 15)),
      source: 'Homemade',
    ),
    // ── Yesterday's meals ───────────────────────────────────────────────
    MealModel(
      id: 'h3',
      name: 'Spicy Ahi Poke Bowl',
      type: 'dinner',
      calories: 680,
      protein: 32,
      carbs: 72,
      fat: 18,
      loggedAt: _todayDate.subtract(const Duration(hours: 4, minutes: 30)),
      source: 'Delivery',
    ),
    MealModel(
      id: 'h4',
      name: 'Avocado Toast & Eggs',
      type: 'breakfast',
      calories: 410,
      protein: 22,
      carbs: 34,
      fat: 24,
      loggedAt: _todayDate.subtract(const Duration(hours: 15)),
      source: 'Homemade',
    ),
    MealModel(
      id: 'h5',
      name: 'Chicken Caesar Wrap',
      type: 'lunch',
      calories: 480,
      protein: 36,
      carbs: 42,
      fat: 18,
      loggedAt: _todayDate.subtract(const Duration(hours: 11)),
      source: 'Restaurant',
    ),
  ];
  Future<void> addFavoriteMeal(FavoriteMealModel favorite) async {
    isLoading = true;
    notifyListeners();
    try {
      final meal = MealModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: favorite.name,
        calories: favorite.calories,
        protein: favorite.protein,
        carbs: 0,
        fat: 0,
        loggedAt: DateTime.now(),
      );
      await _mealService.saveMeal(meal);
    } catch (e) {
      error = 'Could not log meal.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
