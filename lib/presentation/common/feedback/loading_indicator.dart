import 'package:flutter/material.dart';

import 'package:whatsapp_status_saver/app/theme/app_colors.dart';
import 'package:whatsapp_status_saver/app/theme/app_motion.dart';
import 'package:whatsapp_status_saver/app/theme/app_radius.dart';

import '../media/media_placeholder.dart';

/// Loading indicator components for Keeva.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.12:
/// - CircularSpinner: 24dp or 40dp indeterminate in Aurora Mint (#10B981)
/// - ShimmerCard: 9:16 aspect ratio placeholder with subtle shimmer (disabled in reduced motion)
/// - LinearProgressBar: 2dp non-destructive top refresh line
abstract final class LoadingIndicator {
  /// Centered circular progress indicator in Aurora Mint.
  static Widget circular({double size = 24.0, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size > 28 ? 3.0 : 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.darkPrimary,
        ),
      ),
    );
  }

  /// 2dp linear progress bar for top refresh.
  static Widget linearBar({Color? color}) {
    return LinearProgressIndicator(
      minHeight: 2.0,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.darkPrimary),
    );
  }

  /// 9:16 skeleton shimmer card for grid loading.
  static Widget shimmerCard() {
    return const _ShimmerCardWidget();
  }
}

class _ShimmerCardWidget extends StatefulWidget {
  const _ShimmerCardWidget();

  @override
  State<_ShimmerCardWidget> createState() => _ShimmerCardWidgetState();
}

class _ShimmerCardWidgetState extends State<_ShimmerCardWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isReduced = AppMotion.isReducedMotion(context);
    if (isReduced) {
      _controller?.dispose();
      _controller = null;
    } else if (_controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _animation == null) {
      return const MediaPlaceholder();
    }

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: AnimatedBuilder(
        animation: _animation!,
        builder: (context, child) {
          final t = _animation!.value;
          final color = Color.lerp(
            AppColors.darkSurfaceLevel1,
            AppColors.darkSurfaceLevel2,
            t,
          );

          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
            ),
          );
        },
      ),
    );
  }
}
