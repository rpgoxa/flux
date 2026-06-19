import 'package:flutter/material.dart';

import 'package:flux_app/theme/app_colors.dart';

/// Inter type scale from the Crimson & Clarity design system.
/// Inter is bundled locally (assets/fonts/Inter.ttf) — no network download.
abstract final class AppTypography {
  static const fontFamily = 'Inter';

  static TextStyle _inter({
    required double size,
    required double height,
    required FontWeight weight,
    double? letterSpacing,
    Color color = AppColors.onSurface,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle get displayLg => _inter(
        size: 48,
        height: 56,
        weight: FontWeight.w700,
        letterSpacing: -0.96, // -0.02em
      );

  static TextStyle get headlineLg => _inter(
        size: 32,
        height: 40,
        weight: FontWeight.w700,
        letterSpacing: -0.32, // -0.01em
      );

  static TextStyle get headlineLgMobile =>
      _inter(size: 28, height: 36, weight: FontWeight.w700);

  static TextStyle get titleMd =>
      _inter(size: 20, height: 28, weight: FontWeight.w600);

  static TextStyle get bodyLg =>
      _inter(size: 16, height: 24, weight: FontWeight.w400);

  static TextStyle get bodySm =>
      _inter(size: 14, height: 20, weight: FontWeight.w400);

  static TextStyle get labelMd => _inter(
        size: 12,
        height: 16,
        weight: FontWeight.w600,
        letterSpacing: 0.6, // 0.05em
      );

  /// Monospace-feel timer for the recording HUD.
  static TextStyle get timer => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: Colors.white,
        fontFeatures: [FontFeature.tabularFigures()],
      );
}
