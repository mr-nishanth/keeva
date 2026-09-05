import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../application/providers.dart';
import '../../application/saver/save_state.dart';
import '../../application/statuses/status_list_state.dart';
import '../../domain/entities/status_item.dart';
import '../common/buttons/keep_button.dart';
import '../common/controls/filter_control.dart';
import '../common/controls/section_header.dart';
import '../common/feedback/empty_state.dart';
import '../common/feedback/toast.dart';
import '../common/sheets/bottom_sheet.dart';
import '../shell/top_bar.dart';
import 'status_grid.dart';

/// Screen B: Primary Moments Home Screen.
///
/// Implements specification from docs/design/keeva-ui-spec.md Section Screen B:
/// - Brand Header with Private trust badge.
/// - Section header showing moment count.
/// - Filter chips (All, Photos, Videos).
/// - High-performance 9:16 media grid with virtualized slivers.
/// - Signature KeepButton integration via [saveNotifierProvider].
/// - Non-blocking pull-to-refresh.
class MomentsScreen extends ConsumerStatefulWidget {
  final ValueChanged<StatusItem>? onStatusSelected;
  final VoidCallback? onExploreKept;

  const MomentsScreen({super.key, this.onStatusSelected, this.onExploreKept});

  @override
  ConsumerState<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends ConsumerState<MomentsScreen> {
  MediaFilter _activeFilter = MediaFilter.all;

  @override
  Widget build(BuildContext context) {
    final statusListState = ref.watch(statusListNotifierProvider);
    final saveState = ref.watch(saveNotifierProvider);

    // Listen for save completion/failure notifications
    ref.listen<SaveState>(saveNotifierProvider, (previous, next) {
      if (next is SaveSuccess && previous is! SaveSuccess) {
        KeevaToast.show(
          context,
          message: 'Saved to gallery',
          icon: AppIcons.actionCheck,
        );
      } else if (next is SaveFailure && previous is! SaveFailure) {
        KeevaToast.show(
          context,
          message: next.failure.message,
          icon: AppIcons.errorWarning,
        );
      }
    });

    final allItems = statusListState.items;
    final photosCount = allItems.where((i) => !i.isVideo).length;
    final videosCount = allItems.where((i) => i.isVideo).length;

    final filteredItems = switch (_activeFilter) {
      MediaFilter.all => allItems,
      MediaFilter.photos => allItems.where((i) => !i.isVideo).toList(),
      MediaFilter.videos => allItems.where((i) => i.isVideo).toList(),
    };

    final isInitialOrLoading =
        statusListState.isInitial || statusListState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const TopBar.brand(),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(statusListNotifierProvider.notifier).refresh(),
        color: AppColors.darkPrimary,
        backgroundColor: AppColors.darkSurfaceLevel2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space8),
              child: SectionHeader(
                title: 'Today',
                subtitle: '${allItems.length} moments available',
              ),
            ),
            const SizedBox(height: AppSpacing.space8),

            // Filter Chips
            FilterControl(
              activeFilter: _activeFilter,
              onFilterChanged: (filter) {
                setState(() => _activeFilter = filter);
              },
              allCount: allItems.length,
              photosCount: photosCount,
              videosCount: videosCount,
            ),
            const SizedBox(height: AppSpacing.space12),

            // Status Grid
            Expanded(
              child: StatusGrid(
                items: filteredItems,
                isLoading: isInitialOrLoading,
                emptyScenario:
                    _activeFilter != MediaFilter.all && allItems.isNotEmpty
                    ? EmptyScenario.filterEmpty
                    : EmptyScenario.noStatuses,
                failure: statusListState is StatusListFailure
                    ? statusListState.failure
                    : null,
                onRetry: () =>
                    ref.read(statusListNotifierProvider.notifier).load(),
                onStatusTap: widget.onStatusSelected,
                onKeepStatus: (item) {
                  ref.read(saveNotifierProvider.notifier).save(item);
                },
                onAlreadyKeptStatus: (item) {
                  KeevaBottomSheet.showAlreadyKeptOptions(
                    context: context,
                    item: item,
                    onViewInVault: () {
                      widget.onExploreKept?.call();
                    },
                    onSaveCopy: () {
                      ref.read(saveNotifierProvider.notifier).save(item);
                    },
                  );
                },
                keepStateResolver: (item) {
                  if (saveState.isInProgress &&
                      saveState.currentItemId == item.id) {
                    return KeepState.saving;
                  }
                  if (saveState.isSuccess &&
                      saveState.currentItemId == item.id) {
                    return KeepState.success;
                  }
                  if (saveState.isFailure &&
                      saveState.currentItemId == item.id) {
                    return KeepState.failure;
                  }
                  if (item.isSaved) {
                    return KeepState.alreadyKept;
                  }
                  return KeepState.idle;
                },
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
          ],
        ),
      ),
    );
  }
}
