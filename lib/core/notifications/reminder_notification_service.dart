import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../data/models/habit.dart';

/// Delivers habit reminders using the operating system's local notification
/// scheduler, so reminders can arrive while the app is closed.
class ReminderNotificationService {
  ReminderNotificationService._();

  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    timezone_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(zone.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = android == null
        ? true
        : await android.requestNotificationsPermission() ?? true;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = ios == null
        ? true
        : await ios.requestPermissions(alert: true, badge: true, sound: true) ??
              true;
    return androidGranted && iosGranted;
  }

  /// Rebuilds a rolling 10-day schedule. The window is refreshed at app
  /// startup/resume and whenever habits change, staying under iOS's pending
  /// notification limit while honoring weekday and interval schedules.
  Future<void> sync(List<Habit> habits) async {
    await initialize();
    await _plugin.cancelAll();

    final now = DateTime.now();
    final scheduled = <({DateTime at, Habit habit})>[];
    for (final habit in habits) {
      final reminderMinutes = habit.schedule.reminderMinutes;
      if (habit.isArchived || reminderMinutes == null) continue;

      for (var offset = 0; offset < 10; offset++) {
        final date = DateTime(now.year, now.month, now.day + offset);
        if (!habit.schedule.shouldDoOn(date) || habit.isCompletedOn(date)) {
          continue;
        }
        final at = DateTime(
          date.year,
          date.month,
          date.day,
          reminderMinutes ~/ 60,
          reminderMinutes % 60,
        );
        if (at.isAfter(now)) scheduled.add((at: at, habit: habit));
      }
    }
    scheduled.sort((a, b) => a.at.compareTo(b.at));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit reminders',
        channelDescription: 'Gentle reminders for your scheduled habits',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final events = scheduled.take(60).toList();
    for (var index = 0; index < events.length; index++) {
      final event = events[index];
      final at = event.at;
      await _plugin.zonedSchedule(
        id: index,
        title: '${event.habit.emoji ?? '🎯'} ${event.habit.name}',
        body: 'Time for your habit',
        scheduledDate: timezone.TZDateTime(
          timezone.local,
          at.year,
          at.month,
          at.day,
          at.hour,
          at.minute,
        ),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
