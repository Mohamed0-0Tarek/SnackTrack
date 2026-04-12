import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  AuthController(this._authService);

  UserModel? user;
  bool   isLoading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      user = await _authService.login(email, password);
      return true;
    } catch (e) {
      error = 'Login failed. Check your credentials.';
      return false;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      user = await _authService.signup(name, email, password);
      return true;
    } catch (e) {
      error = 'Signup failed. Please try again.';
      return false;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}
