import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/ai_service.dart';

class RecipeController extends ChangeNotifier {
  final RecipeService _recipeService;
  final AiService _aiService;

  RecipeController(this._recipeService, this._aiService);

  List<RecipeModel> recipes = [];
  bool isLoading = false;
  bool isAnalyzing = false;
  String? error;

  Future<void> loadRecipes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      recipes = await _recipeService.getRecipes();
    } catch (e) {
      error = 'Could not load recipes.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<RecipeModel?> saveRecipe(RecipeModel recipe) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      final saved = await _recipeService.saveRecipe(recipe);
      recipes.insert(0, saved);
      return saved;
    } catch (e) {
      error = 'Could not save recipe.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    try {
      await _recipeService.updateRecipe(recipe);
      final idx = recipes.indexWhere((r) => r.id == recipe.id);
      if (idx != -1) recipes[idx] = recipe;
      notifyListeners();
    } catch (e) {
      error = 'Could not update recipe.';
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _recipeService.deleteRecipe(recipeId);
      recipes.removeWhere((r) => r.id == recipeId);
      notifyListeners();
    } catch (e) {
      error = 'Could not delete recipe.';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> analyzeRecipeMacros(String description) async {
    isAnalyzing = true;
    error = null;
    notifyListeners();
    try {
      final result = await _aiService.analyzeRecipeMacros(description);
      return result;
    } catch (e) {
      error = 'Could not analyze recipe macros.';
      return null;
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }
}
