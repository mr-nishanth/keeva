import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/viewer/viewer_state.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';
import 'package:whatsapp_status_saver/domain/repositories/status_repository.dart';

class FakeStatusRepository implements StatusRepository {
  Result<String> prepareVideoResult = const Result.success(
    '/data/user/0/com.example/cache/videos/cached_video.mp4',
  );
  int prepareVideoCallCount = 0;
  Completer<Result<String>>? prepareVideoCompleter;

  @override
  Future<Result<String>> prepareVideo({
    required String id,
    int sizeBytes = 0,
  }) async {
    prepareVideoCallCount++;
    if (prepareVideoCompleter != null) {
      return prepareVideoCompleter!.future;
    }
    return prepareVideoResult;
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
  Future<Result<SavedMedia>> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async => Result.failure(const UnknownFailure('Not implemented in fake'));

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

StatusItem createItem({required String id, required bool isVideo}) {
  return StatusItem(
    id: id,
    displayName: '$id.${isVideo ? 'mp4' : 'jpg'}',
    mimeType: isVideo ? 'video/mp4' : 'image/jpeg',
    sizeBytes: 4096,
    lastModified: DateTime.now(),
    isVideo: isVideo,
  );
}

void main() {
  group('ViewerNotifier', () {
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

    test('initial state is ViewerIdle', () {
      final state = container.read(viewerNotifierProvider);
      expect(state, isA<ViewerIdle>());
      expect(state.isIdle, isTrue);
      expect(state.currentItemId, isNull);
    });

    test('image item transitions immediately to ViewerReady with no native video preparation', () async {
      final imageItem = createItem(id: 'img_opaque_1', isVideo: false);
      final notifier = container.read(viewerNotifierProvider.notifier);

      await notifier.prepare(imageItem);

      expect(repository.prepareVideoCallCount, 0); // Video cache bypassed!
      final state = container.read(viewerNotifierProvider);
      expect(state, isA<ViewerReady>());
      expect(state.isReady, isTrue);
      final readyState = state as ViewerReady;
      expect(readyState.itemId, 'img_opaque_1');
      expect(readyState.isVideo, isFalse);
      expect(readyState.mediaPath, isEmpty);
    });

    test(
      'video item transitions idle -> preparing -> ready on success',
      () async {
        final videoItem = createItem(id: 'vid_opaque_2', isVideo: true);
        repository.prepareVideoResult = const Result.success(
          '/cache/videos/vid_opaque_2.mp4',
        );

        final notifier = container.read(viewerNotifierProvider.notifier);
        final prepareFuture = notifier.prepare(videoItem);

        final preparingState = container.read(viewerNotifierProvider);
        expect(preparingState, isA<ViewerPreparing>());
        expect(preparingState.isPreparing, isTrue);
        expect((preparingState as ViewerPreparing).itemId, 'vid_opaque_2');
        expect(preparingState.currentItemId, 'vid_opaque_2');

        await prepareFuture;

        final readyState = container.read(viewerNotifierProvider);
        expect(readyState, isA<ViewerReady>());
        expect(readyState.isReady, isTrue);
        final ready = readyState as ViewerReady;
        expect(ready.itemId, 'vid_opaque_2');
        expect(ready.isVideo, isTrue);
        expect(ready.mediaPath, '/cache/videos/vid_opaque_2.mp4');
        expect(repository.prepareVideoCallCount, 1);
      },
    );

    test(
      'video preparation failure transitions idle -> preparing -> failure',
      () async {
        final videoItem = createItem(id: 'vid_fail_3', isVideo: true);
        repository.prepareVideoResult = const Result.failure(
          VideoPrepareFailedFailure('Failed to stream video to cache'),
        );

        final notifier = container.read(viewerNotifierProvider.notifier);
        await notifier.prepare(videoItem);

        final state = container.read(viewerNotifierProvider);
        expect(state, isA<ViewerFailure>());
        expect(state.isFailure, isTrue);
        final failureState = state as ViewerFailure;
        expect(failureState.itemId, 'vid_fail_3');
        expect(failureState.failure, isA<VideoPrepareFailedFailure>());
        expect(failureState.failure.message, 'Failed to stream video to cache');
      },
    );

    test(
      'concurrency: second request supersedes stale first request',
      () async {
        final videoItem1 = createItem(id: 'vid_stale_1', isVideo: true);
        final videoItem2 = createItem(id: 'vid_fresh_2', isVideo: true);

        final completer1 = Completer<Result<String>>();
        final completer2 = Completer<Result<String>>();

        final notifier = container.read(viewerNotifierProvider.notifier);

        // Start first video prepare
        repository.prepareVideoCompleter = completer1;
        final future1 = notifier.prepare(videoItem1);

        expect(
          (container.read(viewerNotifierProvider) as ViewerPreparing).itemId,
          'vid_stale_1',
        );

        // Quickly start second video prepare before first completes
        repository.prepareVideoCompleter = completer2;
        final future2 = notifier.prepare(videoItem2);

        expect(
          (container.read(viewerNotifierProvider) as ViewerPreparing).itemId,
          'vid_fresh_2',
        );

        // First (stale) completes now
        completer1.complete(const Result.success('/cache/videos/stale.mp4'));
        await future1;

        // State MUST NOT be updated by the stale first completion!
        expect(
          (container.read(viewerNotifierProvider) as ViewerPreparing).itemId,
          'vid_fresh_2',
        );

        // Second completes
        completer2.complete(const Result.success('/cache/videos/fresh.mp4'));
        await future2;

        final finalState = container.read(viewerNotifierProvider);
        expect(finalState, isA<ViewerReady>());
        expect((finalState as ViewerReady).itemId, 'vid_fresh_2');
        expect(finalState.mediaPath, '/cache/videos/fresh.mp4');
      },
    );

    test('reset restores state to ViewerIdle', () async {
      final item = createItem(id: 'vid_reset', isVideo: true);
      final notifier = container.read(viewerNotifierProvider.notifier);

      await notifier.prepare(item);
      expect(container.read(viewerNotifierProvider), isA<ViewerReady>());

      notifier.reset();
      expect(container.read(viewerNotifierProvider), isA<ViewerIdle>());
    });
  });
}
