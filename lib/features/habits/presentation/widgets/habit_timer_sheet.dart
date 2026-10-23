import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/habit.dart';
import '../../application/habit_providers.dart';

/// Runs a stopwatch for a [HabitProgressKind.duration] habit and records the
/// elapsed minutes when stopped.
class HabitTimerSheet extends ConsumerStatefulWidget {
  const HabitTimerSheet({
    super.key,
    required this.habit,
    required this.date,
  });

  final Habit habit;
  final DateTime date;

  @override
  ConsumerState<HabitTimerSheet> createState() => _HabitTimerSheetState();
}

class _HabitTimerSheetState extends ConsumerState<HabitTimerSheet> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      _save();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _elapsedSeconds++);
      });
    }
    setState(() => _running = !_running);
  }

  void _save() {
    final minutes = (_elapsedSeconds / 60).floor();
    if (minutes <= 0) return;
    ref.read(habitsProvider.notifier).addMinutes(
          widget.habit,
          widget.date,
          minutes,
        );
  }

  String get _display {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = widget.habit;
    final progress = habit.progressOn(widget.date);

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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(habit.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Target: ${habit.effectiveTarget} min  ·  Done: $progress min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  _display,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: FilledButton(
                    onPressed: _toggle,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(
                      _running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
