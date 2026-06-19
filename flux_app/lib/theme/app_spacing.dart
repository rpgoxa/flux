/// 8pt-rhythm spacing scale from the Crimson & Clarity design system.
abstract final class AppSpacing {
  static const double base = 4;
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 40;
  static const double xl = 64;
  static const double gutter = 20;
  static const double marginMobile = 16;
  static const double marginDesktop = 32;
}

/// Corner radii. Cards/buttons use [xl] (12px); pills use [full].
abstract final class AppRadius {
  static const double sm = 4;
  static const double lg = 8;
  static const double xl = 12;
  static const double full = 9999;
}
