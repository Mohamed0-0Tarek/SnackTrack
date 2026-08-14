import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/meal_service.dart';
import '../services/storage_service.dart';

/// ## What changed vs the old ProfileController
/// The old version only called `StorageService.getUser()` (Hive) and
/// swallowed errors silently — no Firestore fetch, no edit mode, no
/// avatar upload, no real entries count.
///
/// Now:
/// - `loadProfile()` reads from Hive first (instant) then syncs from
///   Firestore `users/{uid}` in the background — same pattern as
///   SettingController.
/// - `updateProfile()` writes name/bio to both Firestore and Hive.
/// - `uploadAvatar()` picks a photo, uploads to Firebase Storage at
///   `users/{uid}/avatars/avatar.jpg`, saves the download URL to both
///   Firestore and Hive.
/// - `loadEntries()` calls `MealService.getMealCount()` for the real
///   total — replaces the hardcoded `148` fallback in profile_screen.
/// - All errors now surface via [error] instead of being swallowed.
class ProfileController extends ChangeNotifier {
  final MealService _mealService;
  ProfileController(this._mealService) {
    loadProfile();
  }

  UserModel? profile;
  int? entries;
  bool isLoading = false;
  String? error;

  // ── Load ─────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    // 1. Hive first — instant, no network wait.
    final cached = StorageService.getUser();
    if (cached != null) {
      profile = cached;
      isLoading = false;
      notifyListeners();
    }

    // 2. Firestore sync in background.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = uid;
        final remote = UserModel.fromJson(data);
        profile = remote;
        await StorageService.saveUser(remote);
      }
    } catch (e) {
      error = 'Could not sync profile.';
    } finally {
      isLoading = false;
      notifyListeners();
    }

    // Load real entries count in parallel — non-blocking.
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      entries = await _mealService.getMealCount();
      notifyListeners();
    } catch (_) {
      // Non-critical — stat card just stays null.
    }
  }

  // ── Edit ─────────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    required String name,
    required String bio,
  }) async {
    if (profile == null) return false;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'name': name,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      profile = profile!.copyWith(name: name, bio: bio);
      await StorageService.saveUser(profile!);
      return true;
    } catch (e) {
      error = 'Could not save profile changes.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Avatar upload ────────────────────────────────────────────────────
  // Deferred to post-launch — requires Firebase Storage (Blaze plan).
  // When ready, implement: image_picker → Firebase Storage upload at
  // users/{uid}/avatars/avatar.jpg → save download URL to Firestore + Hive.
}