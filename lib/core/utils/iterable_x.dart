/// Small collection helpers so feature code stays free of boilerplate loops.
extension IterableX<T> on Iterable<T> {
  /// Returns the first element matching [test], or `null` when there is none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns the element with the largest [value], or `null` when empty.
  T? maxBy(double Function(T element) value) {
    T? best;
    double? bestValue;
    for (final element in this) {
      final current = value(element);
      if (bestValue == null || current > bestValue) {
        best = element;
        bestValue = current;
      }
    }
    return best;
  }
}
