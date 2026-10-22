import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/id_x.dart';
import '../../../../data/models/focus_session.dart';
import '../../application/focus_providers.dart';

enum _Phase { focus, shortBreak, longBreak }

class PomodoroTimer extends ConsumerStatefulWidget {
  const PomodoroTimer({super.key});

  @override
  ConsumerState<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends ConsumerState<PomodoroTimer>
    with TickerProviderStateMixin {
  static const _focusMin = 25;
  static const _shortBreak = 5;
  static const _longBreak = 15;

  Timer? _timer;
  _Phase _phase = _Phase.focus;
  int _secondsLeft = _focusMin * 60;
  int _cycle = 0;
  bool _running = false;
  DateTime? _startedAt;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _totalSeconds {
    switch (_phase) {
      case _Phase.focus:
        return _focusMin * 60;
      case _Phase.shortBreak:
        return _shortBreak * 60;
      case _Phase.longBreak:
        return _longBreak * 60;
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.focus:
        return 'Focus Time';
      case _Phase.shortBreak:
        return 'Short Break';
      case _Phase.longBreak:
        return 'Long Break';
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case _Phase.focus:
        return AppColors.focus;
      case _Phase.shortBreak:
        return AppColors.success;
      case _Phase.longBreak:
        return AppColors.habits;
    }
  }

  void _start() {
    _startedAt ??= DateTime.now();
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _onComplete();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _secondsLeft = _totalSeconds;
      _startedAt = null;
    });
  }

  void _onComplete() {
    _timer?.cancel();
    setState(() => _running = false);

    if (_phase == _Phase.focus && _startedAt != null) {
      final elapsed = _focusMin * 60 - _secondsLeft;
      final focusedMin = (elapsed / 60).ceil().clamp(1, _focusMin);
      final session = FocusSession(
        id: newId(),
        startedAt: _startedAt!,
        plannedMinutes: _focusMin,
        focusedMinutes: focusedMin,
        completed: elapsed >= _focusMin * 60 - 1,
        label: 'Pomodoro',
      );
      ref.read(focusSessionsProvider.notifier).record(session);
    }

    if (_phase == _Phase.focus) {
      _cycle++;
      if (_cycle % 4 == 0) {
        _phase = _Phase.longBreak;
        _secondsLeft = _longBreak * 60;
      } else {
        _phase = _Phase.shortBreak;
        _secondsLeft = _shortBreak * 60;
      }
    } else {
      _phase = _Phase.focus;
      _secondsLeft = _focusMin * 60;
      _startedAt = null;
    }
    if (mounted) setState(() {});
  }

  void _skip() {
    _onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    final progress = 1 - (_secondsLeft / _totalSeconds);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _phaseColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text(
            _phaseLabel,
            style: theme.textTheme.labelLarge?.copyWith(color: _phaseColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(_phaseColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$minutes:$seconds',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Cycle ${_cycle + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundBtn(
              icon: Icons.refresh_rounded,
              onTap: _reset,
            ),
            const SizedBox(width: AppSpacing.lg),
            _MainBtn(
              running: _running,
              color: _phaseColor,
              onTap: _running ? _pause : _start,
            ),
            const SizedBox(width: AppSpacing.lg),
            _RoundBtn(
              icon: Icons.skip_next_rounded,
              onTap: _skip,
            ),
          ],
        ),
      ],
    );
  }
}

class _MainBtn extends StatelessWidget {
  const _MainBtn({
    required this.running,
    required this.color,
    required this.onTap,
  });

  final bool running;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          running ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon),
        ),
      ),
    );
  }
}
