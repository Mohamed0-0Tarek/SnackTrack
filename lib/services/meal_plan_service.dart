import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_plan_model.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('MealPlanService called with no signed-in user.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _plansRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('mealPlans');

  Future<MealPlanModel> savePlan(MealPlanModel plan) async {
    final uid = _requireUid();
    final docRef = await _plansRef(uid).add(plan.toFirestoreMap());
    final saved = await docRef.get();
    return MealPlanModel.fromFirestore(saved);
  }

  Future<List<MealPlanModel>> getPlans() async {
    final uid = _requireUid();
    final snapshot = await _plansRef(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(MealPlanModel.fromFirestore).toList();
  }

  Future<void> deletePlan(String planId) async {
    final uid = _requireUid();
    await _plansRef(uid).doc(planId).delete();
  }
}
