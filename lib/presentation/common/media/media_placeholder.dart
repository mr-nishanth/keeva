import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';

/// Deterministic 9:16 media placeholder rendered while thumbnails load.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.19:
/// - Guarantees zero layout shifts during async loading.
class MediaPlaceholder extends StatelessWidget {
  final bool isVideo;
  final BorderRadius borderRadius;

  const MediaPlaceholder({
    super.key,
    this.isVideo = false,
    this.borderRadius = AppRadius.borderMd,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceLevel1,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
        ),
        child: Center(
          child: Icon(
            isVideo ? AppIcons.typeVideo : AppIcons.typeImage,
            size: 32,
            color: AppColors.darkTextTertiary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
