import '../models/meal_model.dart';

class AIService {
  Future<Meal> analyzeMeal(String input) async {
    // fake data for now
    await Future.delayed(Duration(seconds: 1));

    return Meal(
      name: input,
      calories: 400,
      protein: 30,
      carbs: 50,
      fat: 10,
    );
  }
}