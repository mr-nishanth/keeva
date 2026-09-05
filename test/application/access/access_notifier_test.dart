import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';
import 'package:whatsapp_status_saver/domain/repositories/status_repository.dart';

class FakeStatusRepository implements StatusRepository {
  Result<StorageAccessState> checkAccessResult = const Result.success(
    StorageAccessGranted(targetPackage: 'com.whatsapp'),
  );
  Result<StorageAccessState> requestAccessResult = const Result.success(
    StorageAccessGranted(targetPackage: 'com.whatsapp'),
  );

  int checkAccessCallCount = 0;
  int requestAccessCallCount = 0;

  Completer<Result<StorageAccessState>>? checkCompleter;
  Completer<Result<StorageAccessState>>? requestCompleter;

  @override
  Future<Result<StorageAccessState>> checkAccess({
    String targetPackage = 'com.whatsapp',
  }) async {
    checkAccessCallCount++;
    if (checkCompleter != null) {
      return checkCompleter!.future;
    }
    return checkAccessResult;
  }

  @override
  Future<Result<StorageAccessState>> requestAccess({
    String targetPackage = 'com.whatsapp',
  }) async {
    requestAccessCallCount++;
    if (requestCompleter != null) {
      return requestCompleter!.future;
    }
    return requestAccessResult;
  }

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

void main() {
  group('AccessNotifier', () {
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

    test('initial state is AccessInitial', () {
      final state = container.read(accessNotifierProvider);
      expect(state, isA<AccessInitial>());
      expect(state.isInitial, isTrue);
    });

    group('checkAccess', () {
      test('transitions checking -> granted on success', () async {
        repository.checkAccessResult = const Result.success(
          StorageAccessGranted(targetPackage: 'com.whatsapp'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        final checkFuture = notifier.checkAccess();

        expect(container.read(accessNotifierProvider), isA<AccessChecking>());
        await checkFuture;

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessGranted>());
        expect((state as AccessGranted).targetPackage, 'com.whatsapp');
        expect(state.isGranted, isTrue);
      });

      test('transitions checking -> not granted', () async {
        repository.checkAccessResult = const Result.success(
          StorageAccessNotGranted(),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.checkAccess();

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessNotGranted>());
        expect(state.isNotGranted, isTrue);
      });

      test('transitions checking -> revoked', () async {
        repository.checkAccessResult = const Result.success(
          StorageAccessRevoked(reason: 'Revoked by OS'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.checkAccess();

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessRevoked>());
        expect((state as AccessRevoked).reason, 'Revoked by OS');
        expect(state.isRevoked, isTrue);
      });

      test('transitions checking -> invalid', () async {
        repository.checkAccessResult = const Result.success(
          StorageAccessInvalid(reason: 'Missing status folder'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.checkAccess();

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessInvalid>());
        expect((state as AccessInvalid).reason, 'Missing status folder');
        expect(state.isInvalid, isTrue);
      });

      test('transitions checking -> unavailable', () async {
        repository.checkAccessResult = const Result.success(
          StorageAccessUnavailable(reason: 'WhatsApp not installed'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.checkAccess();

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessUnavailable>());
        expect((state as AccessUnavailable).reason, 'WhatsApp not installed');
        expect(state.isUnavailable, isTrue);
      });

      test('transitions checking -> failure on AppFailure', () async {
        repository.checkAccessResult = const Result.failure(
          AccessRevokedFailure('Permission denied'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.checkAccess();

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessFailure>());
        expect((state as AccessFailure).failure, isA<AccessRevokedFailure>());
        expect(state.isFailure, isTrue);
      });

      test('ignores duplicate concurrent checkAccess requests', () async {
        final completer = Completer<Result<StorageAccessState>>();
        repository.checkCompleter = completer;

        final notifier = container.read(accessNotifierProvider.notifier);
        final firstFuture = notifier.checkAccess();
        final secondFuture = notifier.checkAccess();

        expect(repository.checkAccessCallCount, 1);

        completer.complete(
          const Result.success(
            StorageAccessGranted(targetPackage: 'com.whatsapp'),
          ),
        );

        await firstFuture;
        await secondFuture;

        expect(container.read(accessNotifierProvider), isA<AccessGranted>());
        expect(repository.checkAccessCallCount, 1);
      });
    });

    group('requestAccess', () {
      test('transitions requesting -> granted on user approval', () async {
        repository.requestAccessResult = const Result.success(
          StorageAccessGranted(targetPackage: 'com.whatsapp'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        final requestFuture = notifier.requestAccess();

        expect(container.read(accessNotifierProvider), isA<AccessRequesting>());
        await requestFuture;

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessGranted>());
        expect(state.isGranted, isTrue);
      });

      test(
        'transitions requesting -> not granted on user cancellation',
        () async {
          repository.requestAccessResult = const Result.success(
            StorageAccessNotGranted(),
          );

          final notifier = container.read(accessNotifierProvider.notifier);
          await notifier.requestAccess();

          final state = container.read(accessNotifierProvider);
          expect(state, isA<AccessNotGranted>());
          expect(state.isNotGranted, isTrue);
        },
      );

      test('transitions requesting -> failure on platform error', () async {
        repository.requestAccessResult = const Result.failure(
          InvalidFolderFailure('Invalid folder selected'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.requestAccess();

        final state = container.read(accessNotifierProvider);
        expect(state, isA<AccessFailure>());
        expect((state as AccessFailure).failure, isA<InvalidFolderFailure>());
      });

      test('ignores duplicate concurrent requestAccess calls', () async {
        final completer = Completer<Result<StorageAccessState>>();
        repository.requestCompleter = completer;

        final notifier = container.read(accessNotifierProvider.notifier);
        final firstFuture = notifier.requestAccess();
        final secondFuture = notifier.requestAccess();

        expect(repository.requestAccessCallCount, 1);

        completer.complete(
          const Result.success(
            StorageAccessGranted(targetPackage: 'com.whatsapp'),
          ),
        );

        await firstFuture;
        await secondFuture;

        expect(container.read(accessNotifierProvider), isA<AccessGranted>());
        expect(repository.requestAccessCallCount, 1);
      });
    });

    group('refreshAccess', () {
      test('delegates to checkAccess and handles success', () async {
        repository.checkAccessResult = const Result.success(
          StorageAccessGranted(targetPackage: 'com.whatsapp'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.refreshAccess();

        expect(container.read(accessNotifierProvider), isA<AccessGranted>());
        expect(repository.checkAccessCallCount, 1);
      });

      test('delegates to checkAccess and handles failure', () async {
        repository.checkAccessResult = const Result.failure(
          StatusesUnavailableFailure('Not available'),
        );

        final notifier = container.read(accessNotifierProvider.notifier);
        await notifier.refreshAccess();

        expect(container.read(accessNotifierProvider), isA<AccessFailure>());
        expect(repository.checkAccessCallCount, 1);
      });
    });
  });
}
