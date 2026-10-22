/// Date helpers shared by models, repositories and the UI.
extension DateX on DateTime {
  /// Midnight-normalised copy of this date (drops the time component).
  DateTime get dayOnly => DateTime(year, month, day);

  /// Stable `yyyy-MM-dd` key used to index per-day records.
  String get dayKey {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Days elapsed from [other] to this date (positive when in the future).
  int daysSince(DateTime other) =>
      dayOnly.difference(other.dayOnly).inDays;
}

/// Returns the `yyyy-MM-dd` key for [date].
String dayKeyOf(DateTime date) => date.dayKey;
