import 'package:flutter/material.dart';

/// Semantic typography tokens for Keeva.
///
/// Implements the Plus Jakarta Sans type scale according to
/// docs/design/keeva-design-system.md Section 4.
abstract final class AppTypography {
  /// Primary font family name.
  static const String fontFamily = 'Plus Jakarta Sans';

  /// Font family fallbacks.
  static const List<String> fontFallbacks = [
    'Plus Jakarta Sans',
    'system-ui',
    'Roboto',
    'Helvetica Neue',
    'sans-serif',
  ];

  // ===========================================================================
  // TYPE SCALE TOKENS
  // ===========================================================================

  /// displayLarge: 32sp, 40dp line height, SemiBold (600), -0.5sp tracking.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  /// displayMedium: 28sp, 36dp line height, SemiBold (600), -0.25sp tracking.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  /// headlineLarge: 24sp, 32dp line height, SemiBold (600), 0.0sp tracking.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  /// headlineMedium: 20sp, 28dp line height, SemiBold (600), 0.0sp tracking.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  /// titleLarge: 18sp, 24dp line height, Medium (500), 0.0sp tracking.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
  );

  /// titleMedium: 16sp, 22dp line height, Medium (500), +0.1sp tracking.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// bodyLarge: 15sp, 22dp line height, Regular (400), 0.0sp tracking.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  /// bodyMedium: 14sp, 20dp line height, Regular (400), 0.0sp tracking.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  /// bodySmall: 12sp, 16dp line height, Regular (400), +0.1sp tracking.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  /// labelLarge: 14sp, 18dp line height, SemiBold (600), +0.2sp tracking.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// labelMedium: 12sp, 16dp line height, Medium (500), +0.3sp tracking.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  /// labelSmall: 10sp, 14dp line height, SemiBold (600), +0.5sp tracking.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// numericTabular: 11sp, 14dp line height, Medium (500), +0.2sp tracking,
  /// with FontFeature.tabularFigures() for jitter-free numbers.
  static const TextStyle numericTabular = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Builds a [TextTheme] mapped to the Keeva type scale with given text colors.
  static TextTheme buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primaryColor),
      displayMedium: displayMedium.copyWith(color: primaryColor),
      displaySmall: displayMedium.copyWith(color: primaryColor),
      headlineLarge: headlineLarge.copyWith(color: primaryColor),
      headlineMedium: headlineMedium.copyWith(color: primaryColor),
      headlineSmall: headlineMedium.copyWith(color: primaryColor),
      titleLarge: titleLarge.copyWith(color: primaryColor),
      titleMedium: titleMedium.copyWith(color: primaryColor),
      titleSmall: titleMedium.copyWith(color: secondaryColor),
      bodyLarge: bodyLarge.copyWith(color: primaryColor),
      bodyMedium: bodyMedium.copyWith(color: secondaryColor),
      bodySmall: bodySmall.copyWith(color: secondaryColor),
      labelLarge: labelLarge.copyWith(color: primaryColor),
      labelMedium: labelMedium.copyWith(color: secondaryColor),
      labelSmall: labelSmall.copyWith(color: secondaryColor),
    );
  }
}
