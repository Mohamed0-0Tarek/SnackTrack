import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';
import '../services/meal_plan_service.dart';
import '../services/ai_service.dart';
import '../controllers/setting_controller.dart';

class MealPlanController extends ChangeNotifier {
  final MealPlanService _planService;
  final AiService _aiService;

  MealPlanController(this._planService, this._aiService);

  MealPlanModel? currentPlan;
  List<MealPlanModel> plans = [];
  bool isLoading = false;
  bool isGenerating = false;
  String? error;

  Future<void> loadPlans() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      plans = await _planService.getPlans();
      currentPlan = plans.isNotEmpty ? plans.first : null;
    } catch (e) {
      error = 'Could not load meal plans.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generatePlan(SettingController settings, {String? preferences}) async {
    isGenerating = true;
    error = null;
    notifyListeners();
    try {
      final json = await _aiService.generateMealPlan(
        goalCalories: settings.goalCalories,
        goalProtein: settings.goalProtein,
        goalCarbs: settings.goalCarbs,
        goalFat: settings.goalFat,
        preferences: preferences,
      );
      final plan = MealPlanModel(
        id: '',
        name: json['name'] ?? 'Weekly Meal Plan',
        days: (json['days'] as List)
            .map((d) => MealPlanDay.fromJson(d as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.now(),
      );
      final saved = await _planService.savePlan(plan);
      plans.insert(0, saved);
      currentPlan = saved;
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('429') || msg.contains('RESOURCE_EXHAUSTED')) {
        error = 'Free tier limit reached. Please wait about a minute and try again.';
      } else {
        error = 'Could not generate meal plan.';
      }
      return false;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _planService.deletePlan(planId);
      plans.removeWhere((p) => p.id == planId);
      if (currentPlan?.id == planId) {
        currentPlan = plans.isNotEmpty ? plans.first : null;
      }
      notifyListeners();
    } catch (e) {
      error = 'Could not delete plan.';
      notifyListeners();
    }
  }
}
