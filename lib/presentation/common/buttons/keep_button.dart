import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_motion.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

enum KeepState { idle, saving, success, alreadyKept, failure }

enum KeepButtonVariant { cardOverlay, viewerAction }

/// Signature Keeva KeepButton micro-interaction.
///
/// Implements specification from docs/design/keeva-motion-spec.md Section 3:
/// - Visual Affordance: 32x32dp circular glass disc.
/// - Touch Target: Guaranteed 48x48dp interactive bounding box.
/// - State Choreography: Idle -> Pressed (0.94) -> Saving (spinner) -> Success (Check + Aura Wave).
/// - Reduced Motion: Fully complies with MediaQuery.disableAnimationsOf(context).
class KeepButton extends StatefulWidget {
  final KeepState state;
  final VoidCallback? onPressed;
  final VoidCallback? onAlreadyKeptPressed;
  final KeepButtonVariant variant;

  const KeepButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.onAlreadyKeptPressed,
    this.variant = KeepButtonVariant.cardOverlay,
  });

  @override
  State<KeepButton> createState() => _KeepButtonState();
}

class _KeepButtonState extends State<KeepButton> with TickerProviderStateMixin {
  bool _isPressed = false;
  DateTime? _lastTapTime;
  late final AnimationController _auraController;
  late final Animation<double> _auraScale;
  late final Animation<double> _auraOpacity;
  late final AnimationController _nudgeController;
  late final Animation<double> _nudgeAnimation;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _auraScale = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _auraController, curve: Curves.easeOut));

    _auraOpacity = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _auraController, curve: Curves.easeOut));

    _nudgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _nudgeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _nudgeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(covariant KeepButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state && widget.state == KeepState.success) {
      if (!AppMotion.isReducedMotion(context)) {
        _auraController.forward(from: 0.0);
      }
      HapticFeedback.selectionClick();
    } else if (oldWidget.state != widget.state &&
        widget.state == KeepState.failure) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _auraController.dispose();
    _nudgeController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.state == KeepState.saving) {
      return;
    }

    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 400) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTap() {
    if (widget.state == KeepState.saving) {
      return;
    }

    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 400) {
      return;
    }
    _lastTapTime = now;

    if (widget.state == KeepState.alreadyKept ||
        widget.state == KeepState.success) {
      HapticFeedback.selectionClick();
      if (!AppMotion.isReducedMotion(context)) {
        _nudgeController.forward(from: 0.0);
      }
      widget.onAlreadyKeptPressed?.call();
      return;
    }

    widget.onPressed?.call();
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  String _semanticLabel() {
    return switch (widget.state) {
      KeepState.alreadyKept => 'Already kept in vault',
      KeepState.success => 'Kept in vault',
      KeepState.saving => 'Keeping moment',
      KeepState.failure => 'Failed to keep moment. Tap to retry',
      KeepState.idle => 'Keep this moment',
    };
  }

  Widget _buildCardOverlay() {
    final isReduced = AppMotion.isReducedMotion(context);

    Widget iconWidget = switch (widget.state) {
      KeepState.saving => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkPrimary),
        ),
      ),
      KeepState.success => const Icon(
        AppIcons.actionCheck,
        size: 20,
        color: AppColors.darkPrimary,
      ),
      KeepState.alreadyKept => const Icon(
        AppIcons.actionCheck,
        size: 18,
        color: AppColors.darkOnPrimaryContainer,
      ),
      KeepState.failure => const Icon(
        AppIcons.errorWarning,
        size: 18,
        color: AppColors.darkWarning,
      ),
      KeepState.idle => const Icon(
        AppIcons.actionKeep,
        size: 18,
        color: AppColors.darkPrimary,
      ),
    };

    final containerColor = switch (widget.state) {
      KeepState.alreadyKept => AppColors.darkPrimaryContainer,
      KeepState.failure => const Color(0x66F59E0B),
      _ => const Color(0x80000000), // rgba(0,0,0,0.50)
    };

    final visualCircle = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: containerColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.state == KeepState.failure
              ? AppColors.darkWarning
              : AppColors.darkBorderSubtle,
          width: 1,
        ),
      ),
      child: Center(child: iconWidget),
    );

    return SizedBox(
      width: AppSpacing.minTouchTarget,
      height: AppSpacing.minTouchTarget,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (!isReduced)
              AnimatedBuilder(
                animation: _auraController,
                builder: (context, child) {
                  if (!_auraController.isAnimating) {
                    return const SizedBox.shrink();
                  }
                  return Transform.scale(
                    scale: _auraScale.value,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkPrimary.withValues(
                          alpha: _auraOpacity.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            AnimatedScale(
              scale: _isPressed ? 0.94 : 1.0,
              duration: isReduced
                  ? Duration.zero
                  : const Duration(milliseconds: 80),
              curve: AppMotion.buttonSpring,
              child: visualCircle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerAction() {
    final isSaved =
        widget.state == KeepState.alreadyKept ||
        widget.state == KeepState.success;
    final isSaving = widget.state == KeepState.saving;

    final bgColor = isSaved
        ? AppColors.darkPrimaryContainer
        : AppColors.darkPrimary;
    final fgColor = isSaved
        ? AppColors.darkOnPrimaryContainer
        : AppColors.darkOnPrimary;

    final label = isSaved ? 'Kept ✓' : 'Keep';

    return SizedBox(
      height: 48,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSaving) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
            ] else ...[
              Icon(
                isSaved ? AppIcons.actionCheck : AppIcons.actionKeep,
                size: 18,
                color: fgColor,
              ),
              const SizedBox(width: AppSpacing.space8),
            ],
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive =
        widget.state != KeepState.saving &&
        (widget.onPressed != null ||
            (widget.state == KeepState.alreadyKept &&
                widget.onAlreadyKeptPressed != null));

    final child = widget.variant == KeepButtonVariant.cardOverlay
        ? _buildCardOverlay()
        : _buildViewerAction();

    final animatedChild = AnimatedBuilder(
      animation: _nudgeAnimation,
      builder: (context, c) {
        if (_nudgeAnimation.value == 0.0) return c!;
        return Transform.translate(
          offset: Offset(_nudgeAnimation.value, 0.0),
          child: c,
        );
      },
      child: child,
    );

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: _semanticLabel(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isInteractive ? _handleTapDown : null,
        onTapUp: isInteractive ? _handleTapUp : null,
        onTapCancel: isInteractive ? _handleTapCancel : null,
        onTap: isInteractive ? _handleTap : null,
        child: animatedChild,
      ),
    );
  }
}
