import 'package:cloud_firestore/cloud_firestore.dart';

class WeightEntry {
  final String id;
  final double weightKg;
  final DateTime loggedAt;
  final String? notes;

  WeightEntry({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
    this.notes,
  });

  factory WeightEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final loggedAtRaw = data['loggedAt'];
    return WeightEntry(
      id: doc.id,
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      loggedAt: loggedAtRaw is Timestamp
          ? loggedAtRaw.toDate()
          : DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'weightKg': weightKg,
        'loggedAt': Timestamp.fromDate(loggedAt),
        if (notes != null) 'notes': notes,
      };
}
