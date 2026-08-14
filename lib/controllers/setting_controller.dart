

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';

/// App-wide settings: dark mode, notification frequency, incognito, and
/// daily macro goals.
///
/// ## What changed vs the old SettingController
/// The old version held three fields (`isDarkMode`, `notifFrequency`,
/// `incognito`) entirely in memory — every setter just flipped a local
/// field and called `notifyListeners()`. Nothing was written anywhere,
/// so every setting reset to its default on app restart.
///
/// This version:
/// - Loads from Hive on construction (instant, no network wait) via
///   [loadSettings].
/// - Then fetches `users/{uid}/settings` from Firestore in the
///   background and updates both in-memory state and the Hive cache if
///   the remote copy differs (covers a setting changed on another
///   device).
/// - Every setter writes to both Hive and Firestore immediately —
///   that's the "save to both on change" requirement from the original
///   plan — rather than requiring a separate explicit "Save" action.
///
/// Goal fields (`goalCalories`/`goalProtein`/`goalCarbs`/`goalFat`) are
/// included here even though `app_settings_screen.dart` doesn't expose
/// UI for them yet — Dashboard needs to read real goals from
/// `users/{uid}/settings`, so the persistence layer is ready for when
/// that UI gets added, without requiring another rewrite of this file.
class SettingController extends ChangeNotifier {
  bool _isDarkMode = false;
  double _notifFrequency = 1; // 0=Quiet, 1=Standard, 2=Frequent
  bool _incognito = false;
  int _goalCalories = 2000;
  double _goalProtein = 150;
  double _goalCarbs = 250;
  double _goalFat = 65;
  int _goalWaterMl = 2000;

  double _textSize = 1; // 0=Compact, 1=Standard, 2=Enlarged
  bool _highContrast = false;
  int _voiceSensitivity = 1; // 0=Quiet, 1=Balanced, 2=Highly Reactive
  bool _adaptiveAssist = false;

  // ── Privacy fields ───────────────────────────────────────────────────
  bool _anonymousAnalytics = true;
  bool _geoTracking = false;
  bool _aiTrainingModel = true;

  bool isLoading = false;
  String? error;

  bool get isDarkMode => _isDarkMode;
  double get notifFrequency => _notifFrequency;
  bool get incognito => _incognito;
  int get goalCalories => _goalCalories;
  double get goalProtein => _goalProtein;
  double get goalCarbs => _goalCarbs;
  double get goalFat => _goalFat;
  int get goalWaterMl => _goalWaterMl;

  double get textSize => _textSize;
  bool get highContrast => _highContrast;
  int get voiceSensitivity => _voiceSensitivity;
  bool get adaptiveAssist => _adaptiveAssist;
  bool get anonymousAnalytics => _anonymousAnalytics;
  bool get geoTracking => _geoTracking;
  bool get aiTrainingModel => _aiTrainingModel;

  SettingController() {
    loadSettings();
  }

  /// Loads from Hive first (instant), then reconciles with Firestore in
  /// the background. Safe to call again later (e.g. right after sign-in,
  /// once a uid actually exists) to pick up the signed-in user's data.
  Future<void> loadSettings() async {
    final cached = StorageService.getSettings();
    if (cached != null) {
      _applyModel(cached, notify: true);
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Not signed in yet — Hive cache (or defaults) is all we can use
      // for now. Call loadSettings() again after sign-in completes.
      return;
    }

    isLoading = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists && doc.data() != null) {
        final remote = SettingsModel.fromJson(doc.data()!);
        _applyModel(remote, notify: true);
        await StorageService.saveSettings(remote);
      } else {
        // No remote settings yet (new user) — push current
        // (defaults/Hive) values up so Firestore has a baseline.
        await _writeToFirestore(uid);
      }
    } catch (e) {
      error = 'Could not sync settings.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyModel(SettingsModel model, {required bool notify}) {
    _isDarkMode = model.darkMode;
    _notifFrequency = model.notifFrequency;
    _incognito = model.incognito;
    _goalCalories = model.goalCalories;
    _goalProtein = model.goalProtein;
    _goalCarbs = model.goalCarbs;
    _goalFat = model.goalFat;
    _textSize = model.textSize;
    _highContrast = model.highContrast;
    _voiceSensitivity = model.voiceSensitivity;
    _adaptiveAssist = model.adaptiveAssist;
    _anonymousAnalytics = model.anonymousAnalytics;
    _geoTracking = model.geoTracking;
    _aiTrainingModel = model.aiTrainingModel;
    _goalWaterMl = model.goalWaterMl;
    if (notify) notifyListeners();
  }

  SettingsModel _currentModel() => SettingsModel(
        darkMode: _isDarkMode,
        notifFrequency: _notifFrequency,
        incognito: _incognito,
        goalCalories: _goalCalories,
        goalProtein: _goalProtein,
        goalCarbs: _goalCarbs,
        goalFat: _goalFat,
        textSize: _textSize,
        highContrast: _highContrast,
        voiceSensitivity: _voiceSensitivity,
        adaptiveAssist: _adaptiveAssist,
        anonymousAnalytics: _anonymousAnalytics,
        geoTracking: _geoTracking,
        aiTrainingModel: _aiTrainingModel,
        goalWaterMl: _goalWaterMl,
      );

  /// Writes the current in-memory state to both Hive and Firestore.
  /// Called by every setter below — this is what makes settings
  /// "save on every change" instead of needing an explicit save button.
  Future<void> _persist() async {
    final model = _currentModel();
    await StorageService.saveSettings(model);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // Hive write above still succeeded.
    try {
      await _writeToFirestore(uid, model: model);
    } catch (e) {
      error = 'Could not sync settings to your account.';
      notifyListeners();
    }
  }

  Future<void> _writeToFirestore(String uid, {SettingsModel? model}) async {
    final data = (model ?? _currentModel()).toJson();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('preferences')
        .set(data, SetOptions(merge: true));
  }

  // ── Setters ──────────────────────────────────────────────────────────

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _persist();
  }

  void setNotifFrequency(double value) {
    _notifFrequency = value;
    notifyListeners();
    _persist();
  }

  void setIncognito(bool value) {
    _incognito = value;
    notifyListeners();
    _persist();
  }

  void setGoalCalories(int value) {
    _goalCalories = value;
    notifyListeners();
    _persist();
  }

  void setGoalProtein(double value) {
    _goalProtein = value;
    notifyListeners();
    _persist();
  }

  void setGoalCarbs(double value) {
    _goalCarbs = value;
    notifyListeners();
    _persist();
  }

  void setGoalFat(double value) {
    _goalFat = value;
    notifyListeners();
    _persist();
  }

  void setGoalWaterMl(int value) {
    _goalWaterMl = value;
    notifyListeners();
    _persist();
  }

  // ── Accessibility (Phase D) ─────────────────────────────────────────

  void setTextSize(double value) {
    _textSize = value;
    notifyListeners();
    _persist();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
    _persist();
  }

  void setVoiceSensitivity(int value) {
    _voiceSensitivity = value;
    notifyListeners();
    _persist();
  }

  void setAdaptiveAssist(bool value) {
    _adaptiveAssist = value;
    notifyListeners();
    _persist();
  }

  // ── Privacy setters ─────────────────────────────────────────────────

  void setAnonymousAnalytics(bool value) {
    _anonymousAnalytics = value;
    notifyListeners();
    _persist();
  }

  void setGeoTracking(bool value) {
    _geoTracking = value;
    notifyListeners();
    _persist();
  }

  void setAiTrainingModel(bool value) {
    _aiTrainingModel = value;
    notifyListeners();
    _persist();
  }
}
