import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

/// Individual numbered instruction card within the permission guide.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.16.
class PermissionStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isHighlighted;

  const PermissionStep({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceLevel1,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isHighlighted
              ? AppColors.darkPrimary
              : AppColors.darkBorderSubtle,
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.darkPrimary
                  : AppColors.darkSurfaceLevel2,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: AppTypography.labelMedium.copyWith(
                  color: isHighlighted
                      ? AppColors.darkOnPrimary
                      : AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
