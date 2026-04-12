import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class ProfileController extends ChangeNotifier {
  UserModel? profile;
  bool isLoading = false;

  void loadFromStorage() {
    final data = StorageService.getUser();
    if (data != null) {
      profile = UserModel.fromJson(Map<String, dynamic>.from(data));
      notifyListeners();
    }
  }
}
