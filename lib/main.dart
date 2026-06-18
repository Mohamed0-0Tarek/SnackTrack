import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'models/settings_model.dart';
import 'services/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Hive's underlying engine first, then register the typed
  //    adapters BEFORE opening any typed boxes — StorageService.init()
  //    opens Box<UserModel> and Box<SettingsModel>, which will throw if
  //    the adapters aren't registered yet.
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // 2. Now safe to open the typed boxes.
  await StorageService.init();

  // 3. Firebase, unchanged.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}
