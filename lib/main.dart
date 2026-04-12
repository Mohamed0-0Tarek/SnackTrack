import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const App());
}
