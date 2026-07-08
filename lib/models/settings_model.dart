import 'package:hive/hive.dart';

part 'settings_model.g.dart';

/// User-configurable app settings, cached locally in Hive and synced to
/// Firestore (`users/{uid}/settings/preferences`) by SettingController.
///
/// typeId 1. After adding new @HiveField entries, run:
///   flutter packages pub run build_runner build --delete-conflicting-outputs
@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool darkMode;

  @HiveField(1)
  double notifFrequency; // 0=Quiet, 1=Standard, 2=Frequent

  @HiveField(2)
  bool incognito;

  @HiveField(3)
  int goalCalories;

  @HiveField(4)
  double goalProtein;

  @HiveField(5)
  double goalCarbs;

  @HiveField(6)
  double goalFat;

  // ── Accessibility (Phase D) ───────────────────────────────────────────
  @HiveField(7)
  double textSize; // 0=Compact, 1=Standard, 2=Enlarged

  @HiveField(8)
  bool highContrast;

  @HiveField(9)
  int voiceSensitivity; // 0=Quiet, 1=Balanced, 2=Highly Reactive

  @HiveField(10)
  bool adaptiveAssist;

  // ── Privacy (Phase E) ─────────────────────────────────────────────────
  @HiveField(11)
  bool anonymousAnalytics;

  @HiveField(12)
  bool geoTracking;

  @HiveField(13)
  bool aiTrainingModel;

  SettingsModel({
    this.darkMode = false,
    this.notifFrequency = 1,
    this.incognito = false,
    this.goalCalories = 2000,
    this.goalProtein = 150,
    this.goalCarbs = 250,
    this.goalFat = 65,
    this.textSize = 1,
    this.highContrast = false,
    this.voiceSensitivity = 1,
    this.adaptiveAssist = false,
    this.anonymousAnalytics = true,
    this.geoTracking = false,
    this.aiTrainingModel = true,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        darkMode: json['darkMode'] ?? false,
        notifFrequency: (json['notifFrequency'] as num?)?.toDouble() ?? 1,
        incognito: json['incognito'] ?? false,
        goalCalories: json['goalCalories'] ?? 2000,
        goalProtein: (json['goalProtein'] as num?)?.toDouble() ?? 150,
        goalCarbs: (json['goalCarbs'] as num?)?.toDouble() ?? 250,
        goalFat: (json['goalFat'] as num?)?.toDouble() ?? 65,
        textSize: (json['textSize'] as num?)?.toDouble() ?? 1,
        highContrast: json['highContrast'] ?? false,
        voiceSensitivity: json['voiceSensitivity'] ?? 1,
        adaptiveAssist: json['adaptiveAssist'] ?? false,
        anonymousAnalytics: json['anonymousAnalytics'] ?? true,
        geoTracking: json['geoTracking'] ?? false,
        aiTrainingModel: json['aiTrainingModel'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'notifFrequency': notifFrequency,
        'incognito': incognito,
        'goalCalories': goalCalories,
        'goalProtein': goalProtein,
        'goalCarbs': goalCarbs,
        'goalFat': goalFat,
        'textSize': textSize,
        'highContrast': highContrast,
        'voiceSensitivity': voiceSensitivity,
        'adaptiveAssist': adaptiveAssist,
        'anonymousAnalytics': anonymousAnalytics,
        'geoTracking': geoTracking,
        'aiTrainingModel': aiTrainingModel,
      };
}
