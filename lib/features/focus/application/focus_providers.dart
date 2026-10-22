import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../../../data/models/focus_session.dart';
import '../../../data/repositories/repository_providers.dart';

/// All recorded focus sessions, newest first.
final focusSessionsProvider =
    NotifierProvider<FocusSessionsNotifier, List<FocusSession>>(
  FocusSessionsNotifier.new,
);

/// Minutes focused today.
final todayFocusMinutesProvider = Provider<int>((Ref ref) {
  final sessions = ref.watch(focusSessionsProvider);
  final today = DateTime.now();
  return sessions
      .where((FocusSession s) => s.startedAt.isSameDay(today))
      .fold<int>(0, (int sum, FocusSession s) => sum + s.focusedMinutes);
});

/// Number of completed pomodoros today.
final todayCompletedSessionsProvider = Provider<int>((Ref ref) {
  final sessions = ref.watch(focusSessionsProvider);
  final today = DateTime.now();
  return sessions
      .where((FocusSession s) => s.startedAt.isSameDay(today) && s.completed)
      .length;
});

/// Manages focus sessions.
class FocusSessionsNotifier extends Notifier<List<FocusSession>> {
  @override
  List<FocusSession> build() => ref.read(focusRepositoryProvider).getAll();

  /// Stores a finished (or abandoned) session.
  Future<void> record(FocusSession session) async {
    final repository = ref.read(focusRepositoryProvider);
    await repository.save(session);
    state = repository.getAll();
  }

  /// Removes a session.
  Future<void> delete(String id) async {
    final repository = ref.read(focusRepositoryProvider);
    await repository.delete(id);
    state = repository.getAll();
  }
}
