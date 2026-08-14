import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

/// Handles push-notification client plumbing: permission request,
/// device-token registration, and the foreground message listener.
///
/// This does NOT write notification documents into Firestore itself —
/// that happens server-side (e.g. a Cloud Function) whenever something
/// notification-worthy happens. FcmService's only job is making sure
/// this device can actually receive those pushes once they're sent, and
/// keeping users/{uid}.fcmToken current.
///
/// Wiring: call [init] once after a user signs in — mirror how
/// SettingController.loadSettings() is re-triggered from
/// AuthController's listener in app.dart, since a token save requires a
/// signed-in uid.
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications',
    description: 'Used for important notifications shown while the app is open.',
    importance: Importance.high,
  );

  FcmService(this._notificationService);

  Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // User declined — respect it, nothing more to wire up.
      return;
    }

    await _initLocalNotifications();

    final token = await _messaging.getToken();
    if (token != null) {
      await _notificationService.saveFcmToken(token);
    }

    // Tokens rotate (reinstall, app data clear, etc.) — keep Firestore
    // in sync whenever that happens.
    _messaging.onTokenRefresh.listen(_notificationService.saveFcmToken);

    // Foreground pushes don't show anything by default on either
    // platform — Android/iOS only auto-display a banner when the app is
    // backgrounded or closed. So while the app is open we do two things
    // ourselves: save it into Firestore (for the Activity Feed) and show
    // a real system banner via flutter_local_notifications (so the user
    // sees something even while actively using the app).
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _notificationService.saveIncomingPush(message);
      await _showForegroundBanner(message);
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(settings: initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _showForegroundBanner(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
