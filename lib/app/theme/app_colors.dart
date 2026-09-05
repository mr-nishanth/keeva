import 'package:flutter/material.dart';

/// Design tokens for Keeva color palette.
///
/// Implements the approved "Quiet Obsidian + Aurora Mint" dark palette
/// and "Crisp Editorial" light palette from docs/design/keeva-design-system.md.
abstract final class AppColors {
  // ===========================================================================
  // DARK PALETTE (Quiet Obsidian - Default)
  // ===========================================================================

  /// Deep obsidian background to avoid OLED purple smearing.
  static const Color darkBackground = Color(0xFF090B0E);

  /// Level 0: Flat bottom nav bar, top app bar.
  static const Color darkSurfaceLevel0 = Color(0xFF11141A);

  /// Level 1: Media cards, list items, search inputs.
  static const Color darkSurfaceLevel1 = Color(0xFF161A22);

  /// Level 2: Bottom sheets, dialogs, floating action pills.
  static const Color darkSurfaceLevel2 = Color(0xFF1E232E);

  /// Level 3: Tooltips, popovers, high-emphasis overlays.
  static const Color darkSurfaceLevel3 = Color(0xFF282E3C);

  /// Signature Aurora Mint primary action color.
  static const Color darkPrimary = Color(0xFF10B981);
  static const Color darkPrimaryLight = Color(0xFF34D399);
  static const Color darkPrimaryDark = Color(0xFF064E3B);
  static const Color darkOnPrimary = Color(0xFF042F2E);
  static const Color darkPrimaryContainer = Color(0xFF064E3B);
  static const Color darkOnPrimaryContainer = Color(0xFFA7F3D0);

  /// Aurora Indigo accent color for multi-selection and focus.
  static const Color darkAccent = Color(0xFF6366F1);
  static const Color darkAccentLight = Color(0xFF818CF8);
  static const Color darkAccentDark = Color(0xFF312E81);
  static const Color darkOnAccent = Color(0xFFFFFFFF);
  static const Color darkAccentContainer = Color(0xFF1E1B4B);
  static const Color darkOnAccentContainer = Color(0xFFC7D2FE);

  /// Text tokens for dark mode.
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  /// Semantic status tokens for dark mode.
  static const Color darkSuccess = Color(0xFF10B981);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkOnError = Color(0xFFFFFFFF);

  /// Optical borders and scrims for dark mode.
  static const Color darkBorderSubtle = Color(
    0x0FFFFFFF,
  ); // rgba(255,255,255,0.06)
  static const Color darkBorderFocused = Color(
    0x806366F1,
  ); // rgba(99,102,241,0.50)
  static const Color darkBorderSheet = Color(
    0x1FFFFFFF,
  ); // rgba(255,255,255,0.12)
  static const Color darkScrim = Color(0xB8000000); // rgba(0,0,0,0.72)

  // ===========================================================================
  // LIGHT PALETTE (Crisp Editorial)
  // ===========================================================================

  /// Editorial warm off-white canvas.
  static const Color lightBackground = Color(0xFFF9FAFB);

  /// Level 0: Flat white top bars, bottom nav.
  static const Color lightSurfaceLevel0 = Color(0xFFFFFFFF);

  /// Level 1: Chips, search inputs, card borders.
  static const Color lightSurfaceLevel1 = Color(0xFFF3F4F6);

  /// Level 2: Modal sheets with soft ambient shadow.
  static const Color lightSurfaceLevel2 = Color(0xFFFFFFFF);

  /// Level 3: Tooltips, popovers, borders.
  static const Color lightSurfaceLevel3 = Color(0xFFE5E7EB);

  /// Forest mint primary for light mode legibility.
  static const Color lightPrimary = Color(0xFF059669);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD1FAE5);
  static const Color lightOnPrimaryContainer = Color(0xFF065F46);

  /// Deep indigo accent for light mode.
  static const Color lightAccent = Color(0xFF4F46E5);
  static const Color lightOnAccent = Color(0xFFFFFFFF);
  static const Color lightAccentContainer = Color(0xFFEEF2FF);
  static const Color lightOnAccentContainer = Color(0xFF312E81);

  /// Text tokens for light mode.
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  /// Semantic status tokens for light mode.
  static const Color lightSuccess = Color(0xFF059669);
  static const Color lightWarning = Color(0xFFD97706);
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightOnError = Color(0xFFFFFFFF);

  /// Optical borders and scrims for light mode.
  static const Color lightBorderSubtle = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color lightBorderFocused = Color(0x804F46E5);
  static const Color lightBorderSheet = Color(0x1F000000);
  static const Color lightScrim = Color(0x7A111827); // rgba(17,24,39,0.48)

  // ===========================================================================
  // SHARED CONTENT SCRIMS
  // ===========================================================================

  /// Bottom gradient scrim for card text & video duration overlay.
  static const LinearGradient videoScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xD9000000), // rgba(0,0,0,0.85)
      Color(0x00000000), // transparent
    ],
  );
}

/// Theme extension exposing Keeva-specific semantic color tokens.
@immutable
class KeevaColorsExtension extends ThemeExtension<KeevaColorsExtension> {
  final Color surfaceLevel0;
  final Color surfaceLevel1;
  final Color surfaceLevel2;
  final Color surfaceLevel3;
  final Color primaryDark;
  final Color primaryLight;
  final Color accentLight;
  final Color accentDark;
  final Color textTertiary;
  final Color borderSubtle;
  final Color borderFocused;
  final Color borderSheet;
  final Color scrim;

  const KeevaColorsExtension({
    required this.surfaceLevel0,
    required this.surfaceLevel1,
    required this.surfaceLevel2,
    required this.surfaceLevel3,
    required this.primaryDark,
    required this.primaryLight,
    required this.accentLight,
    required this.accentDark,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderFocused,
    required this.borderSheet,
    required this.scrim,
  });

  /// Default dark theme extension instance.
  static const dark = KeevaColorsExtension(
    surfaceLevel0: AppColors.darkSurfaceLevel0,
    surfaceLevel1: AppColors.darkSurfaceLevel1,
    surfaceLevel2: AppColors.darkSurfaceLevel2,
    surfaceLevel3: AppColors.darkSurfaceLevel3,
    primaryDark: AppColors.darkPrimaryDark,
    primaryLight: AppColors.darkPrimaryLight,
    accentLight: AppColors.darkAccentLight,
    accentDark: AppColors.darkAccentDark,
    textTertiary: AppColors.darkTextTertiary,
    borderSubtle: AppColors.darkBorderSubtle,
    borderFocused: AppColors.darkBorderFocused,
    borderSheet: AppColors.darkBorderSheet,
    scrim: AppColors.darkScrim,
  );

  /// Default light theme extension instance.
  static const light = KeevaColorsExtension(
    surfaceLevel0: AppColors.lightSurfaceLevel0,
    surfaceLevel1: AppColors.lightSurfaceLevel1,
    surfaceLevel2: AppColors.lightSurfaceLevel2,
    surfaceLevel3: AppColors.lightSurfaceLevel3,
    primaryDark: Color(0xFF047857),
    primaryLight: Color(0xFF10B981),
    accentLight: Color(0xFF6366F1),
    accentDark: Color(0xFF3730A3),
    textTertiary: AppColors.lightTextTertiary,
    borderSubtle: AppColors.lightBorderSubtle,
    borderFocused: AppColors.lightBorderFocused,
    borderSheet: AppColors.lightBorderSheet,
    scrim: AppColors.lightScrim,
  );

  @override
  KeevaColorsExtension copyWith({
    Color? surfaceLevel0,
    Color? surfaceLevel1,
    Color? surfaceLevel2,
    Color? surfaceLevel3,
    Color? primaryDark,
    Color? primaryLight,
    Color? accentLight,
    Color? accentDark,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderFocused,
    Color? borderSheet,
    Color? scrim,
  }) {
    return KeevaColorsExtension(
      surfaceLevel0: surfaceLevel0 ?? this.surfaceLevel0,
      surfaceLevel1: surfaceLevel1 ?? this.surfaceLevel1,
      surfaceLevel2: surfaceLevel2 ?? this.surfaceLevel2,
      surfaceLevel3: surfaceLevel3 ?? this.surfaceLevel3,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      accentLight: accentLight ?? this.accentLight,
      accentDark: accentDark ?? this.accentDark,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderFocused: borderFocused ?? this.borderFocused,
      borderSheet: borderSheet ?? this.borderSheet,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  ThemeExtension<KeevaColorsExtension> lerp(
    covariant ThemeExtension<KeevaColorsExtension>? other,
    double t,
  ) {
    if (other is! KeevaColorsExtension) {
      return this;
    }
    return KeevaColorsExtension(
      surfaceLevel0: Color.lerp(surfaceLevel0, other.surfaceLevel0, t)!,
      surfaceLevel1: Color.lerp(surfaceLevel1, other.surfaceLevel1, t)!,
      surfaceLevel2: Color.lerp(surfaceLevel2, other.surfaceLevel2, t)!,
      surfaceLevel3: Color.lerp(surfaceLevel3, other.surfaceLevel3, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      borderSheet: Color.lerp(borderSheet, other.borderSheet, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
