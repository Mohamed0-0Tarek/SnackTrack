import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../models/recipe_model.dart';
import '../services/ai_service.dart';

/// Manages the AI coach chat — sending messages, loading conversation
/// history from Firestore, and generating recipes + habit insights.
///
/// ## What changed vs the old AiController
/// Previously all state was in-memory only — closing the AI Coach screen
/// wiped the entire conversation. Now:
/// - [loadConversation] fetches the most recent conversation from
///   `users/{uid}/conversations` when the screen opens, restoring
///   the full message history across app restarts.
/// - [sendMessage] saves every user + assistant message pair to
///   Firestore immediately after the AI responds.
/// - Each conversation is a document under `users/{uid}/conversations`
///   with messages stored as a subcollection, matching the agreed schema.
class AiController extends ChangeNotifier {
  final AiService _aiService;
  AiController(this._aiService);

  List<Map<String, String>> messages = [];
  RecipeModel? recipe;
  List<String>? habitInsights;
  bool isLoading = false;
  bool isLoadingHistory = false;
  String? error;
  String? _activeConversationId;

  // ── Firestore helpers ────────────────────────────────────────────────

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No signed-in user for AiController.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _conversationsRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('conversations');

  /// Loads the most recent conversation from Firestore, ordered by
  /// `updatedAt` descending. Called from AiCoachScreen.initState().
  /// Creates a new conversation document if none exists yet.
  Future<void> loadConversation() async {
    isLoadingHistory = true;
    notifyListeners();
    try {
      final uid = _requireUid();
      final snapshot = await _conversationsRef(uid)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _activeConversationId = doc.id;

        final msgSnapshot = await _conversationsRef(uid)
            .doc(doc.id)
            .collection('messages')
            .orderBy('createdAt')
            .get();

        messages = msgSnapshot.docs.map((m) {
          final data = m.data();
          return {
            'role': data['role'] as String,
            'content': data['content'] as String,
          };
        }).toList();
      } else {
        // No conversation yet — create one now so we have an id ready.
        _activeConversationId = await _createNewConversation(uid);
      }
    } catch (e) {
      // Non-critical — start with empty messages if history fails.
      error = 'Could not load conversation history.';
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<String> _createNewConversation(String uid) async {
    final doc = await _conversationsRef(uid).add({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // ── Messaging ────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final userMsg = {'role': 'user', 'content': text};
    messages = [...messages, userMsg];
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Use last 10 messages as context to stay within token limits.
      final context = messages.length > 10
          ? messages.sublist(messages.length - 10)
          : List<Map<String, String>>.from(messages);

      final reply = await _aiService.chat(context);
      final assistantMsg = {'role': 'assistant', 'content': reply};
      messages = [...messages, assistantMsg];

      // Persist both messages to Firestore.
      await _persistMessages([userMsg, assistantMsg]);
    } catch (e) {
      error = 'Could not get a response. Check your connection and try again.';
      // Remove the optimistically-added user message on failure.
      messages = messages.sublist(0, messages.length - 1);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistMessages(List<Map<String, String>> msgs) async {
    try {
      final uid = _requireUid();
      _activeConversationId ??= await _createNewConversation(uid);

      final batch = FirebaseFirestore.instance.batch();
      final convRef = _conversationsRef(uid).doc(_activeConversationId);

      for (final msg in msgs) {
        final msgRef = convRef.collection('messages').doc();
        batch.set(msgRef, {
          'role': msg['role'],
          'content': msg['content'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Update `updatedAt` on the parent conversation doc so the
      // "most recent conversation" query in loadConversation() stays
      // correct.
      batch.update(convRef, {'updatedAt': FieldValue.serverTimestamp()});
      await batch.commit();
    } catch (_) {
      // Persistence failure is non-critical — the message was sent and
      // received successfully, just not saved. Don't surface to user.
    }
  }

  // ── Clear & start fresh ─────────────────────────────────────────────

  Future<void> clearChat() async {
    messages = [];
    _activeConversationId = null;
    error = null;
    notifyListeners();
    // Create a fresh conversation doc for next session.
    try {
      _activeConversationId = await _createNewConversation(_requireUid());
    } catch (_) {}
  }

  // ── Recipe generation ────────────────────────────────────────────────

  Future<void> generateRecipe(String prompt) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      recipe = await _aiService.generateRecipe(prompt);

      // Save to users/{uid}/recipes per the shared Firestore schema.
      final uid = _requireUid();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recipes')
          .add({
        'name': recipe!.name,
        'ingredients': recipe!.ingredients,
        'steps': recipe!.steps,
        'calories': recipe!.calories,
        'protein': recipe!.protein,
        'carbs': recipe!.carbs,
        'fat': recipe!.fat,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      error = 'Could not generate recipe. Try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Habit insights ───────────────────────────────────────────────────

  Future<void> loadHabitInsights(List<MealModel> weeklyMeals) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      habitInsights = await _aiService.getHabitInsights(weeklyMeals);
    } catch (e) {
      error = 'Could not load insights.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
