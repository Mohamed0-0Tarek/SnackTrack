import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class MealTime {
  final int hour;
  final int minute;

  const MealTime(this.hour, this.minute);

  String toTimeString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  factory MealTime.fromTimeString(String s) {
    final parts = s.split(':');
    return MealTime(
      int.tryParse(parts[0]) ?? 8,
      int.tryParse(parts[1]) ?? 0,
    );
  }
}

class MealReminderService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _defaultChannelId = 'meal_reminders_channel';
  static const String _channelName = 'Meal Reminders';
  static const String _channelDescription =
      'Reminds you to log your meals at set times.';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    // Note: tz_data.initializeTimeZones() and tz.setLocalLocation() are
    // called in main.dart before this runs — do not call them here again.

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings: initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _defaultChannelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    ));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static const Map<String, int> _mealIds = {
    'breakfast': 101,
    'lunch': 102,
    'dinner': 103,
    'snack': 104,
  };

  String _mealLabel(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return mealType;
    }
  }

  Future<void> scheduleMealReminders(Map<String, String> times) async {
    await init();
    await cancelAll();

    final now = DateTime.now();
    debugPrint('[MealReminder] Scheduling reminders. Local now=$now');

    for (final entry in times.entries) {
      final mealType = entry.key;
      final mealTime = MealTime.fromTimeString(entry.value);
      final id = _mealIds[mealType] ?? 100;

      // Build the target time for TODAY in local time.
      var scheduledLocal = DateTime(
        now.year,
        now.month,
        now.day,
        mealTime.hour,
        mealTime.minute,
      );

      // If the time has already passed today, schedule for tomorrow.
      // Without this check, the notification would either fire immediately
      // (if the OS schedules past times right away) or not at all.
      if (scheduledLocal.isBefore(now)) {
        scheduledLocal = scheduledLocal.add(const Duration(days: 1));
        debugPrint(
            '[MealReminder] $mealType time already passed today, scheduling for tomorrow');
      }

      // Convert to TZDateTime using the device's local timezone.
      final tzLocal = tz.local;
      final tzScheduled = tz.TZDateTime(
        tzLocal,
        scheduledLocal.year,
        scheduledLocal.month,
        scheduledLocal.day,
        scheduledLocal.hour,
        scheduledLocal.minute,
      );

      debugPrint('[MealReminder] $mealType (id=$id) -> $tzScheduled');

      try {
        await _plugin.zonedSchedule(
          id: id,
          title: _mealLabel(mealType),
          body: 'Time to log your ${_mealLabel(mealType)} food!',
          scheduledDate: tzScheduled,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // matchDateTimeComponents: DateTimeComponents.time repeats daily.
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('[MealReminder] $mealType scheduled OK at $tzScheduled');
      } catch (e) {
        debugPrint('[MealReminder] $mealType FAILED: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelMeal(String mealType) async {
    final id = _mealIds[mealType];
    if (id != null) {
      await _plugin.cancel(id: id);
    }
  }
}
