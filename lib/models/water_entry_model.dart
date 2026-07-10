import 'package:cloud_firestore/cloud_firestore.dart';

class WaterEntry {
  final String id;
  final int amountMl;
  final DateTime loggedAt;

  WaterEntry({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  factory WaterEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final loggedAtRaw = data['loggedAt'];
    return WaterEntry(
      id: doc.id,
      amountMl: (data['amountMl'] as num?)?.toInt() ?? 250,
      loggedAt: loggedAtRaw is Timestamp
          ? loggedAtRaw.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'amountMl': amountMl,
        'loggedAt': Timestamp.fromDate(loggedAt),
      };
}
