import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/entities/status_item.dart';
import '../common/buttons/keep_button.dart';
import '../common/media/freshness_label.dart';
import '../common/media/media_placeholder.dart';
import '../common/media/video_badge.dart';

/// Primary media thumbnail card in the Moments grid.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.7:
/// - Fixed aspect ratio 9:16.
/// - 12dp rounded corners (`AppRadius.borderMd`).
/// - Micro-interaction scale (0.98) on press.
/// - Kept badge (top-left) when saved.
/// - VideoBadge with duration (top-right) if video.
/// - Relative freshness label (bottom-left).
/// - Signature KeepButton (bottom-right) with 48dp hit area.
/// - Linear gradient scrim at bottom to ensure 14:1 contrast.
/// - Wrapped in [RepaintBoundary] to isolate thumbnail rendering from scroll.
class StatusCard extends StatefulWidget {
  final StatusItem item;
  final VoidCallback? onTap;
  final VoidCallback? onKeep;
  final VoidCallback? onAlreadyKept;
  final KeepState keepState;
  final bool isSelected;
  final String? thumbnailPath;
  final Future<String?> Function(StatusItem)? thumbnailLoader;

  const StatusCard({
    super.key,
    required this.item,
    this.onTap,
    this.onKeep,
    this.onAlreadyKept,
    this.keepState = KeepState.idle,
    this.isSelected = false,
    this.thumbnailPath,
    this.thumbnailLoader,
  });

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  bool _isPressed = false;
  String? _resolvedThumbnailPath;
  @override
  void initState() {
    super.initState();
    _resolvedThumbnailPath = widget.thumbnailPath;
    if (_resolvedThumbnailPath == null && widget.thumbnailLoader != null) {
      _loadThumbnail();
    }
  }

  @override
  void didUpdateWidget(covariant StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thumbnailPath != null &&
        widget.thumbnailPath != _resolvedThumbnailPath) {
      _resolvedThumbnailPath = widget.thumbnailPath;
    } else if (oldWidget.item.id != widget.item.id &&
        widget.thumbnailLoader != null) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    if (widget.thumbnailLoader == null) return;
    try {
      final path = await widget.thumbnailLoader!(widget.item);
      if (mounted) {
        setState(() {
          _resolvedThumbnailPath = path;
        });
      }
    } catch (_) {
      // Keep placeholder if load fails
    }
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  Widget _buildKeptBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceLevel1.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderPill,
        border: Border.all(
          color: AppColors.darkPrimary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            AppIcons.actionCheck,
            size: 12,
            color: AppColors.darkPrimary,
          ),
          const SizedBox(width: AppSpacing.space4),
          Text(
            'Kept',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.darkPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final path = _resolvedThumbnailPath;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            MediaPlaceholder(isVideo: widget.item.isVideo),
      );
    }

    return MediaPlaceholder(isVideo: widget.item.isVideo);
  }

  @override
  Widget build(BuildContext context) {
    final isKept =
        widget.item.isSaved ||
        widget.keepState == KeepState.alreadyKept ||
        widget.keepState == KeepState.success;

    final mediaTypeLabel = widget.item.isVideo ? 'Video' : 'Photo';
    final freshnessText = FreshnessLabel.formatFreshness(
      widget.item.lastModified,
    );
    final semanticDescription =
        '$mediaTypeLabel status, $freshnessText. ${isKept ? 'Already kept in vault. ' : ''}Double tap to preview.';

    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: semanticDescription,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: AppMotion.buttonSpring,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceLevel1,
                  borderRadius: AppRadius.borderMd,
                  border: widget.isSelected
                      ? Border.all(color: AppColors.darkPrimary, width: 2.0)
                      : Border.all(
                          color: AppColors.darkBorderSubtle,
                          width: 1.0,
                        ),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.borderMd,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Media Image / Placeholder with Hero transition
                      Hero(
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
                        child: _buildMediaContent(),
                      ),

                      // 2. Bottom linear scrim for typography contrast
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 72,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xB3000000), // rgba(0, 0, 0, 0.70)
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 3. Top-Left Kept Badge
                      if (isKept)
                        Positioned(
                          top: AppSpacing.space8,
                          left: AppSpacing.space8,
                          child: _buildKeptBadge(),
                        ),

                      // 4. Top-Right Video Badge
                      if (widget.item.isVideo)
                        const Positioned(
                          top: AppSpacing.space8,
                          right: AppSpacing.space8,
                          child: VideoBadge(durationMs: 0),
                        ),

                      // 5. Bottom-Left Freshness Label (bounded before KeepButton)
                      Positioned(
                        bottom: AppSpacing.space12,
                        left: AppSpacing.space8,
                        right: AppSpacing.space48 + AppSpacing.space4,
                        child: FreshnessLabel(
                          timestamp: widget.item.lastModified,
                        ),
                      ),

                      // 6. Bottom-Right Signature KeepButton
                      Positioned(
                        bottom: AppSpacing.space2,
                        right: AppSpacing.space2,
                        child: KeepButton(
                          state: widget.keepState,
                          onPressed: widget.onKeep,
                          onAlreadyKeptPressed: widget.onAlreadyKept,
                          variant: KeepButtonVariant.cardOverlay,
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
    );
  }
}
