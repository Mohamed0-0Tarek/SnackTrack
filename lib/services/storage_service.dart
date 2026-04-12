import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'user_data';
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('nutrifit_box');
  }

  static Future<void> saveToken(String token) => _box.put(_tokenKey, token);
  static String?       getToken()              => _box.get(_tokenKey);
  static Future<void>  clearToken()            => _box.delete(_tokenKey);

  static Future<void> saveUser(Map<String, dynamic> user) => _box.put(_userKey, user);
  static Map?          getUser()                           => _box.get(_userKey);
  static Future<void>  clearAll()                          => _box.clear();
}
