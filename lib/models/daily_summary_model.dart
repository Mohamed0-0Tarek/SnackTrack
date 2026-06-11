import 'meal_model.dart';

/// Aggregated nutritional data for a single day.
///
/// This model collects totals (calories, macros) plus their respective
/// daily goals, and carries the full list of [MealModel] entries logged
/// throughout the day.
///
/// ## Computed getters
/// [calorieProgress] and [caloriesRemaining] derive their values from
/// stored fields — they aren't sent by the API.  Using getters instead
/// of additional fields avoids data duplication and guarantees the
/// computed values always stay in sync with the source data.
///
/// ## Default parameter values
/// Goal fields like [proteinGoal] have sensible defaults (e.g. 150 g)
/// so the model works out-of-the-box even when the API omits them.
/// This keeps the dashboard functional during early development or when
/// user-specific goals haven't been configured yet.
class DailySummaryModel {
  /// Total kilocalories consumed today (sum of all logged meals).
  final int    totalCalories;

  /// The user's daily calorie budget.
  final int    calorieGoal;

  /// Calories burned through exercise.
  ///
  /// Many calorie-tracking apps add exercise back to the daily budget:
  ///   effectiveRemaining = calorieGoal - totalCalories + exerciseCalories
  /// This field lets the UI display exercise separately while also
  /// adjusting the remaining-kcal calculation if desired.
  final int    exerciseCalories;

  /// Grams of protein consumed today.
  final DateTime date; // ← أضفنا دي

  final double totalProtein;

  /// Grams of carbs consumed today.
  final double totalCarbs;

  /// Grams of fat consumed today.
  final double totalFat;

  /// Daily protein target in grams — drives the progress bar in [MacroCard].
  final double proteinGoal;

  /// Daily carbs target in grams.
  final double carbsGoal;

  /// Daily fat target in grams.
  final double fatGoal;

  /// Chronological list of individual meals logged today.
  final List<MealModel> meals;

  DailySummaryModel({
    required this.date, // ← أضفنا دي
    required this.totalCalories,
    required this.calorieGoal,
    this.exerciseCalories = 0,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.proteinGoal = 150,
    this.carbsGoal   = 250,
    this.fatGoal     = 65,
    required this.meals,
  });

  /// Fraction of daily calorie goal consumed (0.0 – 1.0+).
  ///
  /// Can exceed 1.0 if the user eats more than the goal — the UI
  /// should clamp this before passing it to a progress indicator.
  double get calorieProgress => totalCalories / calorieGoal;

  /// How many kilocalories remain before hitting the goal.
  ///
  /// May be negative when the user exceeds the budget; the dashboard
  /// clamps it to zero for display purposes.
  int get caloriesRemaining => calorieGoal - totalCalories;

  /// Constructs a [DailySummaryModel] from decoded JSON.
  ///
  /// Nullable casts (`as num?`) with `?? default` ensure the model
  /// degrades gracefully when optional goal fields are missing.
  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) =>
      DailySummaryModel(
        date: DateTime.parse(json['date']), // ← أضفنا دي
        totalCalories: json['total_calories'],
        calorieGoal: json['calorie_goal'],
        totalProtein: (json['total_protein'] as num).toDouble(),
        totalCarbs: (json['total_carbs'] as num).toDouble(),
        totalFat: (json['total_fat'] as num).toDouble(),
        meals: (json['meals'] as List)
            .map((m) => MealModel.fromJson(m))
            .toList(),
      );
}
