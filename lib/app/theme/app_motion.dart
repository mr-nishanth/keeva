import 'package:flutter/material.dart';

/// Motion easing curves, duration tokens, and accessibility motion helpers.
///
/// Implements tokens and curves from docs/design/keeva-motion-spec.md.
abstract final class AppMotion {
  // ===========================================================================
  // EASING CURVES
  // ===========================================================================

  /// Entrances: elements entering the viewport decelerate naturally into resting position.
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.70, 0.10, 1.00);

  /// Exits: elements leaving the screen accelerate rapidly out of view.
  static const Curve emphasizedAccelerate = Cubic(0.30, 0.00, 0.80, 0.15);

  /// Morphing, selection changes, and color transitions.
  static const Curve standardEasing = Cubic(0.20, 0.00, 0.00, 1.00);

  /// Micro-spring for signature "Keep" button release.
  static const Curve buttonSpring = Cubic(0.175, 0.885, 0.32, 1.15);

  // ===========================================================================
  // DURATION TOKENS
  // ===========================================================================

  /// 50ms: Rapid touch state changes (ripple start).
  static const Duration durationInstant = Duration(milliseconds: 50);

  /// 100ms: Button press scale-down, checkbox check.
  static const Duration durationMicro = Duration(milliseconds: 100);

  /// 180ms: Filter chip selection, tooltip popover.
  static const Duration durationFast = Duration(milliseconds: 180);

  /// 240ms: Staggered grid card entry, tab pill indicator morph.
  static const Duration durationNormal = Duration(milliseconds: 240);

  /// 320ms: Bottom sheet slide-up, dialog entrance.
  static const Duration durationMedium = Duration(milliseconds: 320);

  /// 300ms: Thumbnail-to-fullscreen viewer zoom transition.
  static const Duration durationHero = Duration(milliseconds: 300);

  /// 2500ms: Snackbar / Toast visibility duration.
  static const Duration durationToast = Duration(milliseconds: 2500);

  // ===========================================================================
  // REDUCED MOTION HELPERS
  // ===========================================================================

  /// Checks if reduced motion is requested by the operating system.
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  /// Returns [duration] if animations are enabled, or [Duration.zero]
  /// (or [fallback] if provided) if reduced motion is requested.
  static Duration adjustedDuration(
    BuildContext context,
    Duration duration, {
    Duration fallback = Duration.zero,
  }) {
    return isReducedMotion(context) ? fallback : duration;
  }
}
