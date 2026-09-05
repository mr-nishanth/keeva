import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../application/providers.dart';
import '../../domain/entities/status_item.dart';
import '../common/buttons/keep_button.dart';
import '../common/controls/filter_control.dart';
import '../common/controls/section_header.dart';
import '../common/feedback/empty_state.dart';
import '../moments/status_grid.dart';
import '../shell/top_bar.dart';

/// Screen E: Kept Media Vault.
///
/// Implements specification from docs/design/keeva-ui-spec.md Section Screen E:
/// - Reuses [StatusCard] and [StatusGrid] for high performance.
/// - Product vocabulary strictly uses "Kept", "Vault", and "Safely Preserved".
/// - Displays total storage footprint and album location.
/// - Filter chips (All, Photos, Videos).
/// - Dedicated [EmptyScenario.vaultEmpty] with CTA to explore moments.
class KeptVaultScreen extends ConsumerStatefulWidget {
  final ValueChanged<StatusItem>? onStatusSelected;
  final VoidCallback? onExploreMoments;

  const KeptVaultScreen({
    super.key,
    this.onStatusSelected,
    this.onExploreMoments,
  });

  @override
  ConsumerState<KeptVaultScreen> createState() => _KeptVaultScreenState();
}

class _KeptVaultScreenState extends ConsumerState<KeptVaultScreen> {
  MediaFilter _activeFilter = MediaFilter.all;

  String _formatFootprint(int totalBytes) {
    if (totalBytes <= 0) return '0 MB stored in Pictures/SavedStatus';
    final mb = totalBytes / (1024 * 1024);
    if (mb < 1.0) {
      final kb = totalBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB stored in Pictures/SavedStatus';
    }
    return '${mb.toStringAsFixed(1)} MB stored in Pictures/SavedStatus';
  }

  @override
  Widget build(BuildContext context) {
    final statusListState = ref.watch(statusListNotifierProvider);

    // Filter to only kept/saved items
    final keptItems = statusListState.items.where((i) => i.isSaved).toList();
    final photosCount = keptItems.where((i) => !i.isVideo).length;
    final videosCount = keptItems.where((i) => i.isVideo).length;

    final totalBytes = keptItems.fold<int>(
      0,
      (sum, item) => sum + item.sizeBytes,
    );

    final filteredItems = switch (_activeFilter) {
      MediaFilter.all => keptItems,
      MediaFilter.photos => keptItems.where((i) => !i.isVideo).toList(),
      MediaFilter.videos => keptItems.where((i) => i.isVideo).toList(),
    };

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: TopBar.contextual(title: 'Kept Vault'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header with Storage Footprint
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space8),
            child: SectionHeader(
              title: '${keptItems.length} moments safely kept',
              subtitle: _formatFootprint(totalBytes),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),

          // Filter Chips
          if (keptItems.isNotEmpty) ...[
            FilterControl(
              activeFilter: _activeFilter,
              onFilterChanged: (filter) {
                setState(() => _activeFilter = filter);
              },
              allCount: keptItems.length,
              photosCount: photosCount,
              videosCount: videosCount,
            ),
            const SizedBox(height: AppSpacing.space12),
          ],

          // Kept Media Grid
          Expanded(
            child: RefreshIndicator(
              color: AppColors.darkPrimary,
              backgroundColor: AppColors.darkSurfaceLevel2,
              onRefresh: () =>
                  ref.read(statusListNotifierProvider.notifier).refresh(),
              child: StatusGrid(
                items: filteredItems,
                emptyScenario:
                    _activeFilter != MediaFilter.all && keptItems.isNotEmpty
                    ? EmptyScenario.filterEmpty
                    : EmptyScenario.vaultEmpty,
                onEmptyAction: widget.onExploreMoments,
                onStatusTap: widget.onStatusSelected,
                keepStateResolver: (_) => KeepState.alreadyKept,
                thumbnailLoader: (item) async {
                  final useCase = ref.read(getThumbnailUseCaseProvider);
                  final result = await useCase(
                    id: item.id,
                    isVideo: item.isVideo,
                  );
                  return result.dataOrNull;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
