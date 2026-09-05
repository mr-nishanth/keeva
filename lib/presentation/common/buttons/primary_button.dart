import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

/// Primary call-to-action button for Keeva.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.4:
/// - Aurora Mint (#10B981) background with dark emerald (#042F2E) text (8.4:1 AAA).
/// - Guaranteed minimum 48x48dp interactive hit target.
/// - Deterministic states: Idle, Pressed (scale 0.98), Loading, Disabled.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final double height;
  final String? semanticLabel;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.height = 52.0,
    this.semanticLabel,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final content = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 150),
        child: Container(
          constraints: BoxConstraints(minWidth: 120, minHeight: widget.height),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space8,
          ),
          decoration: const BoxDecoration(
            color: AppColors.darkPrimary,
            borderRadius: AppRadius.borderPill,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.darkOnPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: widget.isFullWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.leadingIcon != null) ...[
                        Icon(
                          widget.leadingIcon,
                          size: 20,
                          color: AppColors.darkOnPrimary,
                        ),
                        const SizedBox(width: AppSpacing.space8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.darkOnPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          child: content,
        ),
      ),
    );
  }
}
