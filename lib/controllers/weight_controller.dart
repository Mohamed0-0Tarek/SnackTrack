import 'package:flutter/material.dart';
import '../models/weight_entry_model.dart';
import '../services/weight_service.dart';

class WeightController extends ChangeNotifier {
  final WeightService _weightService;

  WeightController(this._weightService);

  List<WeightEntry> history = [];
  bool isLoading = false;
  String? error;

  WeightEntry? get latestWeight =>
      history.isNotEmpty ? history.first : null;

  double? get weightChangeLastWeek {
    if (history.length < 2) return null;
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    // Find the nearest entry before lastWeek
    WeightEntry? before;
    for (final entry in history.reversed) {
      if (entry.loggedAt.isBefore(lastWeek)) {
        before = entry;
        break;
      }
    }
    if (before == null) return null;
    return latestWeight!.weightKg - before.weightKg;
  }

  String get trendDirection {
    final change = weightChangeLastWeek;
    if (change == null) return 'flat';
    if (change.abs() < 0.3) return 'stable';
    return change < 0 ? 'down' : 'up';
  }

  String get trendLabel {
    final change = weightChangeLastWeek;
    if (change == null) return '–';
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      history = await _weightService.getHistory(limit: 30);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logWeight(double weightKg, {String? notes}) async {
    try {
      await _weightService.logWeight(weightKg, notes: notes);
      await loadHistory();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _weightService.deleteEntry(entryId);
      await loadHistory();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
