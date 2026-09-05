import 'package:flutter/material.dart';

/// Corner radius tokens for Keeva.
///
/// Implements tokens from docs/design/keeva-design-system.md Section 6.
abstract final class AppRadius {
  /// 4dp: Status badges, scrubber thumbs.
  static const double radiusXs = 4.0;

  /// 8dp: Compact chips, selection checkboxes, snackbars.
  static const double radiusSm = 8.0;

  /// 12dp: Media card thumbnails, dialog boxes, text input fields.
  static const double radiusMd = 12.0;

  /// 16dp: High-emphasis cards, onboarding illustration frames.
  static const double radiusLg = 16.0;

  /// 24dp: Modal bottom sheet top corners, signature Keep action pill.
  static const double radiusXl = 24.0;

  /// 9999dp: Filter chips, trust indicator ("Private"), floating pill bars.
  static const double radiusPill = 9999.0;

  // ===========================================================================
  // BORDER RADIUS HELPERS
  // ===========================================================================

  /// BorderRadius.circular(4.0)
  static const BorderRadius borderXs = BorderRadius.all(
    Radius.circular(radiusXs),
  );

  /// BorderRadius.circular(8.0)
  static const BorderRadius borderSm = BorderRadius.all(
    Radius.circular(radiusSm),
  );

  /// BorderRadius.circular(12.0)
  static const BorderRadius borderMd = BorderRadius.all(
    Radius.circular(radiusMd),
  );

  /// BorderRadius.circular(16.0)
  static const BorderRadius borderLg = BorderRadius.all(
    Radius.circular(radiusLg),
  );

  /// BorderRadius.circular(24.0)
  static const BorderRadius borderXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );

  /// BorderRadius.circular(9999.0)
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(radiusPill),
  );

  /// Top corners for modal bottom sheets: 24dp.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(radiusXl),
  );
}
