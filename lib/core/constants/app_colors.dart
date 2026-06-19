import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppColors {
  static const Color primary = AppPalette.ocean;
  static const Color primaryDark = AppPalette.oceanDark;
  static const Color secondary = AppPalette.coral;
  static const Color accent = AppPalette.sunshine;

  static const Color background = AppPalette.background;
  static const Color surface = AppPalette.surface;
  static const Color softPrimary = AppPalette.surfaceCool;
  static const Color softBlue = AppPalette.surfaceAccent;
  static const Color softWarm = AppPalette.surfaceWarm;

  static const Color darkBackground = AppPalette.darkBackground;
  static const Color darkSurface = AppPalette.darkSurface;
  static const Color darkSoftPrimary = AppPalette.darkSurfaceCool;

  static const Color textPrimary = AppPalette.textPrimary;
  static const Color textSecondary = AppPalette.textSecondary;
  static const Color darkTextPrimary = AppPalette.darkTextPrimary;
  static const Color darkTextSecondary = AppPalette.darkTextSecondary;

  static const Color success = AppPalette.success;
  static const Color successSoft = AppPalette.successSoft;
  static const Color error = AppPalette.error;
  static const Color errorSoft = AppPalette.errorSoft;
  static const Color border = AppPalette.border;
}
