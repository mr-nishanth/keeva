import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

import 'permission_step.dart';

/// The 3-step structured visual guide explaining Android SAF folder access.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.15
/// and docs/design/keeva-ui-spec.md Screen A.
class PermissionGuide extends StatelessWidget {
  const PermissionGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: Text(
            'HOW KEEVA WORKS',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.darkTextTertiary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const PermissionStep(
          stepNumber: 1,
          title: '1. View statuses in WhatsApp',
          description: 'Statuses only exist on your device after you have viewed them in WhatsApp.',
        ),
        const SizedBox(height: AppSpacing.space12),
        const PermissionStep(
          stepNumber: 2,
          title: '2. Tap Connect Folder below',
          description: 'This opens the Android system file selector directly to the WhatsApp media folder.',
        ),
        const SizedBox(height: AppSpacing.space12),
        const PermissionStep(
          stepNumber: 3,
          title: '3. Tap "Use this folder"',
          description: 'Confirm access by tapping the blue button at the bottom of the Android picker.',
          isHighlighted: true,
        ),
        const SizedBox(height: AppSpacing.space16),

        // Privacy Guarantee Pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceLevel1,
            borderRadius: AppRadius.borderPill,
            border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.privacyShield,
                size: 16,
                color: AppColors.darkPrimary,
              ),
              const SizedBox(width: AppSpacing.space8),
              Flexible(
                child: Text(
                  '100% On-Device • Zero Network • Private',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
