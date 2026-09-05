import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_motion.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

void main() {
  group('Phase 2E-B1: Theme & Design System Foundation', () {
    // =========================================================================
    // WCAG RELATIVE LUMINANCE & CONTRAST HELPER
    // =========================================================================
    double srgbToLinear(double channel) {
      return channel <= 0.04045
          ? channel / 12.92
          : pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    double relativeLuminance(Color color) {
      final r = srgbToLinear(color.r);
      final g = srgbToLinear(color.g);
      final b = srgbToLinear(color.b);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    double contrastRatio(Color fg, Color bg) {
      final l1 = relativeLuminance(fg);
      final l2 = relativeLuminance(bg);
      final lighter = max(l1, l2);
      final darker = min(l1, l2);
      return (lighter + 0.05) / (darker + 0.05);
    }

    // =========================================================================
    // COLOR PALETTE & CONTRAST RATIO TESTS
    // =========================================================================
    group('AppColors & Contrast Matrix', () {
      test('Dark palette exact hex values match specification', () {
        expect(AppColors.darkBackground, const Color(0xFF090B0E));
        expect(AppColors.darkSurfaceLevel0, const Color(0xFF11141A));
        expect(AppColors.darkSurfaceLevel1, const Color(0xFF161A22));
        expect(AppColors.darkSurfaceLevel2, const Color(0xFF1E232E));
        expect(AppColors.darkSurfaceLevel3, const Color(0xFF282E3C));
        expect(AppColors.darkPrimary, const Color(0xFF10B981));
        expect(AppColors.darkOnPrimary, const Color(0xFF042F2E));
        expect(AppColors.darkPrimaryContainer, const Color(0xFF064E3B));
        expect(AppColors.darkOnPrimaryContainer, const Color(0xFFA7F3D0));
        expect(AppColors.darkAccent, const Color(0xFF6366F1));
        expect(AppColors.darkTextPrimary, const Color(0xFFF9FAFB));
        expect(AppColors.darkTextSecondary, const Color(0xFF9CA3AF));
        expect(AppColors.darkTextTertiary, const Color(0xFF6B7280));
      });

      test('Light palette exact hex values match specification', () {
        expect(AppColors.lightBackground, const Color(0xFFF9FAFB));
        expect(AppColors.lightSurfaceLevel0, const Color(0xFFFFFFFF));
        expect(AppColors.lightSurfaceLevel1, const Color(0xFFF3F4F6));
        expect(AppColors.lightPrimary, const Color(0xFF059669));
        expect(AppColors.lightTextPrimary, const Color(0xFF111827));
        expect(AppColors.lightTextSecondary, const Color(0xFF4B5563));
      });

      test('Dark textPrimary on darkBackground meets WCAG AAA (>= 7.0:1)', () {
        final ratio = contrastRatio(
          AppColors.darkTextPrimary,
          AppColors.darkBackground,
        );
        expect(ratio, greaterThanOrEqualTo(7.0));
      });

      test('Dark onPrimary on darkPrimary meets WCAG AA (>= 4.5:1)', () {
        final ratio = contrastRatio(
          AppColors.darkOnPrimary,
          AppColors.darkPrimary,
        );
        expect(ratio, greaterThanOrEqualTo(4.5));
      });

      test(
        'Dark textSecondary on darkSurfaceLevel1 meets WCAG AA (>= 4.5:1)',
        () {
          final ratio = contrastRatio(
            AppColors.darkTextSecondary,
            AppColors.darkSurfaceLevel1,
          );
          expect(ratio, greaterThanOrEqualTo(4.5));
        },
      );

      test(
        'Light textPrimary on lightBackground meets WCAG AAA (>= 7.0:1)',
        () {
          final ratio = contrastRatio(
            AppColors.lightTextPrimary,
            AppColors.lightBackground,
          );
          expect(ratio, greaterThanOrEqualTo(7.0));
        },
      );

      test('KeevaColorsExtension lerp and copyWith work deterministically', () {
        const darkExt = KeevaColorsExtension.dark;
        const lightExt = KeevaColorsExtension.light;

        final copied = darkExt.copyWith(primaryDark: Colors.green);
        expect(copied.primaryDark, Colors.green);
        expect(copied.surfaceLevel0, darkExt.surfaceLevel0);

        final lerped = darkExt.lerp(lightExt, 0.5) as KeevaColorsExtension;
        expect(lerped, isNotNull);
        expect(lerped.surfaceLevel0, isNot(darkExt.surfaceLevel0));
      });
    });

    // =========================================================================
    // TYPOGRAPHY TESTS
    // =========================================================================
    group('AppTypography Scale', () {
      test('Uses Plus Jakarta Sans and system fallbacks', () {
        expect(AppTypography.fontFamily, 'Plus Jakarta Sans');
        expect(AppTypography.fontFallbacks, contains('Roboto'));
        expect(AppTypography.fontFallbacks, contains('system-ui'));
      });

      test('Type scale sizes match approved design tokens', () {
        expect(AppTypography.displayLarge.fontSize, 32);
        expect(AppTypography.displayMedium.fontSize, 28);
        expect(AppTypography.headlineLarge.fontSize, 24);
        expect(AppTypography.headlineMedium.fontSize, 20);
        expect(AppTypography.titleLarge.fontSize, 18);
        expect(AppTypography.titleMedium.fontSize, 16);
        expect(AppTypography.bodyLarge.fontSize, 15);
        expect(AppTypography.bodyMedium.fontSize, 14);
        expect(AppTypography.bodySmall.fontSize, 12);
        expect(AppTypography.labelLarge.fontSize, 14);
        expect(AppTypography.labelMedium.fontSize, 12);
        expect(AppTypography.labelSmall.fontSize, 10);
        expect(AppTypography.numericTabular.fontSize, 11);
      });

      test('numericTabular includes tabularFigures font feature', () {
        expect(
          AppTypography.numericTabular.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      });

      test('buildTextTheme assigns font family and colors', () {
        final theme = AppTypography.buildTextTheme(
          primaryColor: Colors.white,
          secondaryColor: Colors.grey,
        );
        expect(theme.headlineLarge?.color, Colors.white);
        expect(theme.bodyMedium?.color, Colors.grey);
        expect(theme.headlineLarge?.fontFamily, 'Plus Jakarta Sans');
      });
    });

    // =========================================================================
    // SPACING & RADIUS TESTS
    // =========================================================================
    group('AppSpacing & AppRadius Tokens', () {
      test('Spacing tokens match 8pt grid hierarchy', () {
        expect(AppSpacing.space2, 2.0);
        expect(AppSpacing.space4, 4.0);
        expect(AppSpacing.space8, 8.0);
        expect(AppSpacing.space12, 12.0);
        expect(AppSpacing.space16, 16.0);
        expect(AppSpacing.space20, 20.0);
        expect(AppSpacing.space24, 24.0);
        expect(AppSpacing.space32, 32.0);
        expect(AppSpacing.space40, 40.0);
        expect(AppSpacing.space48, 48.0);
        expect(AppSpacing.space64, 64.0);
        expect(AppSpacing.minTouchTarget, 48.0);
      });

      test('Radius tokens match specification', () {
        expect(AppRadius.radiusXs, 4.0);
        expect(AppRadius.radiusSm, 8.0);
        expect(AppRadius.radiusMd, 12.0);
        expect(AppRadius.radiusLg, 16.0);
        expect(AppRadius.radiusXl, 24.0);
        expect(AppRadius.radiusPill, 9999.0);
      });
    });

    // =========================================================================
    // MOTION TESTS
    // =========================================================================
    group('AppMotion Tokens & Helpers', () {
      test('Curves and duration tokens are defined', () {
        expect(AppMotion.emphasizedDecelerate, isA<Cubic>());
        expect(AppMotion.emphasizedAccelerate, isA<Cubic>());
        expect(AppMotion.standardEasing, isA<Cubic>());
        expect(AppMotion.buttonSpring, isA<Cubic>());

        expect(AppMotion.durationInstant, const Duration(milliseconds: 50));
        expect(AppMotion.durationMicro, const Duration(milliseconds: 100));
        expect(AppMotion.durationFast, const Duration(milliseconds: 180));
        expect(AppMotion.durationNormal, const Duration(milliseconds: 240));
        expect(AppMotion.durationMedium, const Duration(milliseconds: 320));
        expect(AppMotion.durationHero, const Duration(milliseconds: 300));
        expect(AppMotion.durationToast, const Duration(milliseconds: 2500));
      });

      testWidgets('adjustedDuration respects reduced motion', (tester) async {
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(AppMotion.isReducedMotion(capturedContext), isTrue);
        expect(
          AppMotion.adjustedDuration(
            capturedContext,
            const Duration(milliseconds: 300),
          ),
          Duration.zero,
        );
      });
    });

    // =========================================================================
    // ICONS & THEME CONFIGURATION TESTS
    // =========================================================================
    group('AppIcons & KeevaTheme', () {
      test('AppIcons defines canonical rounded icons', () {
        expect(AppIcons.navMoments, Icons.auto_awesome_motion_rounded);
        expect(AppIcons.navKept, Icons.bookmark_rounded);
        expect(AppIcons.navSettings, Icons.tune_rounded);
        expect(AppIcons.actionKeep, Icons.bookmark_add_rounded);
      });

      test('KeevaTheme.darkTheme configures Quiet Obsidian accurately', () {
        final dark = KeevaTheme.darkTheme;
        expect(dark.brightness, Brightness.dark);
        expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
        expect(dark.colorScheme.primary, AppColors.darkPrimary);
        expect(dark.colorScheme.onPrimary, AppColors.darkOnPrimary);
        expect(dark.extension<KeevaColorsExtension>(), isNotNull);
        expect(
          dark.extension<KeevaColorsExtension>()?.surfaceLevel0,
          AppColors.darkSurfaceLevel0,
        );
      });

      test('KeevaTheme.lightTheme configures Crisp Editorial accurately', () {
        final light = KeevaTheme.lightTheme;
        expect(light.brightness, Brightness.light);
        expect(light.scaffoldBackgroundColor, AppColors.lightBackground);
        expect(light.colorScheme.primary, AppColors.lightPrimary);
        expect(light.extension<KeevaColorsExtension>(), isNotNull);
      });

      testWidgets('KeevaTheme.colorsOf accessor retrieves extension', (
        tester,
      ) async {
        late KeevaColorsExtension colors;
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: Builder(
              builder: (context) {
                colors = KeevaTheme.colorsOf(context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(colors.surfaceLevel1, AppColors.darkSurfaceLevel1);
      });
    });
  });
}
