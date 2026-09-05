import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';
import 'package:whatsapp_status_saver/domain/repositories/status_repository.dart';

class FakeStatusRepository implements StatusRepository {
  Result<List<StatusItem>> statusesResult = const Result.success([]);
  int getStatusesCallCount = 0;
  Completer<Result<List<StatusItem>>>? getStatusesCompleter;

  @override
  Future<Result<List<StatusItem>>> getStatuses({
    String targetPackage = 'com.whatsapp',
  }) async {
    getStatusesCallCount++;
    if (getStatusesCompleter != null) {
      return getStatusesCompleter!.future;
    }
    return statusesResult;
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

StatusItem createSampleStatus({required String id, bool isVideo = false}) {
  return StatusItem(
    id: id,
    displayName: '$id.jpg',
    mimeType: isVideo ? 'video/mp4' : 'image/jpeg',
    sizeBytes: 1024,
    lastModified: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    isVideo: isVideo,
  );
}

void main() {
  group('StatusListNotifier', () {
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

    test('initial state is StatusListInitial with empty items', () {
      final state = container.read(statusListNotifierProvider);
      expect(state, isA<StatusListInitial>());
      expect(state.isInitial, isTrue);
      expect(state.items, isEmpty);
    });

    group('load', () {
      test('transitions loading -> success with items', () async {
        final sampleItems = [
          createSampleStatus(id: 'status_1'),
          createSampleStatus(id: 'status_2', isVideo: true),
        ];
        repository.statusesResult = Result.success(sampleItems);

        final notifier = container.read(statusListNotifierProvider.notifier);
        final loadFuture = notifier.load();

        expect(
          container.read(statusListNotifierProvider),
          isA<StatusListLoading>(),
        );
        expect(container.read(statusListNotifierProvider).isLoading, isTrue);

        await loadFuture;

        final state = container.read(statusListNotifierProvider);
        expect(state, isA<StatusListSuccess>());
        expect(state.isSuccess, isTrue);
        expect(state.items.length, 2);
        expect(state.items.first.id, 'status_1');
        expect(state.items.last.isVideo, isTrue);
      });

      test(
        'transitions loading -> empty when scan discovers 0 items',
        () async {
          repository.statusesResult = const Result.success([]);

          final notifier = container.read(statusListNotifierProvider.notifier);
          await notifier.load();

          final state = container.read(statusListNotifierProvider);
          expect(state, isA<StatusListEmpty>());
          expect(state.isEmpty, isTrue);
          expect(state.items, isEmpty);
        },
      );

      test('transitions loading -> failure on AppFailure', () async {
        repository.statusesResult = const Result.failure(
          ReadFailedFailure('Permission denied or folder inaccessible'),
        );

        final notifier = container.read(statusListNotifierProvider.notifier);
        await notifier.load();

        final state = container.read(statusListNotifierProvider);
        expect(state, isA<StatusListFailure>());
        expect(state.isFailure, isTrue);
        expect((state as StatusListFailure).failure, isA<ReadFailedFailure>());
        expect(state.items, isEmpty);
      });

      test('ignores duplicate concurrent load requests', () async {
        final completer = Completer<Result<List<StatusItem>>>();
        repository.getStatusesCompleter = completer;

        final notifier = container.read(statusListNotifierProvider.notifier);
        final firstFuture = notifier.load();
        final secondFuture = notifier.load();

        expect(repository.getStatusesCallCount, 1);

        completer.complete(
          Result.success([createSampleStatus(id: 'status_concurrent')]),
        );

        await firstFuture;
        await secondFuture;

        expect(
          container.read(statusListNotifierProvider),
          isA<StatusListSuccess>(),
        );
        expect(repository.getStatusesCallCount, 1);
      });
    });

    group('refresh', () {
      test(
        'transitions success -> refreshing -> success while preserving items',
        () async {
          final initialItems = [createSampleStatus(id: 'status_init')];
          final updatedItems = [
            createSampleStatus(id: 'status_init'),
            createSampleStatus(id: 'status_new'),
          ];

          repository.statusesResult = Result.success(initialItems);
          final notifier = container.read(statusListNotifierProvider.notifier);
          await notifier.load();

          expect(
            container.read(statusListNotifierProvider),
            isA<StatusListSuccess>(),
          );

          final completer = Completer<Result<List<StatusItem>>>();
          repository.getStatusesCompleter = completer;

          final refreshFuture = notifier.refresh();

          final refreshingState = container.read(statusListNotifierProvider);
          expect(refreshingState, isA<StatusListRefreshing>());
          expect(refreshingState.isRefreshing, isTrue);
          // Existing items preserved during refresh!
          expect(refreshingState.items.length, 1);
          expect(refreshingState.items.first.id, 'status_init');

          completer.complete(Result.success(updatedItems));
          await refreshFuture;

          final finalState = container.read(statusListNotifierProvider);
          expect(finalState, isA<StatusListSuccess>());
          expect(finalState.items.length, 2);
        },
      );

      test('transitions success -> refreshing -> failure and explicitly preserves existing items', () async {
        final initialItems = [
          createSampleStatus(id: 'status_1'),
          createSampleStatus(id: 'status_2'),
        ];

        repository.statusesResult = Result.success(initialItems);
        final notifier = container.read(statusListNotifierProvider.notifier);
        await notifier.load();

        // Now mock failure on refresh
        repository.statusesResult = const Result.failure(
          StatusesUnavailableFailure('Folder temporarily unavailable'),
        );

        await notifier.refresh();

        final state = container.read(statusListNotifierProvider);
        expect(state, isA<StatusListFailure>());
        expect(state.isFailure, isTrue);
        final failureState = state as StatusListFailure;
        expect(failureState.failure, isA<StatusesUnavailableFailure>());
        // Crucial test: previous items are explicitly retained in failure state!
        expect(failureState.previousItems, isNotNull);
        expect(failureState.previousItems!.length, 2);
        expect(failureState.items.length, 2);
        expect(failureState.items.first.id, 'status_1');
      });

      test(
        'transitions refreshing -> empty when refreshed directory has 0 items',
        () async {
          final initialItems = [createSampleStatus(id: 'status_expired')];
          repository.statusesResult = Result.success(initialItems);
          final notifier = container.read(statusListNotifierProvider.notifier);
          await notifier.load();

          repository.statusesResult = const Result.success([]);
          await notifier.refresh();

          final state = container.read(statusListNotifierProvider);
          expect(state, isA<StatusListEmpty>());
          expect(state.items, isEmpty);
        },
      );

      test('ignores duplicate concurrent refresh requests', () async {
        final initialItems = [createSampleStatus(id: 'status_1')];
        repository.statusesResult = Result.success(initialItems);
        final notifier = container.read(statusListNotifierProvider.notifier);
        await notifier.load();

        final completer = Completer<Result<List<StatusItem>>>();
        repository.getStatusesCompleter = completer;

        final firstRefresh = notifier.refresh();
        final secondRefresh = notifier.refresh();

        // 1 from load + 1 from first refresh
        expect(repository.getStatusesCallCount, 2);

        completer.complete(Result.success(initialItems));
        await firstRefresh;
        await secondRefresh;

        expect(
          container.read(statusListNotifierProvider),
          isA<StatusListSuccess>(),
        );
        expect(repository.getStatusesCallCount, 2);
      });
    });
  });
}
