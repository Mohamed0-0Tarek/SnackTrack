import 'package:hive/hive.dart';

part 'settings_model.g.dart';

/// User-configurable app settings, cached locally in Hive and synced to
/// Firestore (`users/{uid}/settings`) by SettingController.
///
/// typeId 1 is used here — make sure no other HiveObject in the project
/// claims typeId 1 (UserModel's adapter, added alongside StorageService,
/// should use a different typeId, e.g. 0).
///
/// NOTE: after adding this file, run:
///   flutter packages pub run build_runner build
/// to generate settings_model.g.dart (the HiveTypeAdapter). This file
/// won't compile until that's been generated once.
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

  SettingsModel({
    this.darkMode = false,
    this.notifFrequency = 1,
    this.incognito = false,
    this.goalCalories = 2000,
    this.goalProtein = 150,
    this.goalCarbs = 250,
    this.goalFat = 65,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        darkMode: json['darkMode'] ?? false,
        notifFrequency: (json['notifFrequency'] as num?)?.toDouble() ?? 1,
        incognito: json['incognito'] ?? false,
        goalCalories: json['goalCalories'] ?? 2000,
        goalProtein: (json['goalProtein'] as num?)?.toDouble() ?? 150,
        goalCarbs: (json['goalCarbs'] as num?)?.toDouble() ?? 250,
        goalFat: (json['goalFat'] as num?)?.toDouble() ?? 65,
      );

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'notifFrequency': notifFrequency,
        'incognito': incognito,
        'goalCalories': goalCalories,
        'goalProtein': goalProtein,
        'goalCarbs': goalCarbs,
        'goalFat': goalFat,
      };
}
