import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_summary_model.dart';
import '../models/meal_model.dart';

/// Firestore-backed meal data layer.
///
/// ## What changed vs the old MealService
/// The old version was pure Dio/REST hitting fake `/meals/*` endpoints —
/// none of it ever worked since there was no backend behind it. This is
/// a full rewrite onto Firestore, matching the agreed schema:
///   users/{uid}/meals/{mealId}
///
/// Every method below requires a signed-in Firebase user — see
/// [_requireUid]. That's intentional: MealService should never be called
/// before auth is ready, and failing loudly here is much easier to debug
/// than a silent permission-denied from Firestore security rules later.
///
/// AI analysis (the old `analyzeMeal`) is intentionally NOT here anymore
/// — that's AiService's job. MealService only owns persistence/reads.
class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception(
        'MealService called with no signed-in user. This should never '
        'happen if auth guards are wired correctly — check that the '
        'caller waited for AuthController.isInitialized.',
      );
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _mealsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('meals');

  /// Writes a new meal document. Returns the meal with its Firestore-
  /// assigned ID attached (the [meal] passed in may have had a temporary
  /// or empty `id` — the returned copy has the real one).
  Future<MealModel> saveMeal(MealModel meal) async {
    final uid = _requireUid();
    final docRef = await _mealsCollection(uid).add(meal.toFirestoreMap());
    final savedDoc = await docRef.get();
    return MealModel.fromFirestore(savedDoc);
  }

  /// Real-time stream of today's meals, ordered newest first.
  /// Dashboard listens to this directly — no polling needed.
  Stream<List<MealModel>> watchTodaysMeals() {
    final uid = _requireUid();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _mealsCollection(uid)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MealModel.fromFirestore).toList());
  }

  /// One-shot fetch of today's meals (for places that don't want a live
  /// stream — e.g. a single aggregate computation).
  Future<List<MealModel>> getTodaysMeals() async {
    final uid = _requireUid();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _mealsCollection(uid)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs.map(MealModel.fromFirestore).toList();
  }

  /// Aggregated summary for a specific day.
  Future<DailySummaryModel> getDailySummary(DateTime date) async {
    final uid = _requireUid();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _mealsCollection(uid)
        .where(
          'loggedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('loggedAt', descending: true)
        .get();

    final meals = snapshot.docs.map(MealModel.fromFirestore).toList();

    final totalCalories = meals.fold<int>(0, (total, meal) => total + meal.calories);
    final totalProtein = meals.fold<double>(0, (total, meal) => total + meal.protein);
    final totalCarbs = meals.fold<double>(0, (total, meal) => total + meal.carbs);
    final totalFat = meals.fold<double>(0, (total, meal) => total + meal.fat);

    return DailySummaryModel(
      date: date,
      totalCalories: totalCalories,
      calorieGoal: 2200,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      meals: meals,
    );
  }

  /// Paginated history fetch, ordered newest-first.
  /// Pass the last document from a previous page as [startAfter] to get
  /// the next page; omit it for the first page.
  Future<List<MealModel>> getMealHistory({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final uid = _requireUid();
    Query<Map<String, dynamic>> query = _mealsCollection(uid)
        .orderBy('loggedAt', descending: true)
        .limit(pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map(MealModel.fromFirestore).toList();
  }

  /// Same as [getMealHistory] but also returns the last raw document
  /// snapshot, so callers can pass it back in as `startAfter` for the
  /// next page without re-querying.
  Future<({List<MealModel> meals, DocumentSnapshot? lastDoc})>
      getMealHistoryPage({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final uid = _requireUid();
    Query<Map<String, dynamic>> query = _mealsCollection(uid)
        .orderBy('loggedAt', descending: true)
        .limit(pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final meals = snapshot.docs.map(MealModel.fromFirestore).toList();
    return (
      meals: meals,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  /// Meals in a date range — used by Phase 7's weekly report and by
  /// history's Week/Month filter chips.
  Future<List<MealModel>> getMealsBetween(DateTime start, DateTime end) async {
    final uid = _requireUid();
    final snapshot = await _mealsCollection(uid)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('loggedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs.map(MealModel.fromFirestore).toList();
  }

  /// Total number of meals ever logged by this user — used by the
  /// profile screen's "entries" stat. Uses Firestore's count() aggregate
  /// so it doesn't pull every document just to count them.
  Future<int> getMealCount() async {
    final uid = _requireUid();
    final snapshot = await _mealsCollection(uid).count().get();
    return snapshot.count ?? 0;
  }

  /// Last 5 distinct meal names, most recent first — feeds the "quick
  /// favorites" chips on the add-meal screen.
  Future<List<String>> getRecentDistinctMealNames({int limit = 5}) async {
    final uid = _requireUid();
    final snapshot = await _mealsCollection(uid)
        .orderBy('loggedAt', descending: true)
        .limit(30) // pull a bit extra since we'll dedupe down to `limit`
        .get();

    final seen = <String>{};
    final names = <String>[];
    for (final doc in snapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null && seen.add(name)) {
        names.add(name);
        if (names.length >= limit) break;
      }
    }
    return names;
  }

  Future<void> deleteMeal(String mealId) async {
    final uid = _requireUid();
    await _mealsCollection(uid).doc(mealId).delete();
  }
}
