import 'package:flutter/material.dart';

/// Spacing tokens for Keeva based on an 8pt architectural grid with 4pt micro-positioning.
///
/// Implements tokens from docs/design/keeva-design-system.md Section 5.
abstract final class AppSpacing {
  /// 2dp: Micro gap between badge icon and text.
  static const double space2 = 2.0;

  /// 4dp: Gap between time label and duration pill; inner chip padding.
  static const double space4 = 4.0;

  /// 8dp: Grid spacing between media cards; button horizontal icon spacing.
  static const double space8 = 8.0;

  /// 12dp: Compact card internal padding; chip horizontal padding.
  static const double space12 = 12.0;

  /// 16dp: Screen horizontal margin on mobile; sheet standard padding.
  static const double space16 = 16.0;

  /// 20dp: Spacing between section headers and content blocks.
  static const double space20 = 20.0;

  /// 24dp: Bottom navigation vertical height offset; modal sheet top padding.
  static const double space24 = 24.0;

  /// 32dp: Hero graphic margin; large empty-state vertical spacing.
  static const double space32 = 32.0;

  /// 40dp: Section separation on tablets.
  static const double space40 = 40.0;

  /// 48dp: Minimum touch target bounding box (kMinInteractiveDimension).
  static const double space48 = 48.0;

  /// 64dp: Floating action clearance; onboarding top spacing.
  static const double space64 = 64.0;

  // ===========================================================================
  // CONVENIENCE EDGE INSETS
  // ===========================================================================

  /// Horizontal screen margin: 16dp.
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: space16,
  );

  /// Standard card padding: 12dp.
  static const EdgeInsets cardPadding = EdgeInsets.all(space12);

  /// Standard modal sheet padding: 24dp top/horizontal, 16dp bottom.
  static const EdgeInsets sheetPadding = EdgeInsets.fromLTRB(
    space24,
    space16,
    space24,
    space24,
  );

  /// Minimum interactive touch dimension contract (48dp).
  static const double minTouchTarget = 48.0;
}
