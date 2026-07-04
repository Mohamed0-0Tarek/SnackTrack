import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

/// Firestore-backed notifications layer.
/// Schema: users/{uid}/notifications/{notifId} — see NotifItem for fields.
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception(
        'NotificationService called with no signed-in user. This should '
        'never happen if auth guards are wired correctly — check that the '
        'caller waited for AuthController.isInitialized.',
      );
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _notifsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  /// Real-time stream of all notifications, newest first. The screen
  /// splits this into Today/Previous buckets client-side via
  /// [NotifItem.isToday].
  Stream<List<NotifItem>> watchNotifications() {
    final uid = _requireUid();
    return _notifsCollection(uid)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(NotifItem.fromFirestore).toList());
  }

  Future<void> markAsRead(String notifId) async {
    final uid = _requireUid();
    await _notifsCollection(uid).doc(notifId).update({'isUnread': false});
  }

  /// Batch-marks every id in [notifIds] as read — used by "Mark all read".
  Future<void> markAllAsRead(List<String> notifIds) async {
    if (notifIds.isEmpty) return;
    final uid = _requireUid();
    final batch = _firestore.batch();
    for (final id in notifIds) {
      batch.update(_notifsCollection(uid).doc(id), {'isUnread': false});
    }
    await batch.commit();
  }

  /// Persists/refreshes this device's FCM token on the user's profile doc.
  /// Called by FcmService on init and whenever the token rotates.
  Future<void> saveFcmToken(String token) async {
    final uid = _requireUid();
    await _firestore.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  /// Turns a received FCM push into a real notification document, so it
  /// shows up in the app's Activity Feed the same way any other
  /// notification does. Called from both the foreground listener
  /// (fcm_service.dart) and the background handler (main.dart) — those
  /// are two separate code paths that both funnel into this one method
  /// so the save logic only lives in one place.
  ///
  /// Silently does nothing if there's no signed-in user — this can
  /// happen in the background-isolate case if a push arrives right as
  /// someone signs out.
  Future<void> saveIncomingPush(RemoteMessage message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = message.data;
    final tagsRaw = data['tags'] as String?;

    await _notifsCollection(uid).add({
      'title': message.notification?.title ?? data['title'] ?? 'Notification',
      'body': message.notification?.body ?? data['body'] ?? '',
      'time': Timestamp.now(),
      'tags': (tagsRaw == null || tagsRaw.isEmpty)
          ? <String>[]
          : tagsRaw.split(','),
      'isUnread': true,
      'type': data['type'] ?? 'system',
    });
  }
}
