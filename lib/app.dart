import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/reminder_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/models/habit.dart';
import 'features/habits/application/habit_providers.dart';

/// Root widget: wires the router and the theming.
class HabitGeniusApp extends ConsumerStatefulWidget {
  const HabitGeniusApp({super.key});

  @override
  ConsumerState<HabitGeniusApp> createState() => _HabitGeniusAppState();
}

class _HabitGeniusAppState extends ConsumerState<HabitGeniusApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncReminders(ref.read(habitsProvider)));
    }
  }

  Future<void> _syncReminders(List<Habit> habits) async {
    try {
      await ReminderNotificationService.instance.sync(habits);
    } catch (_) {
      // Keep reminder delivery failures from interrupting normal app use.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(habitsProvider, (previous, next) {
      unawaited(_syncReminders(next));
    });
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Habit Genius',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
