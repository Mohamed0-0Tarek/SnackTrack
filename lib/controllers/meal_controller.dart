import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../services/ai_service.dart';

/// Manages meal analysis, persistence, and history browsing.
///
/// ## What changed vs the old MealController
/// - Now takes BOTH MealService and AiService (previously only
///   MealService — `analyzeMeal` used to live on MealService itself,
///   which mixed AI concerns into the persistence layer).
/// - `loadHistory()` no longer falls back to `_mockHistory` on error —
///   that fallback was silently masking the fact that MealService was
///   never actually working. Errors now surface to [error] for the UI
///   to show, which is the correct behavior now that the service is real.
/// - `analyzeMeal` calls AiService, `saveMeal` calls MealService — same
///   split the task plan specifies for Fatma's AiService/MealService.
enum HistoryFilter { today, week, month }

enum MealInputMethod { text, photo, barcode, voice }

class MealController extends ChangeNotifier {
  final MealService _mealService;
  final AiService _aiService;

  MealController(this._mealService, this._aiService);

  MealModel? analyzedMeal;
  List<MealModel> history = [];
  bool isLoading = false;
  bool isAnalyzing = false;
  String? error;
  String? analysisError;

  HistoryFilter selectedFilter = HistoryFilter.today;
  String searchQuery = '';

  // ── Analysis & persistence ────────────────────────────────────────────

  /// Sends [description] to the AI service for nutritional analysis.
  /// Returns true on success so the caller can navigate forward.
  Future<bool> analyzeMeal(String description) async {
    isAnalyzing = true;
    analysisError = null;
    notifyListeners();
    try {
      analyzedMeal = await _aiService.analyzeMeal(description);
      return true;
    } catch (e) {
      analysisError = 'Could not analyze meal. Try again.';
      return false;
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Persists the currently analysed meal to Firestore.
  /// Returns true on success.
  Future<bool> saveMeal() async {
    if (analyzedMeal == null) return false;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final saved = await _mealService.saveMeal(analyzedMeal!);
      analyzedMeal = saved;
      return true;
    } catch (e) {
      error = 'Could not save meal.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── History loading ─────────────────────────────────────────────────

  /// Fetches the user's meal history from Firestore.
  /// No mock fallback anymore — a failure here is a real failure the UI
  /// should show (retry button), not something to paper over.
  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      history = await _mealService.getMealHistory();
    } catch (e) {
      error = 'Could not load meal history.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Filtering helpers ───────────────────────────────────────────────

  void setFilter(HistoryFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  List<MealModel> get filteredHistory {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime cutoff = switch (selectedFilter) {
      HistoryFilter.today => today,
      HistoryFilter.week => today.subtract(const Duration(days: 7)),
      HistoryFilter.month => today.subtract(const Duration(days: 30)),
    };

    return history.where((m) {
      if (m.loggedAt.isBefore(cutoff)) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!m.name.toLowerCase().contains(q) && !m.type.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  Map<String, List<MealModel>> get groupedHistory {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<MealModel>> groups = {};

    for (final meal in filteredHistory) {
      final date = DateTime(meal.loggedAt.year, meal.loggedAt.month, meal.loggedAt.day);

      final String label;
      if (date == today) {
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else {
        label = _formatDate(meal.loggedAt);
      }

      groups.putIfAbsent(label, () => []).add(meal);
    }
    return groups;
  }

  void clearAnalysis() {
    analyzedMeal = null;
    analysisError = null;
    notifyListeners();
  }

  static String _formatDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  /// Quick-favorites: real distinct recent meal names from Firestore.
  /// AddMealScreen re-runs analyzeMeal() on the chosen name rather than
  /// reusing a stored calorie value — only the name is cached here, not
  /// full nutrition data, so a fresh AI analysis is the honest path.
  Future<List<String>> getQuickFavorites() => _mealService.getRecentDistinctMealNames();
}
