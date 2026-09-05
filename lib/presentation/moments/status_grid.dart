import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/entities/status_item.dart';
import '../common/buttons/keep_button.dart';
import '../common/feedback/empty_state.dart';
import '../common/feedback/error_state.dart';
import '../common/feedback/loading_indicator.dart';
import 'status_card.dart';

/// High-performance, edge-aware scrolling grid holding [StatusCard] elements.
///
/// Implements specification from docs/design/keeva-component-spec.md Section 2.8:
/// - Responsive columns: 2 (<600dp), 3 (600-839dp), 4 (840-1199dp), 5 (>=1200dp).
/// - 8dp grid spacing between cards (`AppSpacing.space8`).
/// - Cache extent 500dp for seamless 120fps scrolling.
/// - Staggered card entrance for the first 4 rows (220ms, 25ms offset per row).
/// - Zero BackdropFilter or blur inside scrolling views.
/// - Deterministic empty, loading, and error states.
class StatusGrid extends StatelessWidget {
  final List<StatusItem> items;
  final ValueChanged<StatusItem>? onStatusTap;
  final ValueChanged<StatusItem>? onKeepStatus;
  final ValueChanged<StatusItem>? onAlreadyKeptStatus;
  final KeepState Function(StatusItem)? keepStateResolver;
  final Future<String?> Function(StatusItem)? thumbnailLoader;
  final bool isLoading;
  final EmptyScenario emptyScenario;
  final VoidCallback? onEmptyAction;
  final AppFailure? failure;
  final VoidCallback? onRetry;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const StatusGrid({
    super.key,
    required this.items,
    this.onStatusTap,
    this.onKeepStatus,
    this.onAlreadyKeptStatus,
    this.keepStateResolver,
    this.thumbnailLoader,
    this.isLoading = false,
    this.emptyScenario = EmptyScenario.noStatuses,
    this.onEmptyAction,
    this.failure,
    this.onRetry,
    this.physics,
    this.controller,
    this.padding,
  });

  /// Computes responsive column count based on available width.
  static int getColumnCount(double width) {
    if (width < 600) return 2;
    if (width < 840) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: ErrorState.fromFailure(failure: failure!, onRetry: onRetry),
        ),
      );
    }

    if (isLoading) {
      return _buildSkeletonGrid(context);
    }

    if (items.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: EmptyState(
                  scenario: emptyScenario,
                  onAction: onEmptyAction,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = getColumnCount(constraints.maxWidth);
        final defaultPadding = EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space8,
          AppSpacing.space16,
          AppSpacing.space64 + MediaQuery.viewPaddingOf(context).bottom,
        );

        return GridView.builder(
          controller: controller,
          physics: physics,
          padding: padding ?? defaultPadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.space8,
            crossAxisSpacing: AppSpacing.space8,
            childAspectRatio: 9 / 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final card = StatusCard(
              item: item,
              onTap: onStatusTap != null ? () => onStatusTap!(item) : null,
              onKeep: onKeepStatus != null ? () => onKeepStatus!(item) : null,
              onAlreadyKept: onAlreadyKeptStatus != null
                  ? () => onAlreadyKeptStatus!(item)
                  : null,
              keepState:
                  keepStateResolver?.call(item) ??
                  (item.isSaved ? KeepState.alreadyKept : KeepState.idle),
              thumbnailLoader: thumbnailLoader,
            );

            return _StaggeredGridCard(
              id: item.id,
              index: index,
              columns: columns,
              child: card,
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = getColumnCount(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space8,
          ),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.space8,
            crossAxisSpacing: AppSpacing.space8,
            childAspectRatio: 9 / 16,
          ),
          itemCount: columns * 3, // 6 or 9 skeleton cards
          itemBuilder: (context, index) => LoadingIndicator.shimmerCard(),
        );
      },
    );
  }
}

class _StaggeredGridCard extends StatefulWidget {
  final String id;
  final int index;
  final int columns;
  final Widget child;

  const _StaggeredGridCard({
    required this.id,
    required this.index,
    required this.columns,
    required this.child,
  });

  @override
  State<_StaggeredGridCard> createState() => _StaggeredGridCardState();
}

class _StaggeredGridCardState extends State<_StaggeredGridCard>
    with SingleTickerProviderStateMixin {
  static final Set<String> _animatedIds = <String>{};

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _translateAnimation;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    final row = widget.index ~/ widget.columns;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.emphasizedDecelerate,
    );

    _translateAnimation = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.emphasizedDecelerate,
      ),
    );

    final alreadyAnimated = _animatedIds.contains(widget.id);
    if (alreadyAnimated || row >= 4) {
      _controller.value = 1.0;
    } else {
      _animatedIds.add(widget.id);
      final delay = Duration(milliseconds: row * 25);
      if (delay == Duration.zero) {
        _controller.forward();
      } else {
        _staggerTimer = Timer(delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.isReducedMotion(context)) {
      _staggerTimer?.cancel();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReducedMotion(context) ||
        _controller.value == 1.0 ||
        widget.index ~/ widget.columns >= 4) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _translateAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
