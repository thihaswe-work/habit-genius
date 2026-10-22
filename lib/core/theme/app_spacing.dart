/// Spacing, radius and elevation tokens.
///
/// Using a token scale instead of ad-hoc numbers keeps spacing consistent
/// across every screen and makes a future density/responsive pass a one-file
/// change.
abstract final class AppSpacing {
  // ---------------------------------------------------------------- spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;

  // --------------------------------------------------------------- radius
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusPill = 999;

  // ------------------------------------------------------------ horizontal
  /// Standard screen gutter used by every page.
  static const double gutter = 20;
}
