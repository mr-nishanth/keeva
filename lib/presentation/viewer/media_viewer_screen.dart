import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers.dart';
import '../../application/saver/save_state.dart';
import '../../application/viewer/viewer_state.dart';
import '../../domain/entities/status_item.dart';
import '../../core/constants/app_constants.dart';
import '../common/buttons/keep_button.dart';
import '../common/feedback/error_state.dart';
import '../common/feedback/loading_indicator.dart';
import '../common/feedback/toast.dart';
import '../common/media/freshness_label.dart';
import '../common/media/media_placeholder.dart';
import '../common/sheets/bottom_sheet.dart';
import 'keeva_video_player.dart';

/// Screen D: Full Media Viewer (Immersive Shell).
///
/// Implements specification from docs/design/keeva-ui-spec.md Section Screen D:
/// - Pitch black canvas (#000000) for edge-to-edge optical clarity.
/// - Top floating chrome with back navigation and timestamp.
/// - Single-tap anywhere toggles top and bottom chrome visibility.
/// - Interactive 1:1 vertical drag swipe-to-dismiss (120dp threshold or 800dp/s velocity).
/// - Bottom floating pill bar: Share, signature KeepButton, and Info sheet.
/// - Connects to [viewerNotifierProvider] and [saveNotifierProvider].
class MediaViewerScreen extends ConsumerStatefulWidget {
  final StatusItem item;
  final VoidCallback? onDismiss;
  final ValueChanged<StatusItem>? onShare;
  final VoidCallback? onNavigateToKept;
  final String? mediaPath;

  const MediaViewerScreen({
    super.key,
    required this.item,
    this.onDismiss,
    this.onShare,
    this.onNavigateToKept,
    this.mediaPath,
  });

  @override
  ConsumerState<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends ConsumerState<MediaViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _showChrome = true;
  double _dragOffsetY = 0.0;
  String? _resolvedThumbnailPath;
  late final AnimationController _snapBackController;
  Animation<double>? _snapBackAnimation;

  @override
  void initState() {
    super.initState();
    _resolvedThumbnailPath = widget.mediaPath;
    _snapBackController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )..addListener(() {
          if (_snapBackAnimation != null) {
            setState(() {
              _dragOffsetY = _snapBackAnimation!.value;
            });
          }
        });

    // Prepare media in background via viewerNotifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(viewerNotifierProvider.notifier).prepare(widget.item);
      if (_resolvedThumbnailPath == null) {
        _loadThumbnail();
      }
    });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    super.dispose();
  }

  Future<void> _loadThumbnail() async {
    try {
      final useCase = ref.read(getThumbnailUseCaseProvider);
      final res = await useCase(
        id: widget.item.id,
        isVideo: widget.item.isVideo,
        width: widget.item.isVideo
            ? AppConstants.defaultThumbnailDimension
            : AppConstants.highResPreviewWidth,
        height: widget.item.isVideo
            ? AppConstants.defaultThumbnailDimension
            : AppConstants.highResPreviewHeight,
      );
      if (mounted && res.dataOrNull != null) {
        setState(() => _resolvedThumbnailPath = res.dataOrNull);
      }
    } catch (_) {
      // Use fallback placeholder
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_snapBackController.isAnimating) {
      _snapBackController.stop();
    }
    setState(() {
      _dragOffsetY += details.delta.dy;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    const double dismissThreshold = 120.0;
    const double velocityThreshold = 800.0;

    final velocity = details.primaryVelocity ?? 0.0;
    final isDismissing =
        _dragOffsetY.abs() >= dismissThreshold ||
        velocity.abs() >= velocityThreshold;

    if (isDismissing) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      } else {
        Navigator.of(context).maybePop();
      }
    } else {
      if (AppMotion.isReducedMotion(context)) {
        setState(() {
          _dragOffsetY = 0.0;
        });
      } else {
        _snapBackAnimation = Tween<double>(begin: _dragOffsetY, end: 0.0)
            .animate(
              CurvedAnimation(
                parent: _snapBackController,
                curve: AppMotion.buttonSpring,
              ),
            );
        _snapBackController.forward(from: 0.0);
      }
    }
  }

  void _toggleChrome() {
    HapticFeedback.selectionClick();
    setState(() => _showChrome = !_showChrome);
  }

  void _showMediaDetailsSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final fileSizeMb = (widget.item.sizeBytes / (1024 * 1024)).toStringAsFixed(
      2,
    );
    final dateStr = widget.item.lastModified
        .toLocal()
        .toString()
        .split('.')
        .first;

    KeevaBottomSheet.show(
      context: context,
      builder: (context) {
        return Padding(
          padding: AppSpacing.sheetPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Media Information',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              _buildInfoRow('File Name', widget.item.displayName),
              _buildInfoRow(
                'Media Type',
                widget.item.isVideo ? 'Video (MP4)' : 'Photo (JPEG)',
              ),
              _buildInfoRow('File Size', '$fileSizeMb MB'),
              _buildInfoRow('Date Modified', dateStr),
              _buildInfoRow(
                'Storage Access',
                'Android SAF Document ID (Protected)',
              ),
              const SizedBox(height: AppSpacing.space16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewerState = ref.watch(viewerNotifierProvider);
    final saveState = ref.watch(saveNotifierProvider);

    // Save toast notifications
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

    final isReduced = AppMotion.isReducedMotion(context);

    // Scrim opacity decreases as image is dragged away
    final double dragProgress = (_dragOffsetY.abs() / 300.0).clamp(0.0, 1.0);
    final double backgroundOpacity = (1.0 - (dragProgress * 0.75)).clamp(
      0.2,
      1.0,
    );
    final double mediaScale = (1.0 - (dragProgress * 0.12)).clamp(0.85, 1.0);

    // Keep button state resolution
    final KeepState keepState;
    if (saveState.isInProgress && saveState.currentItemId == widget.item.id) {
      keepState = KeepState.saving;
    } else if (saveState.isSuccess &&
        saveState.currentItemId == widget.item.id) {
      keepState = KeepState.success;
    } else if (saveState.isFailure &&
        saveState.currentItemId == widget.item.id) {
      keepState = KeepState.failure;
    } else if (widget.item.isSaved) {
      keepState = KeepState.alreadyKept;
    } else {
      keepState = KeepState.idle;
    }

    final String? activeVideoPath =
        (widget.mediaPath != null && widget.mediaPath!.endsWith('.mp4'))
        ? widget.mediaPath
        : (viewerState is ViewerReady &&
              viewerState.isVideo &&
              viewerState.mediaPath.isNotEmpty)
        ? viewerState.mediaPath
        : null;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: backgroundOpacity),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. INTERACTIVE FULLSCREEN MEDIA CANVAS (with 1:1 vertical drag dismiss)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleChrome,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, _dragOffsetY),
                child: Transform.scale(
                  scale: mediaScale,
                  child: Hero(
                    tag: 'status_hero_${widget.item.id}',
                    flightShuttleBuilder:
                        (
                          flightContext,
                          animation,
                          flightDirection,
                          fromHeroContext,
                          toHeroContext,
                        ) {
                          return ClipRRect(
                            borderRadius: AppRadius.borderMd,
                            child: toHeroContext.widget,
                          );
                        },
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (widget.item.isVideo &&
                                activeVideoPath != null) ...[
                              KeevaVideoPlayer(
                                videoPath: activeVideoPath,
                                showChrome: _showChrome,
                                onToggleChrome: _toggleChrome,
                              ),
                            ] else if (_resolvedThumbnailPath != null &&
                                _resolvedThumbnailPath!.isNotEmpty) ...[
                              Image.file(
                                File(_resolvedThumbnailPath!),
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => MediaPlaceholder(
                                  isVideo: widget.item.isVideo,
                                ),
                              ),
                            ] else ...[
                              MediaPlaceholder(isVideo: widget.item.isVideo),
                            ],

                            // Overlay indicator during video preparation or error
                            if (viewerState is ViewerPreparing &&
                                activeVideoPath == null)
                              Center(
                                child: LoadingIndicator.circular(
                                  size: 36,
                                  color: AppColors.darkPrimary,
                                ),
                              )
                            else if (viewerState is ViewerFailure)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.space24,
                                  ),
                                  child: ErrorState.fromFailure(
                                    failure: viewerState.failure,
                                    onRetry: () => ref
                                        .read(viewerNotifierProvider.notifier)
                                        .prepare(widget.item),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. TOP FLOATING CHROME
          AnimatedPositioned(
            duration: isReduced
                ? Duration.zero
                : const Duration(milliseconds: 240),
            curve: AppMotion.emphasizedDecelerate,
            top: _showChrome ? 0 : -90,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.space8,
                MediaQuery.viewPaddingOf(context).top + AppSpacing.space4,
                AppSpacing.space8,
                AppSpacing.space8,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000), // 70% black scrim
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      AppIcons.actionBack,
                      color: AppColors.darkTextPrimary,
                    ),
                    tooltip: 'Back',
                    onPressed: () {
                      if (widget.onDismiss != null) {
                        widget.onDismiss!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: Text(
                      FreshnessLabel.formatFreshness(widget.item.lastModified),
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      AppIcons.actionInfo,
                      color: AppColors.darkTextPrimary,
                    ),
                    tooltip: 'Media Details',
                    onPressed: () => _showMediaDetailsSheet(context),
                  ),
                ],
              ),
            ),
          ),

          // 3. BOTTOM FLOATING PILL BAR
          AnimatedPositioned(
            duration: isReduced
                ? Duration.zero
                : const Duration(milliseconds: 240),
            curve: AppMotion.emphasizedDecelerate,
            bottom: _showChrome
                ? MediaQuery.viewPaddingOf(context).bottom + AppSpacing.space24
                : -90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space8,
                  vertical: AppSpacing.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceLevel2.withValues(alpha: 0.95),
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: AppColors.darkBorderSubtle,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Share Button
                    TextButton.icon(
                      onPressed: () async {
                        if (widget.onShare != null) {
                          widget.onShare!(widget.item);
                        } else {
                          final useCase = ref.read(shareStatusUseCaseProvider);
                          await useCase(
                            id: widget.item.id,
                            displayName: widget.item.displayName,
                            mimeType: widget.item.mimeType,
                            isVideo: widget.item.isVideo,
                          );
                        }
                      },
                      icon: const Icon(
                        AppIcons.actionShare,
                        size: 18,
                        color: AppColors.darkTextPrimary,
                      ),
                      label: Text(
                        'Share',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.space8),

                    // Signature KeepButton (Viewer Action variant)
                    KeepButton(
                      state: keepState,
                      onPressed: () => ref
                          .read(saveNotifierProvider.notifier)
                          .save(widget.item),
                      onAlreadyKeptPressed: () {
                        KeevaBottomSheet.showAlreadyKeptOptions(
                          context: context,
                          item: widget.item,
                          onViewInVault: () {
                            if (widget.onDismiss != null) {
                              widget.onDismiss!();
                            } else {
                              Navigator.of(context).maybePop();
                            }
                            widget.onNavigateToKept?.call();
                          },
                          onSaveCopy: () {
                            ref
                                .read(saveNotifierProvider.notifier)
                                .save(widget.item);
                          },
                        );
                      },
                      variant: KeepButtonVariant.viewerAction,
                    ),

                    const SizedBox(width: AppSpacing.space8),

                    // Info Button
                    IconButton(
                      icon: const Icon(
                        AppIcons.actionInfo,
                        size: 20,
                        color: AppColors.darkTextSecondary,
                      ),
                      tooltip: 'Details',
                      onPressed: () => _showMediaDetailsSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
