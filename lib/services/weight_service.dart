import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weight_entry_model.dart';

class WeightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('WeightService called with no signed-in user.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _weightCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('weights');

  Future<WeightEntry> logWeight(double weightKg, {String? notes}) async {
    final uid = _requireUid();
    final docRef = await _weightCollection(uid).add({
      'weightKg': weightKg,
      'loggedAt': FieldValue.serverTimestamp(),
      if (notes != null) 'notes': notes,
    });
    final savedDoc = await docRef.get();
    return WeightEntry.fromFirestore(savedDoc);
  }

  Future<List<WeightEntry>> getHistory({int? limit}) async {
    final uid = _requireUid();
    var query = _weightCollection(uid).orderBy('loggedAt', descending: true);
    if (limit != null) query = query.limit(limit);
    final snapshot = await query.get();
    return snapshot.docs.map(WeightEntry.fromFirestore).toList();
  }

  Future<WeightEntry?> getLastEntryBefore(DateTime date) async {
    final uid = _requireUid();
    final snapshot = await _weightCollection(uid)
        .where('loggedAt', isLessThan: Timestamp.fromDate(date))
        .orderBy('loggedAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return WeightEntry.fromFirestore(snapshot.docs.first);
  }

  Future<void> deleteEntry(String entryId) async {
    final uid = _requireUid();
    await _weightCollection(uid).doc(entryId).delete();
  }
}
