import 'package:flutter/material.dart';
import '../models/daily_summary_model.dart';
import '../services/meal_service.dart';

class DashboardController extends ChangeNotifier {
  final MealService _mealService;
  DashboardController(this._mealService);

  DailySummaryModel? summary;
  bool   isLoading = false;
  String? error;

  Future<void> loadSummary() async {
    isLoading = true; error = null; notifyListeners();
    try {
      summary = await _mealService.getDailySummary(DateTime.now());
    } catch (e) {
      error = 'Could not load summary.';
    } finally {
      isLoading = false; notifyListeners();
    }
  }
}
