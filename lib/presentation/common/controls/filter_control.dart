import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';
import 'package:whatsapp_status_saver/app/theme/app_spacing.dart';
import 'package:whatsapp_status_saver/app/theme/app_typography.dart';

enum MediaFilter { all, photos, videos }

/// Filter chips row for toggling media types.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.21:
/// - Guarantees 48dp touch height while maintaining 32dp visual height.
/// - Tabular figures on item count.
/// - Horizontally scrollable to support 200% text scale without overflow.
class FilterControl extends StatelessWidget {
  final MediaFilter activeFilter;
  final ValueChanged<MediaFilter> onFilterChanged;
  final int allCount;
  final int photosCount;
  final int videosCount;

  const FilterControl({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    this.allCount = 0,
    this.photosCount = 0,
    this.videosCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Row(
        children: [
          _buildChip(
            filter: MediaFilter.all,
            label: 'All ($allCount)',
            isSelected: activeFilter == MediaFilter.all,
          ),
          const SizedBox(width: AppSpacing.space8),
          _buildChip(
            filter: MediaFilter.photos,
            label: 'Photos ($photosCount)',
            isSelected: activeFilter == MediaFilter.photos,
          ),
          const SizedBox(width: AppSpacing.space8),
          _buildChip(
            filter: MediaFilter.videos,
            label: 'Videos ($videosCount)',
            isSelected: activeFilter == MediaFilter.videos,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required MediaFilter filter,
    required String label,
    required bool isSelected,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Filter: $label',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) {
            HapticFeedback.selectionClick();
            onFilterChanged(filter);
          }
        },
        child: SizedBox(
          height: AppSpacing.minTouchTarget, // 48dp minimum hit box
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 32,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.darkSurfaceLevel2
                    : AppColors.darkSurfaceLevel1,
                borderRadius: AppRadius.borderPill,
                border: Border.all(
                  color: isSelected
                      ? AppColors.darkPrimary
                      : AppColors.darkBorderSubtle,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.darkTextPrimary
                        : AppColors.darkTextSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
