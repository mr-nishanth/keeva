import '../../core/errors/app_failure.dart';
import '../../domain/entities/saved_media.dart';

/// Sealed hierarchy representing media save operations to the public device gallery.
sealed class SaveState {
  const SaveState();

  bool get isIdle => this is SaveIdle;
  bool get isInProgress => this is SaveInProgress;
  bool get isSuccess => this is SaveSuccess;
  bool get isFailure => this is SaveFailure;

  String? get currentItemId => switch (this) {
    SaveInProgress(:final itemId) => itemId,
    SaveSuccess(:final itemId) => itemId,
    SaveFailure(:final itemId) => itemId,
    _ => null,
  };
}

/// No save operation is currently active.
final class SaveIdle extends SaveState {
  const SaveIdle();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveIdle && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SaveIdle()';
}

/// Status [itemId] is actively being saved into the device gallery.
final class SaveInProgress extends SaveState {
  final String itemId;

  const SaveInProgress({required this.itemId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveInProgress &&
          other.runtimeType == runtimeType &&
          other.itemId == itemId);

  @override
  int get hashCode => Object.hash(runtimeType, itemId);

  @override
  String toString() => 'SaveInProgress(itemId: $itemId)';
}

/// Status [itemId] was successfully saved to MediaStore, yielding [savedMedia].
final class SaveSuccess extends SaveState {
  final String itemId;
  final SavedMedia savedMedia;

  const SaveSuccess({required this.itemId, required this.savedMedia});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveSuccess &&
          other.runtimeType == runtimeType &&
          other.itemId == itemId &&
          other.savedMedia == savedMedia);

  @override
  int get hashCode => Object.hash(runtimeType, itemId, savedMedia);

  @override
  String toString() =>
      'SaveSuccess(itemId: $itemId, savedUriOrPath: ${savedMedia.savedUriOrPath})';
}

/// Saving status [itemId] failed with [failure].
final class SaveFailure extends SaveState {
  final String itemId;
  final AppFailure failure;

  const SaveFailure({required this.itemId, required this.failure});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveFailure &&
          other.runtimeType == runtimeType &&
          other.itemId == itemId &&
          other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, itemId, failure);

  @override
  String toString() => 'SaveFailure(itemId: $itemId, failure: $failure)';
}
