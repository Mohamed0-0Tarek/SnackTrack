import '../core/network/dio_client.dart';
import '../models/recipe_model.dart';

class AiService {
  final DioClient _dio;
  AiService(this._dio);

  Future<String> chat(List<Map<String, String>> messages) async {
    final response = await _dio.post('/ai/chat', data: {'messages': messages});
    return response.data['reply'];
  }

  Future<RecipeModel> generateRecipe(String prompt) async {
    final response = await _dio.post('/ai/recipe', data: {'prompt': prompt});
    return RecipeModel.fromJson(response.data);
  }

  Future<String> getHabitInsights() async {
    final response = await _dio.get('/ai/habits');
    return response.data['insights'];
  }
}
