import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/recipe_model.dart';

/// Calls an LLM directly for meal analysis, chat, and recipe generation.
///
/// ## What changed vs the old AiService
/// The old version POSTed to fake `/ai/chat`, `/ai/recipe`, `/ai/habits`
/// REST endpoints. This rewrite calls the LLM provider directly — example
/// below uses Gemini's REST API since it has a generous free tier, but
/// swapping to OpenAI only means changing [_endpoint] and the request/
/// response shape in [_callModel].
///
/// ## Where the API key comes from
/// NEVER hardcode the key here. Pass it in via --dart-define at build
/// time, or better, proxy these calls through a Cloud Function so the
/// key never ships in the client binary. The constructor below takes it
/// as a parameter for that reason — wire it from an environment-style
/// config, not a literal string.
class AiService {
  final String _apiKey;
  // gemini-2.5-flash-lite is the current
  // low-cost/low-latency stable model
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  AiService({String apiKey = const String.fromEnvironment('GEMINI_API_KEY')})
      : _apiKey = apiKey;

  Future<Map<String, dynamic>> _callModel(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'No Gemini API key configured. Pass --dart-define=GEMINI_API_KEY=... '
        'at build/run time.',
      );
    }

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]}
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (text == null) {
      throw Exception('AI response missing expected content.');
    }
    return jsonDecode(text) as Map<String, dynamic>;
  }

  /// Analyzes a free-text meal description into structured nutrition data.
  /// Returns a [MealModel] with a placeholder id/loggedAt — the caller
  /// (MealController) fills those in properly before saving.
  Future<MealModel> analyzeMeal(String description) async {
    final prompt = '''
You are a nutrition analysis assistant. Given a meal description, respond
with ONLY a JSON object (no markdown, no commentary) with this exact shape:
{
  "name": string,
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "vitamins": {"Vitamin A": number (0-1), "Vitamin C": number (0-1), ...},
  "minerals": {"Iron": number (0-1), "Magnesium": number (0-1), ...},
  "notes": string
}
Include common vitamins and minerals where you can estimate them from the
meal description. Use 0-1 values representing fraction of daily value.
Omit vitamins or minerals if you cannot estimate them.

Meal description: "$description"
''';

    final json = await _callModel(prompt);
    final vitaminsRaw = json['vitamins'] as Map<String, dynamic>?;
    final mineralsRaw = json['minerals'] as Map<String, dynamic>?;

    return MealModel(
      id: '', // assigned by MealService.saveMeal on persist
      name: json['name'] ?? description,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      loggedAt: DateTime.now(),
      notes: json['notes'] as String?,
      analyzedBy: 'gemini-2.5-flash-lite',
      vitamins: vitaminsRaw?.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      minerals: mineralsRaw?.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }

  /// Sends a chat message with prior conversation context.
  /// [history] is a list of {"role": "user"|"assistant", "content": "..."}.
  Future<String> chat(List<Map<String, String>> history) async {
    if (_apiKey.isEmpty) {
      throw Exception('No Gemini API key configured.');
    }

    final contents = history
        .map((m) => {
              'role': m['role'] == 'assistant' ? 'model' : 'user',
              'parts': [{'text': m['content']}],
            })
        .toList();

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contents': contents}),
    );

    if (response.statusCode != 200) {
      throw Exception('AI chat failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
    return text ?? 'Sorry, I could not generate a response.';
  }

  Future<RecipeModel> generateRecipe(String prompt) async {
    final fullPrompt = '''
You are a recipe generator. Respond with ONLY a JSON object (no markdown)
with this exact shape:
{"name": string, "ingredients": [string], "steps": [string], "calories": number, "protein": number, "carbs": number, "fat": number}

Request: "$prompt"
''';
    final json = await _callModel(fullPrompt);
    return RecipeModel.fromJson(json);
  }

  /// One-tip dietary suggestion based on today's logged meals — used by
  /// the dashboard's Smart Analysis Card.
  Future<String> getDietaryTip(List<MealModel> todaysMeals) async {
    final summary = todaysMeals
        .map((m) => '${m.name} (${m.calories} kcal, P:${m.protein}g C:${m.carbs}g F:${m.fat}g)')
        .join(', ');

    final prompt = '''
You are a nutrition coach. Based on today's logged meals, respond with
ONLY a JSON object: {"tip": string}. Keep the tip to one or two sentences.

Today's meals: $summary
''';
    final json = await _callModel(prompt);
    return json['tip'] as String? ?? 'Keep logging meals to get personalized tips.';
  }

  /// Weekly pattern insights — used by AI coach habit cards.
  Future<List<String>> getHabitInsights(List<MealModel> weeklyMeals) async {
    final summary = weeklyMeals.map((m) => '${m.type} on ${m.loggedAt.weekday}').join(', ');

    final prompt = '''
You are a nutrition coach analyzing a week of meal logs. Respond with
ONLY a JSON object: {"insights": [string, string, string]} — exactly
three short, specific observations about eating patterns.

Logs: $summary
''';
    final json = await _callModel(prompt);
    final insights = json['insights'] as List?;
    return insights?.map((e) => e.toString()).toList() ?? [];
  }

  /// Weekly Oracle Verdict — health grade + recommendations for the
  /// weekly report screen. Returns a Map with keys:
  ///   "grade"           → string e.g. "B+"
  ///   "summary"         → one sentence metabolic overview
  ///   "recommendations" → list of 3 short strings
  Future<Map<String, dynamic>> getWeeklyOracleVerdict(dynamic report) async {
    final avgCal = report.avgCalories;
    final protein = report.totalProtein.toStringAsFixed(0);
    final carbs = report.totalCarbs.toStringAsFixed(0);
    final fat = report.totalFat.toStringAsFixed(0);
    final topMeal = report.topMealByCalories?.name ?? 'unknown';

    final prompt = '''
You are a nutrition oracle. Given this user's weekly nutritional data,
respond with ONLY a JSON object (no markdown):
{"grade": string, "summary": string, "recommendations": [string, string, string]}

- grade: A letter grade A-F with optional +/- (e.g. "B+")
- summary: one sentence metabolic overview
- recommendations: exactly 3 short, actionable nutrition tips

Weekly data:
- Average daily calories: $avgCal kcal
- Total protein: ${protein}g
- Total carbs: ${carbs}g
- Total fat: ${fat}g
- Highest calorie meal this week: $topMeal
''';
    return await _callModel(prompt);
  }
}