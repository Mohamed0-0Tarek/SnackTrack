import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/settings_model.dart';

/// Typed local storage on top of Hive.
///
/// ## What changed vs the old StorageService
/// The old version stored raw tokens and a `Map` for the user
/// (`saveToken`, `getToken`, `saveUser(Map)`). That's gone — auth state
/// is now owned entirely by Firebase (see FirebaseAuthService /
/// AuthController), so there's no token to cache here anymore.
///
/// What this DOES cache locally, for instant-load-then-sync patterns:
/// - [UserModel] — so ProfileController can show something immediately
///   on app start before the Firestore fetch completes.
/// - [SettingsModel] — so SettingController can apply dark mode / goals
///   instantly without waiting on a network round trip.
///
/// Two separate Hive boxes are used (one per type) rather than one mixed
/// box, since `Hive.openBox<T>` is cleanly typed that way and avoids
/// runtime casts.
class StorageService {
  static const String _userBoxName = 'user_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _mealCacheBoxName = 'meal_cache';

  static const String _userKey = 'current_user';
  static const String _settingsKey = 'current_settings';

  static late Box<UserModel> _userBox;
  static late Box<SettingsModel> _settingsBox;
  static late Box _mealCacheBox;

  /// Call once in main.dart, AFTER Hive.initFlutter() and AFTER
  /// registering adapters:
  ///   await Hive.initFlutter();
  ///   Hive.registerAdapter(UserModelAdapter());
  ///   Hive.registerAdapter(SettingsModelAdapter());
  ///   await StorageService.init();
  static Future<void> init() async {
    _userBox = await Hive.openBox<UserModel>(_userBoxName);
    _settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);
    _mealCacheBox = await Hive.openBox(_mealCacheBoxName);
  }

  // ── User ─────────────────────────────────────────────────────────────

  static Future<void> saveUser(UserModel user) => _userBox.put(_userKey, user);

  static UserModel? getUser() => _userBox.get(_userKey);

  static Future<void> clearUser() => _userBox.delete(_userKey);

  // ── Settings ─────────────────────────────────────────────────────────

  static Future<void> saveSettings(SettingsModel settings) =>
      _settingsBox.put(_settingsKey, settings);

  static SettingsModel? getSettings() => _settingsBox.get(_settingsKey);

  // ── Meal cache (used by Phase 5 — offline history fallback) ────────────

  static Future<void> saveMealCache(String key, dynamic jsonData) =>
      _mealCacheBox.put(key, jsonData);

  static dynamic getMealCache(String key) => _mealCacheBox.get(key);

  // ── Full wipe (used on logout) ──────────────────────────────────────

  /// Clears everything cached locally. Call this from
  /// AuthController.logout() / the profile logout flow, AFTER
  /// FirebaseAuth.signOut() succeeds.
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _settingsBox.clear();
    await _mealCacheBox.clear();
  }
}
