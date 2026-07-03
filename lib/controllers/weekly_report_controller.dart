import 'package:flutter/material.dart';
import '../services/weekly_report_service.dart';
import '../services/ai_service.dart';

class WeeklyReportController extends ChangeNotifier {
  final WeeklyReportService _reportService;
  final AiService _aiService;

  WeeklyReportController(this._reportService, this._aiService);

  WeeklyReport? report;
  bool isLoading = false;
  String? error;

  // AI oracle fields
  String? oracleGrade;        // e.g. "B+"
  String? oracleSummary;      // metabolic summary sentence
  List<String> oracleRecs = []; // 3 recommendations
  bool isOracleLoading = false;

  Future<void> loadReport() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      report = await _reportService.getWeeklyReport();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }

    if (report != null && report!.allMeals.isNotEmpty) {
      _loadOracleCard();
    }
  }

  Future<void> _loadOracleCard() async {
    if (isOracleLoading) return;
    isOracleLoading = true;
    notifyListeners();
    try {
      final result = await _aiService.getWeeklyOracleVerdict(report!);
      oracleGrade = result['grade'] as String?;
      oracleSummary = result['summary'] as String?;
      oracleRecs = List<String>.from(result['recommendations'] ?? []);
    } catch (_) {
      // Non-critical — oracle card shows placeholder if this fails.
    } finally {
      isOracleLoading = false;
      notifyListeners();
    }
  }
}
