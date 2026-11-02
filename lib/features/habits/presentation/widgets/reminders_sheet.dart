import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/notifications/reminder_notification_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/habit_providers.dart';
import '../../application/reminder_scheduler.dart';

class RemindersSheet extends ConsumerWidget {
  const RemindersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habits = ref.watch(habitsProvider);
    final reminders = ReminderScheduler.upcoming(habits);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming reminders', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          if (reminders.isEmpty)
            const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No reminders scheduled',
              message: 'Add a reminder time when creating or editing a habit.',
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: reminders.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      reminder.emoji ?? '🎯',
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(reminder.habitName),
                    subtitle: Text(
                      '${DateFormat.EEEE().format(reminder.at)} at '
                      '${DateFormat.jm().format(reminder.at)}',
                    ),
                    trailing: const Icon(Icons.alarm_rounded),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final service = ReminderNotificationService.instance;
                final granted = await service.requestPermission();
                if (!context.mounted) return;
                if (granted) {
                  await service.sync(ref.read(habitsProvider));
                }
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      granted
                          ? 'Habit notifications are enabled.'
                          : 'Notifications are disabled in system settings.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Enable notifications'),
            ),
          ),
        ],
      ),
    );
  }
}
