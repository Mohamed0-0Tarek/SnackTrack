import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class ProfileController extends ChangeNotifier {
  UserModel? profile;
  bool isLoading = false;

  ProfileController() {
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = StorageService.getUser();
      if (data != null) {
        profile = UserModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // Handle error silently or log if needed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
