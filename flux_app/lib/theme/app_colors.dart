import 'package:flutter/material.dart';

/// Crimson & Clarity palette (light) — matches the rendered Stitch screens.
/// Single source of truth for color. No raw hex outside this file.
abstract final class AppColors {
  // Surfaces / background
  static const background = Color(0xFFFAF9FE);
  static const surface = Color(0xFFFAF9FE);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F3F8);
  static const surfaceContainer = Color(0xFFEEEDF3);
  static const surfaceContainerHigh = Color(0xFFE9E7ED);
  static const surfaceContainerHighest = Color(0xFFE3E2E7);
  static const surfaceVariant = Color(0xFFE3E2E7);
  static const surfaceDim = Color(0xFFDAD9DF);

  // On-surface text
  static const onSurface = Color(0xFF1A1B1F);
  static const onSurfaceVariant = Color(0xFF5D3F3B);
  static const onBackground = Color(0xFF1A1B1F);

  // Primary (Recording Red)
  static const primary = Color(0xFFBC000A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE2241F);
  static const onPrimaryContainer = Color(0xFFFFFBFF);
  static const primaryFixed = Color(0xFFFFDAD5);
  static const inversePrimary = Color(0xFFFFB4AA);
  static const surfaceTint = Color(0xFFC0000A);

  // Secondary / neutral
  static const secondary = Color(0xFF5F5E60);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE2DFE1);
  static const onSecondaryContainer = Color(0xFF636264);
  static const secondaryFixedDim = Color(0xFFC8C6C8);

  // Outline
  static const outline = Color(0xFF926F6A);
  static const outlineVariant = Color(0xFFE7BDB7);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Immersive (Active Recording) surface
  static const recordingBackdrop = Color(0xFF000000);
}
