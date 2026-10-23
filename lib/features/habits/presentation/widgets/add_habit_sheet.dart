import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/id_x.dart';
import '../../../../data/models/habit.dart';
import '../../application/habit_providers.dart';

class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key});

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '10');
  HabitProgressKind _kind = HabitProgressKind.checkbox;
  String _emoji = '🎯';
  final Set<Weekday> _weekdays = <Weekday>{};
  TimeOfDayFilter _timeOfDay = TimeOfDayFilter.any;
  TimeOfDay? _reminder;
  int _intervalDays = 1;

  static const _emojis = ['🎯', '💧', '📚', '🏋️', '🧘', '😴', '🍎', '💊', '🧹', '💻'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('New habit', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'e.g. Morning workout',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Icon', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final e in _emojis)
                  GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _emoji == e
                            ? theme.colorScheme.primary.withValues(alpha: 0.16)
                            : theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: _emoji == e
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<HabitProgressKind>(
              segments: const [
                ButtonSegment(
                  value: HabitProgressKind.checkbox,
                  label: Text('Check'),
                  icon: Icon(Icons.check_box_outlined),
                ),
                ButtonSegment(
                  value: HabitProgressKind.counter,
                  label: Text('Count'),
                  icon: Icon(Icons.add_circle_outline_rounded),
                ),
                ButtonSegment(
                  value: HabitProgressKind.duration,
                  label: Text('Timer'),
                  icon: Icon(Icons.timer_outlined),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
              showSelectedIcon: false,
            ),
            if (_kind == HabitProgressKind.duration) ...[
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target duration (minutes)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (_kind == HabitProgressKind.counter) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Unit (optional)',
                        hintText: 'pages, glasses',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('Schedule', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<TimeOfDayFilter>(
              segments: const [
                ButtonSegment(value: TimeOfDayFilter.any, label: Text('Anytime')),
                ButtonSegment(
                    value: TimeOfDayFilter.morning, label: Text('Morning')),
                ButtonSegment(
                    value: TimeOfDayFilter.afternoon,
                    label: Text('Afternoon')),
                ButtonSegment(
                    value: TimeOfDayFilter.evening, label: Text('Evening')),
              ],
              selected: {_timeOfDay},
              onSelectionChanged: (s) =>
                  setState(() => _timeOfDay = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final day in Weekday.values)
                  FilterChip(
                    label: Text(day.name.substring(0, 2).toUpperCase()),
                    selected: _weekdays.contains(day),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _weekdays.add(day);
                      } else {
                        _weekdays.remove(day);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Daily')),
                ButtonSegment(value: 2, label: Text('Every 2d')),
                ButtonSegment(value: 3, label: Text('Every 3d')),
              ],
              selected: {_intervalDays},
              onSelectionChanged: (s) =>
                  setState(() => _intervalDays = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              icon: const Icon(Icons.alarm_rounded, size: 18),
              label: Text(
                _reminder == null
                    ? 'Add reminder'
                    : 'Reminder at ${_reminder!.format(context)}',
              ),
              onPressed: _pickReminder,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Create habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _reminder = picked);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final target = int.tryParse(_targetCtrl.text.trim()) ?? 1;
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 10;
    final unit = _unitCtrl.text.trim();
    final habit = Habit(
      id: newId(),
      name: name,
      emoji: _emoji,
      progressType: _kind == HabitProgressKind.checkbox
          ? HabitProgressType.checkbox
          : HabitProgressType.counter,
      progressKind: _kind,
      target: _kind == HabitProgressKind.counter ? target.clamp(1, 999) : 1,
      unit: _kind == HabitProgressKind.counter && unit.isNotEmpty ? unit : null,
      durationMinutesTarget:
          _kind == HabitProgressKind.duration ? duration.clamp(1, 600) : 0,
      schedule: HabitSchedule(
        timeOfDay: _timeOfDay,
        weekdays: Set<Weekday>.from(_weekdays),
        reminderMinutes: _reminder == null
            ? null
            : _reminder!.hour * 60 + _reminder!.minute,
        intervalDays: _intervalDays,
      ),
      createdAt: DateTime.now(),
    );
    ref.read(habitsProvider.notifier).upsert(habit);
    Navigator.of(context).pop();
  }
}
