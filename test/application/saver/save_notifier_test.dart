import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/saver/save_state.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';
import 'package:whatsapp_status_saver/domain/repositories/status_repository.dart';

class FakeStatusRepository implements StatusRepository {
  Result<SavedMedia> saveResult = Result.success(
    SavedMedia(
      id: 'item_1',
      originalFileName: 'item_1.jpg',
      savedUriOrPath: 'content://media/external/images/media/101',
      mediaType: MediaType.image,
      mimeType: 'image/jpeg',
      sizeBytes: 2048,
      savedAt: DateTime.now(),
    ),
  );

  int saveCallCount = 0;
  String? lastSavedId;
  Completer<Result<SavedMedia>>? saveCompleter;

  @override
  Future<Result<SavedMedia>> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async {
    saveCallCount++;
    lastSavedId = id;
    if (saveCompleter != null) {
      return saveCompleter!.future;
    }
    return saveResult;
  }

  @override
  Future<Result<StorageAccessState>> checkAccess({
    String targetPackage = 'com.whatsapp',
  }) async => const Result.success(StorageAccessGranted());

  @override
  Future<Result<StorageAccessState>> requestAccess({
    String targetPackage = 'com.whatsapp',
  }) async => const Result.success(StorageAccessGranted());

  @override
  Future<Result<List<StatusItem>>> getStatuses({
    String targetPackage = 'com.whatsapp',
  }) async => const Result.success([]);

  @override
  Future<Result<String>> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = 256,
    int height = 256,
  }) async => const Result.success('/cache/thumb.jpg');

  @override
  Future<Result<String>> prepareVideo({
    required String id,
    int sizeBytes = 0,
  }) async => const Result.success('/cache/video.mp4');

  @override
  Future<Result<bool>> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) async => const Result.success(true);

  @override
  Future<Result<bool>> revokeAccess({
    String targetPackage = 'com.whatsapp',
  }) async => const Result.success(true);

  @override
  Future<Result<int>> clearCaches() async => const Result.success(0);

  @override
  Future<Result<Map<String, int>>> getCacheStats() async =>
      const Result.success({});
}

StatusItem createTestItem({required String id, bool isVideo = false}) {
  return StatusItem(
    id: id,
    displayName: '$id.jpg',
    mimeType: isVideo ? 'video/mp4' : 'image/jpeg',
    sizeBytes: 1024,
    lastModified: DateTime.now(),
    isVideo: isVideo,
  );
}

void main() {
  group('SaveNotifier', () {
    late FakeStatusRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeStatusRepository();
      container = ProviderContainer(
        overrides: [statusRepositoryProvider.overrideWithValue(repository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is SaveIdle', () {
      final state = container.read(saveNotifierProvider);
      expect(state, isA<SaveIdle>());
      expect(state.isIdle, isTrue);
      expect(state.currentItemId, isNull);
    });

    test(
      'transitions idle -> saving -> success with preserved item id',
      () async {
        final item = createTestItem(id: 'status_opaque_123');
        repository.saveResult = Result.success(
          SavedMedia(
            id: item.id,
            originalFileName: item.displayName,
            savedUriOrPath: 'content://media/external/images/media/42',
            mediaType: MediaType.image,
            mimeType: item.mimeType,
            sizeBytes: item.sizeBytes,
            savedAt: DateTime.now(),
          ),
        );

        final notifier = container.read(saveNotifierProvider.notifier);
        final saveFuture = notifier.save(item);

        final inProgressState = container.read(saveNotifierProvider);
        expect(inProgressState, isA<SaveInProgress>());
        expect(inProgressState.isInProgress, isTrue);
        expect((inProgressState as SaveInProgress).itemId, 'status_opaque_123');
        expect(inProgressState.currentItemId, 'status_opaque_123');

        await saveFuture;

        final successState = container.read(saveNotifierProvider);
        expect(successState, isA<SaveSuccess>());
        expect(successState.isSuccess, isTrue);
        final success = successState as SaveSuccess;
        expect(success.itemId, 'status_opaque_123');
        expect(success.savedMedia.id, 'status_opaque_123');
        expect(
          success.savedMedia.savedUriOrPath,
          'content://media/external/images/media/42',
        );
      },
    );

    test('transitions idle -> saving -> failure with preserved failure and item id', () async {
      final item = createTestItem(id: 'status_fail_456');
      repository.saveResult = const Result.failure(
        SaveFailedFailure('MediaStore storage full or write denied'),
      );

      final notifier = container.read(saveNotifierProvider.notifier);
      await notifier.save(item);

      final state = container.read(saveNotifierProvider);
      expect(state, isA<SaveFailure>());
      expect(state.isFailure, isTrue);
      final failureState = state as SaveFailure;
      expect(failureState.itemId, 'status_fail_456');
      expect(failureState.failure, isA<SaveFailedFailure>());
      expect(
        failureState.failure.message,
        'MediaStore storage full or write denied',
      );
    });

    test('prevents duplicate concurrent saves for the same item', () async {
      final item = createTestItem(id: 'status_concurrent_789');
      final completer = Completer<Result<SavedMedia>>();
      repository.saveCompleter = completer;

      final notifier = container.read(saveNotifierProvider.notifier);
      final firstSave = notifier.save(item);
      final duplicateSave = notifier.save(item);

      expect(repository.saveCallCount, 1);

      completer.complete(
        Result.success(
          SavedMedia(
            id: item.id,
            originalFileName: item.displayName,
            savedUriOrPath: 'content://media/path',
            mediaType: MediaType.image,
            mimeType: item.mimeType,
            sizeBytes: item.sizeBytes,
            savedAt: DateTime.now(),
          ),
        ),
      );

      await firstSave;
      await duplicateSave;

      expect(container.read(saveNotifierProvider), isA<SaveSuccess>());
      expect(repository.saveCallCount, 1);
    });

    test('allows new save after previous save completes', () async {
      final item1 = createTestItem(id: 'status_first');
      final item2 = createTestItem(id: 'status_second');

      final notifier = container.read(saveNotifierProvider.notifier);

      await notifier.save(item1);
      expect(container.read(saveNotifierProvider), isA<SaveSuccess>());
      expect(
        (container.read(saveNotifierProvider) as SaveSuccess).itemId,
        'status_first',
      );

      await notifier.save(item2);
      expect(container.read(saveNotifierProvider), isA<SaveSuccess>());
      expect(
        (container.read(saveNotifierProvider) as SaveSuccess).itemId,
        'status_second',
      );
      expect(repository.saveCallCount, 2);
    });

    test('reset restores state to SaveIdle', () async {
      final item = createTestItem(id: 'status_reset');
      final notifier = container.read(saveNotifierProvider.notifier);

      await notifier.save(item);
      expect(container.read(saveNotifierProvider), isA<SaveSuccess>());

      notifier.reset();
      expect(container.read(saveNotifierProvider), isA<SaveIdle>());
      expect(container.read(saveNotifierProvider).isIdle, isTrue);
    });
  });
}
