import 'package:flutter/material.dart';
import '../models/water_entry_model.dart';
import '../services/water_service.dart';

class WaterController extends ChangeNotifier {
  final WaterService _waterService;

  WaterController(this._waterService);

  List<WaterEntry> todayEntries = [];
  bool isLoading = false;
  int todayTotalMl = 0;

  Future<void> loadToday() async {
    isLoading = true;
    notifyListeners();
    try {
      todayEntries = await _waterService.getTodaysWater();
      _recalcTotal();
    } catch (_) {
      // silently fail
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logWater(int amountMl) async {
    try {
      await _waterService.logWater(amountMl);
      await loadToday();
    } catch (_) {}
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _waterService.deleteEntry(entryId);
      await loadToday();
    } catch (_) {}
  }

  void _recalcTotal() {
    todayTotalMl = todayEntries.fold(0, (sum, e) => sum + e.amountMl);
  }
}
