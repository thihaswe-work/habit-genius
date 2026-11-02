import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/hive_adapters.dart';
import 'data/local/repositories/hive_habit_repository.dart';
import 'data/local/hive_service.dart';
import 'core/notifications/reminder_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  registerHiveAdapters();
  await HiveService.init();

  final notifications = ReminderNotificationService.instance;
  try {
    await notifications.initialize();
    await notifications.sync(
      HiveHabitRepository(HiveService.instance.box('habits')).getActive(),
    );
  } catch (_) {
    // Notification setup must never prevent the habit tracker from opening.
  }

  runApp(const ProviderScope(child: HabitGeniusApp()));
}
