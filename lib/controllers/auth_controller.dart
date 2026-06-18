import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

/// Auth state for the whole app, now driven by Firebase's actual session
/// state rather than only being set after a manual signIn() call.
///
/// ## What changed vs the old AuthController
/// Previously `user` was only ever assigned inside `signIn()`/`signUp()`.
/// That meant on a cold app start (even with a valid persisted Firebase
/// session) `user` stayed null until the person logged in again — the
/// splash/router had to fall back to checking a Hive token instead.
///
/// Now [_listenToAuthChanges] subscribes to
/// [FirebaseAuthService.authStateChanges] once, in the constructor, and
/// keeps [user] in sync automatically for the lifetime of the app —
/// including on cold start, since Firebase persists its own session.
class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService;
  AuthController(this._authService) {
    _listenToAuthChanges();
  }

  UserModel? user;
  bool isLoading = false;
  String? error;

  /// True once the first authStateChanges event has been processed.
  /// The splash screen waits on this before deciding where to route —
  /// without it, there's a brief window where `user == null` could mean
  /// either "definitely logged out" or "haven't checked yet".
  bool isInitialized = false;

  Future<void> _listenToAuthChanges() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        user = null;
        isInitialized = true;
        notifyListeners();
        return;
      }

      try {
        user = await _authService.fetchUserProfile(firebaseUser);
      } catch (e) {
        error = e.toString();
      } finally {
        isInitialized = true;
        notifyListeners();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.signIn(email, password);
      // _listenToAuthChanges will also fire and re-set `user`, which is
      // fine — it's idempotent. Setting it here too means the UI doesn't
      // wait an extra stream tick before navigating.
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _authService.signUp(name, email, password);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      // user is cleared by the authStateChanges listener automatically.
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      error = e.toString();
      rethrow;
    }
  }

  bool get isEmailVerified => _authService.isEmailVerified;

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
      await FirebaseFirestore.instance.collection('users').doc(user!.id).update({
        'age': age,
        'weight': weight,
        'height': height,
        'objective': objective,
      });

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
      notifyListeners();
    }
  }
}
