import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

import 'duration_label.dart';

/// Pill badge overlay for video items displaying duration.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.9:
/// - Height: 20dp, Radius: 4dp
/// - Background: rgba(0, 0, 0, 0.65)
/// - Icon: play_arrow (12dp), tabular font
class VideoBadge extends StatelessWidget {
  final int durationMs;

  const VideoBadge({super.key, required this.durationMs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: Color(0xA6000000), // rgba(0,0,0,0.65)
        borderRadius: AppRadius.borderXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            AppIcons.typeVideo,
            size: 12,
            color: AppColors.darkTextPrimary,
          ),
          if (durationMs > 0) ...[
            const SizedBox(width: AppSpacing.space4),
            DurationLabel(
              durationMs: durationMs,
              style: AppTypography.numericTabular.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
