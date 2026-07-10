import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/water_entry_model.dart';

class WaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('WaterService called with no signed-in user.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _waterCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('water');

  Future<WaterEntry> logWater(int amountMl) async {
    final uid = _requireUid();
    final docRef = await _waterCollection(uid).add({
      'amountMl': amountMl,
      'loggedAt': FieldValue.serverTimestamp(),
    });
    final savedDoc = await docRef.get();
    return WaterEntry.fromFirestore(savedDoc);
  }

  Future<List<WaterEntry>> getTodaysWater() async {
    final uid = _requireUid();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _waterCollection(uid)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs.map(WaterEntry.fromFirestore).toList();
  }

  Stream<List<WaterEntry>> watchTodaysWater() {
    final uid = _requireUid();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _waterCollection(uid)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(WaterEntry.fromFirestore).toList());
  }

  Future<void> deleteEntry(String entryId) async {
    final uid = _requireUid();
    await _waterCollection(uid).doc(entryId).delete();
  }
}
