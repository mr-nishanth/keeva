import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../../core/result/result.dart';
import '../../domain/entities/status_item.dart';
import '../../domain/use_cases/save_status_use_case.dart';
import '../providers.dart';
import 'save_state.dart';

/// Coordinates single-item media export operations to the system public gallery.
///
/// Ensures the opaque ID invariant is preserved and prevents concurrent duplicate saves.
class SaveNotifier extends Notifier<SaveState> {
  final SaveStatusUseCase? _saveStatusOverride;

  SaveNotifier({SaveStatusUseCase? saveStatusUseCase})
    : _saveStatusOverride = saveStatusUseCase;

  SaveStatusUseCase get _saveStatus =>
      _saveStatusOverride ?? ref.read(saveStatusUseCaseProvider);

  @override
  SaveState build() => const SaveIdle();

  /// Saves [item] into the public media library.
  ///
  /// Concurrency guard: Prevents concurrent duplicate saves for the same item.
  Future<void> save(StatusItem item) async {
    if (state is SaveInProgress &&
        (state as SaveInProgress).itemId == item.id) {
      return;
    }

    state = SaveInProgress(itemId: item.id);

    try {
      final result = await _saveStatus(
        id: item.id,
        displayName: item.displayName,
        mimeType: item.mimeType,
        isVideo: item.isVideo,
      );

      state = switch (result) {
        Success(:final data) => () {
          ref.read(statusListNotifierProvider.notifier).markItemSaved(item.id);
          return SaveSuccess(itemId: item.id, savedMedia: data);
        }(),
        Failure(:final failure) => SaveFailure(
          itemId: item.id,
          failure: failure,
        ),
      };
    } on AppFailure catch (failure) {
      state = SaveFailure(itemId: item.id, failure: failure);
    } catch (e) {
      state = SaveFailure(
        itemId: item.id,
        failure: UnknownFailure('Unexpected failure saving status media: $e'),
      );
    }
  }

  /// Resets notifier back to [SaveIdle].
  void reset() {
    state = const SaveIdle();
  }
}
