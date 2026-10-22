import '../models/focus_session.dart';

/// Persistence contract for focus (Pomodoro) sessions.
abstract interface class FocusRepository {
  /// All recorded sessions, newest first.
  List<FocusSession> getAll();

  /// Stores a finished session.
  Future<void> save(FocusSession session);

  /// Removes the session with [id].
  Future<void> delete(String id);

  /// Total focused minutes across sessions started on [date].
  int focusedMinutesOn(DateTime date);
}
