import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

/// Toast and transient notification helper for Keeva.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.18.
abstract final class KeevaToast {
  /// Displays a floating snackbar anchored above the navigation bar.
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceLevel3,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
          side: const BorderSide(color: AppColors.darkBorderSheet, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.darkPrimary),
              const SizedBox(width: AppSpacing.space8),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
