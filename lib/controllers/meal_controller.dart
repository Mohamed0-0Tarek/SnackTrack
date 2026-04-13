import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';

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
  final MealService _mealService;
  MealController(this._mealService);

  MealModel? analyzedMeal;
  List<MealModel> history = [];
  bool isLoading = false;
  String? error;

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

  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      history = await _mealService.getMealHistory();
    } catch (e) {
      error = 'Could not load history.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  void clearAnalysis() {
    analyzedMeal = null;
    notifyListeners();
  }
}
