import 'package:flutter/material.dart';
import 'package:health_assistant/models/meal_model.dart';
import 'package:health_assistant/services/ai_service.dart';

class MealViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();

  Meal? meal;
  bool isLoading = false;

  Future<void> analyzeMeal(String input) async {
    isLoading = true;
    notifyListeners();

    meal = await _aiService.analyzeMeal(input);

    isLoading = false;
    notifyListeners();
  }
}