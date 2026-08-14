import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('RecipeService called with no signed-in user.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _recipesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('recipes');

  Future<RecipeModel> saveRecipe(RecipeModel recipe) async {
    final uid = _requireUid();
    final docRef = await _recipesRef(uid).add(recipe.toFirestoreMap());
    final saved = await docRef.get();
    return RecipeModel.fromFirestore(saved);
  }

  Future<List<RecipeModel>> getRecipes() async {
    final uid = _requireUid();
    final snapshot = await _recipesRef(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(RecipeModel.fromFirestore).toList();
  }

  Future<RecipeModel?> getRecipe(String recipeId) async {
    final uid = _requireUid();
    final doc = await _recipesRef(uid).doc(recipeId).get();
    if (!doc.exists) return null;
    return RecipeModel.fromFirestore(doc);
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    final uid = _requireUid();
    await _recipesRef(uid).doc(recipe.id).set(recipe.toFirestoreMap());
  }

  Future<void> deleteRecipe(String recipeId) async {
    final uid = _requireUid();
    await _recipesRef(uid).doc(recipeId).delete();
  }
}
