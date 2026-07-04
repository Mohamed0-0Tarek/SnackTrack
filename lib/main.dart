import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'models/settings_model.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'app.dart';

/// Runs in a separate background isolate when a push arrives while the
/// app is closed or minimized — this isolate does NOT share state with
/// the running app, so Firebase has to be initialized again here from
/// scratch before anything Firebase-related can be used.
///
/// Must stay a top-level (or static) function — instance methods can't
/// be used as a background message handler.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().saveIncomingPush(message);
}

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

  // Must be registered before runApp(), so it's ready to catch a push
  // that arrives while the app is closed or minimized.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const App());
}
