import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

enum SecondaryButtonVariant { outlined, ghost }

/// Secondary/neutral action button for Keeva.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.5:
/// - Outlined: 1.5px subtle border rgba(255, 255, 255, 0.16)
/// - Ghost: Transparent background with light touch highlight
/// - Guaranteed minimum 48x48dp interactive hit target.
class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final SecondaryButtonVariant variant;
  final IconData? leadingIcon;
  final bool isFullWidth;
  final String? semanticLabel;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SecondaryButtonVariant.outlined,
    this.leadingIcon,
    this.isFullWidth = false,
    this.semanticLabel,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
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
    final isEnabled = widget.onPressed != null;

    final isOutlined = widget.variant == SecondaryButtonVariant.outlined;

    final decoration = BoxDecoration(
      color: _isPressed
          ? (isOutlined
                ? AppColors.darkSurfaceLevel2
                : AppColors.darkSurfaceLevel1)
          : (isOutlined ? AppColors.darkSurfaceLevel1 : Colors.transparent),
      borderRadius: AppRadius.borderMd,
      border: isOutlined
          ? Border.all(
              color: const Color(0x29FFFFFF), // rgba(255, 255, 255, 0.16)
              width: 1.5,
            )
          : null,
    );

    final content = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 150),
        child: Container(
          constraints: const BoxConstraints(minWidth: 100, minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space8,
          ),
          decoration: decoration,
          child: Center(
            child: Row(
              mainAxisSize: widget.isFullWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: 18,
                    color: AppColors.darkTextPrimary,
                  ),
                  const SizedBox(width: AppSpacing.space8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.darkTextPrimary,
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
