import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Central theme provider for Keeva.
///
/// Builds complete, modern Material 3 [ThemeData] configurations
/// for both Dark (Quiet Obsidian) and Light (Crisp Editorial) modes.
abstract final class KeevaTheme {
  /// Quick accessor for the [KeevaColorsExtension] from the active [BuildContext].
  static KeevaColorsExtension colorsOf(BuildContext context) {
    return Theme.of(context).extension<KeevaColorsExtension>() ??
        KeevaColorsExtension.dark;
  }

  // ===========================================================================
  // DARK THEME (Quiet Obsidian + Aurora Mint — Default)
  // ===========================================================================

  static ThemeData get darkTheme {
    final textTheme = AppTypography.buildTextTheme(
      primaryColor: AppColors.darkTextPrimary,
      secondaryColor: AppColors.darkTextSecondary,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkAccent,
      onSecondary: AppColors.darkOnAccent,
      secondaryContainer: AppColors.darkAccentContainer,
      onSecondaryContainer: AppColors.darkOnAccentContainer,
      tertiary: AppColors.darkAccentLight,
      onTertiary: AppColors.darkBackground,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      surface: AppColors.darkSurfaceLevel1,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkSurfaceLevel0,
      surfaceContainer: AppColors.darkSurfaceLevel1,
      surfaceContainerHigh: AppColors.darkSurfaceLevel2,
      surfaceContainerHighest: AppColors.darkSurfaceLevel3,
      outline: AppColors.darkBorderSubtle,
      outlineVariant: AppColors.darkBorderSheet,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,

      // Top App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurfaceLevel0,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceLevel0,
        indicatorColor: AppColors.darkPrimaryContainer,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: AppColors.darkPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelMedium.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkPrimary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.darkTextSecondary,
            size: 24,
          );
        }),
      ),

      // Navigation Rail (Tablets)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurfaceLevel0,
        indicatorColor: AppColors.darkPrimaryContainer,
        elevation: 0,
        selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: const IconThemeData(
          color: AppColors.darkPrimary,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: 24,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceLevel1,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: const BorderSide(color: AppColors.darkBorderSubtle, width: 1),
        ),
      ),

      // Modal Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurfaceLevel2,
        modalBackgroundColor: AppColors.darkSurfaceLevel2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheetTop,
          side: BorderSide(color: AppColors.darkBorderSheet, width: 1),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfaceLevel2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: const BorderSide(color: AppColors.darkBorderSheet, width: 1),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceLevel3,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
          side: const BorderSide(color: AppColors.darkBorderSheet, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Extensions
      extensions: const [KeevaColorsExtension.dark],
    );
  }

  // ===========================================================================
  // LIGHT THEME (Crisp Editorial)
  // ===========================================================================

  static ThemeData get lightTheme {
    final textTheme = AppTypography.buildTextTheme(
      primaryColor: AppColors.lightTextPrimary,
      secondaryColor: AppColors.lightTextSecondary,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightAccent,
      onSecondary: AppColors.lightOnAccent,
      secondaryContainer: AppColors.lightAccentContainer,
      onSecondaryContainer: AppColors.lightOnAccentContainer,
      tertiary: Color(0xFF4338CA),
      onTertiary: Colors.white,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      surface: AppColors.lightSurfaceLevel0,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerLowest: AppColors.lightBackground,
      surfaceContainerLow: AppColors.lightSurfaceLevel0,
      surfaceContainer: AppColors.lightSurfaceLevel1,
      surfaceContainerHigh: AppColors.lightSurfaceLevel2,
      surfaceContainerHighest: AppColors.lightSurfaceLevel3,
      outline: AppColors.lightBorderSubtle,
      outlineVariant: AppColors.lightBorderSheet,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightBackground,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,

      // Top App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurfaceLevel0,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurfaceLevel0,
        indicatorColor: AppColors.lightPrimaryContainer,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: AppColors.lightPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelMedium.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightPrimary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.lightTextSecondary,
            size: 24,
          );
        }),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurfaceLevel0,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: const BorderSide(color: AppColors.lightBorderSubtle, width: 1),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurfaceLevel0,
        modalBackgroundColor: AppColors.lightSurfaceLevel0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheetTop,
          side: BorderSide(color: AppColors.lightBorderSheet, width: 1),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurfaceLevel0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: const BorderSide(color: AppColors.lightBorderSheet, width: 1),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Extensions
      extensions: const [KeevaColorsExtension.light],
    );
  }
}
