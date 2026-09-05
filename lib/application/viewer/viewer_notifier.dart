import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../../core/result/result.dart';
import '../../domain/entities/status_item.dart';
import '../../domain/use_cases/prepare_video_playback_use_case.dart';
import '../providers.dart';
import 'viewer_state.dart';

/// Manages media preparation states for full-screen preview.
///
/// Prepares video files through [PrepareVideoPlaybackUseCase] and immediately
/// validates image items without unneeded background processing.
/// Implements token-based concurrency: newer requests supersede stale in-flight requests.
class ViewerNotifier extends Notifier<ViewerState> {
  final PrepareVideoPlaybackUseCase? _prepareVideoOverride;
  int _activeRequestId = 0;

  ViewerNotifier({PrepareVideoPlaybackUseCase? prepareVideoUseCase})
    : _prepareVideoOverride = prepareVideoUseCase;

  PrepareVideoPlaybackUseCase get _prepareVideo =>
      _prepareVideoOverride ?? ref.read(prepareVideoPlaybackUseCaseProvider);

  @override
  ViewerState build() => const ViewerIdle();

  /// Prepares [item] for full-screen viewing.
  ///
  /// For video media, caches the stream locally to allow seek and hardware decode.
  /// For image media, transitions immediately to [ViewerReady].
  ///
  /// Concurrency guard: Stale in-flight video preparation is discarded if another
  /// item is selected before completion.
  Future<void> prepare(StatusItem item) async {
    final requestId = ++_activeRequestId;
    state = ViewerPreparing(itemId: item.id);

    if (!item.isVideo) {
      state = ViewerReady(itemId: item.id, mediaPath: '', isVideo: false);
      return;
    }

    try {
      final result = await _prepareVideo(
        id: item.id,
        sizeBytes: item.sizeBytes,
      );

      if (requestId != _activeRequestId) {
        return;
      }

      state = switch (result) {
        Success(:final data) => ViewerReady(
          itemId: item.id,
          mediaPath: data,
          isVideo: true,
        ),
        Failure(:final failure) => ViewerFailure(
          itemId: item.id,
          failure: failure,
        ),
      };
    } on AppFailure catch (failure) {
      if (requestId == _activeRequestId) {
        state = ViewerFailure(itemId: item.id, failure: failure);
      }
    } catch (e) {
      if (requestId == _activeRequestId) {
        state = ViewerFailure(
          itemId: item.id,
          failure: UnknownFailure('Unexpected failure preparing video: $e'),
        );
      }
    }
  }

  /// Cancels in-flight preparation and resets to [ViewerIdle].
  void reset() {
    _activeRequestId++;
    state = const ViewerIdle();
  }
}
