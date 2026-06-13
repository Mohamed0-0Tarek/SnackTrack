import '../core/network/dio_client.dart';
import '../models/meal_model.dart';
import '../models/daily_summary_model.dart';

class MealService {
  final DioClient _dio;
  MealService(this._dio);

  Future<MealModel> analyzeMeal(String description) async {
    final response = await _dio.post('/meals/analyze', data: {'description': description});
    return MealModel.fromJson(response.data);
  }

  Future<MealModel> saveMeal(MealModel meal) async {
    final response = await _dio.post('/meals', data: meal.toJson());
    return MealModel.fromJson(response.data);
  }

  Future<DailySummaryModel> getDailySummary(DateTime date) async {
    final response = await _dio.get('/meals/summary', params: {'date': date.toIso8601String()});
    return DailySummaryModel.fromJson(response.data);
  }

  Future<List<MealModel>> getMealHistory({int page = 1}) async {
    final response = await _dio.get('/meals/history', params: {'page': page});
    return (response.data as List).map((m) => MealModel.fromJson(m)).toList();
  }
}
