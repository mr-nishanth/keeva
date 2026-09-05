import '../../core/errors/app_failure.dart';

/// Sealed hierarchy representing media viewer preparation states.
sealed class ViewerState {
  const ViewerState();

  bool get isIdle => this is ViewerIdle;
  bool get isPreparing => this is ViewerPreparing;
  bool get isReady => this is ViewerReady;
  bool get isFailure => this is ViewerFailure;

  String? get currentItemId => switch (this) {
    ViewerPreparing(:final itemId) => itemId,
    ViewerReady(:final itemId) => itemId,
    ViewerFailure(:final itemId) => itemId,
    _ => null,
  };
}

/// Viewer is not currently displaying or preparing media.
final class ViewerIdle extends ViewerState {
  const ViewerIdle();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewerIdle && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ViewerIdle()';
}

/// Video status [itemId] is currently caching for hardware-accelerated playback.
final class ViewerPreparing extends ViewerState {
  final String itemId;

  const ViewerPreparing({required this.itemId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewerPreparing &&
          other.runtimeType == runtimeType &&
          other.itemId == itemId);

  @override
  int get hashCode => Object.hash(runtimeType, itemId);

  @override
  String toString() => 'ViewerPreparing(itemId: $itemId)';
}

/// Media [itemId] is ready for full-screen preview.
///
/// For video, [mediaPath] contains the local cached file path.
/// For image, [mediaPath] is empty as native video cache preparation is bypassed.
final class ViewerReady extends ViewerState {
  final String itemId;
  final String mediaPath;
  final bool isVideo;

  const ViewerReady({
    required this.itemId,
    required this.mediaPath,
    required this.isVideo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewerReady &&
          other.runtimeType == runtimeType &&
          other.itemId == itemId &&
          other.mediaPath == mediaPath &&
          other.isVideo == isVideo);

  @override
  int get hashCode => Object.hash(runtimeType, itemId, mediaPath, isVideo);

  @override
  String toString() =>
      'ViewerReady(itemId: $itemId, isVideo: $isVideo, mediaPath: $mediaPath)';
}

/// Preparing media for viewer failed with [failure].
final class ViewerFailure extends ViewerState {
  final String itemId;
  final AppFailure failure;

  const ViewerFailure({required this.itemId, required this.failure});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ViewerFailure &&
          other.runtimeType == runtimeType &&
          other.itemId == itemId &&
          other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, itemId, failure);

  @override
  String toString() => 'ViewerFailure(itemId: $itemId, failure: $failure)';
}
