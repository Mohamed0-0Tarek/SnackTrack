import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for direct Firestore orchestration
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  AuthController(this._authService);

  UserModel? user;
  bool   isLoading = false;
  String? error;

  /// Communicates with AuthService to execute user login.
  Future<void> signIn(String email, String password) async {
    isLoading = true; 
    error = null; 
    notifyListeners();
    
    try {
      user = await _authService.login(email, password);
    } catch (e) {
      error = e.toString();
      // Rethrow lets the UI's local try-catch intercept the error 
      // and present an accurate SnackBar message to the user.
      rethrow; 
    } finally {
      isLoading = false; 
      notifyListeners();
    }
  }

  /// Communicates with AuthService to create a new user profile document.
  Future<void> signUp(String name, String email, String password) async {
    isLoading = true; 
    error = null; 
    notifyListeners();
    
    try {
      user = await _authService.signup(name, email, password);
    } catch (e) {
      error = e.toString();
      rethrow; 
    } finally {
      isLoading = false; 
      notifyListeners();
    }
  }

  /// Terminates user active session cleanly.
  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      user = null;
      error = null;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Synchronizes physiological statistics and primary objective metrics
  /// across both Cloud Firestore and local in-memory application states.
  Future<void> synchronizeOnboardingProfile({
    required int age,
    required double weight,
    required double height,
    required String objective,
  }) async {
    if (user == null) {
      throw Exception('Active session metadata not found. Please log in again.');
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // 1. Mutate the targeted document properties on the remote cloud database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.id)
          .update({
        'age': age,
        'weight': weight,
        'height': height,
        'objective': objective,
      });

      // 2. Clone and update the local state memory model using copyWith
      user = user!.copyWith(
        age: age,
        weight: weight,
        height: height,
        objective: objective,
      );
      
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      // 3. Inform the GoRouter refreshListenable middle layer that state has changed,
      notifyListeners();
    }
  }
}