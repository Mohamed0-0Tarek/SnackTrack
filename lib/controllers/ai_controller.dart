import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/ai_service.dart';

class AiController extends ChangeNotifier {
  final AiService _aiService;
  AiController(this._aiService);

  List<Map<String, String>> messages = [];
  RecipeModel? recipe;
  String? habitInsights;
  bool   isLoading = false;
  String? error;

  Future<void> sendMessage(String text) async {
    messages.add({'role': 'user', 'content': text});
    isLoading = true; notifyListeners();
    try {
      final reply = await _aiService.chat(messages);
      messages.add({'role': 'assistant', 'content': reply});
    } catch (e) {
      error = 'Could not get response.';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> generateRecipe(String prompt) async {
    isLoading = true; error = null; notifyListeners();
    try {
      recipe = await _aiService.generateRecipe(prompt);
    } catch (e) {
      error = 'Could not generate recipe.';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> loadHabitInsights() async {
    isLoading = true; notifyListeners();
    try {
      habitInsights = await _aiService.getHabitInsights();
    } catch (e) {
      error = 'Could not load insights.';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  void clearChat() { messages.clear(); notifyListeners(); }
}
