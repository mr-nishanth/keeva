import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/saver/save_state.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/application/viewer/viewer_state.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
import 'package:whatsapp_status_saver/data/datasources/status_platform_datasource.dart';
import 'package:whatsapp_status_saver/data/models/status_dto.dart';
import 'package:whatsapp_status_saver/data/repositories/status_repository_impl.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';
import 'package:whatsapp_status_saver/domain/repositories/status_repository.dart';
import 'package:whatsapp_status_saver/domain/use_cases/check_storage_access_use_case.dart';
import 'package:whatsapp_status_saver/domain/use_cases/get_statuses_use_case.dart';
import 'package:whatsapp_status_saver/domain/use_cases/get_thumbnail_use_case.dart';
import 'package:whatsapp_status_saver/domain/use_cases/prepare_video_playback_use_case.dart';
import 'package:whatsapp_status_saver/domain/use_cases/request_storage_access_use_case.dart';
import 'package:whatsapp_status_saver/domain/use_cases/save_status_use_case.dart';
import 'package:whatsapp_status_saver/platform/status_scanner_platform_interface.dart';

class MockPlatformInterface implements StatusScannerPlatformInterface {
  @override
  Future<PlatformAccessCheckResult> checkFolderAccess({
    String targetPackage = 'com.whatsapp',
  }) async => const PlatformAccessCheckResult(
    hasAccess: true,
    status: 'valid',
    targetPackage: 'com.whatsapp',
  );

  @override
  Future<PlatformAccessRequestResult> requestFolderAccess({
    String targetPackage = 'com.whatsapp',
  }) async => const PlatformAccessRequestResult(
    granted: true,
    persisted: true,
    status: 'valid',
  );

  @override
  Future<List<StatusDto>> getStatuses({
    String targetPackage = 'com.whatsapp',
  }) async => [];

  @override
  Future<String> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = 256,
    int height = 256,
  }) async => '/thumb.jpg';

  @override
  Future<String> prepareVideo({required String id, int sizeBytes = 0}) async =>
      '/video.mp4';

  @override
  Future<SaveResultDto> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async => const SaveResultDto(
    success: true,
    mediaType: 'image',
    displayName: 'test.jpg',
    bytesSaved: 1024,
    publicCollection: 'Pictures',
  );

  @override
  Future<CacheClearResultDto> clearCaches() async => const CacheClearResultDto(
    freedBytes: 0,
    thumbnailFreedBytes: 0,
    videoFreedBytes: 0,
  );

  @override
  Future<CacheStatsDto> getCacheStats() async => const CacheStatsDto(
    thumbnailCacheBytes: 0,
    videoCacheBytes: 0,
    totalCacheBytes: 0,
  );

  @override
  Future<bool> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) async => true;

  @override
  Future<bool> revokeAccess({String targetPackage = 'com.whatsapp'}) async =>
      true;
}

class FakeStatusRepository implements StatusRepository {
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
  }) async => const Result.success('/fake/thumb.jpg');

  @override
  Future<Result<String>> prepareVideo({
    required String id,
    int sizeBytes = 0,
  }) async => const Result.success('/fake/video.mp4');

  @override
  Future<Result<SavedMedia>> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async => Result.success(
    SavedMedia(
      id: id,
      originalFileName: 'saved.jpg',
      savedUriOrPath: 'content://fake/path',
      mediaType: MediaType.image,
      mimeType: 'image/jpeg',
      sizeBytes: 1024,
      savedAt: DateTime.now(),
    ),
  );

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
  group('Provider Composition & Overrides', () {
    test('default providers compose complete dependency tree correctly', () {
      final container = ProviderContainer(
        overrides: [
          // Override platform interface to prevent real MethodChannel invocations in unit test
          statusScannerPlatformProvider.overrideWithValue(
            MockPlatformInterface(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final platform = container.read(statusScannerPlatformProvider);
      expect(platform, isA<MockPlatformInterface>());

      final datasource = container.read(statusPlatformDatasourceProvider);
      expect(datasource, isA<StatusPlatformDatasourceImpl>());

      final repository = container.read(statusRepositoryProvider);
      expect(repository, isA<StatusRepositoryImpl>());

      final checkUseCase = container.read(checkStorageAccessUseCaseProvider);
      expect(checkUseCase, isA<CheckStorageAccessUseCase>());

      final requestUseCase = container.read(
        requestStorageAccessUseCaseProvider,
      );
      expect(requestUseCase, isA<RequestStorageAccessUseCase>());

      final getStatusesUseCase = container.read(getStatusesUseCaseProvider);
      expect(getStatusesUseCase, isA<GetStatusesUseCase>());

      final getThumbnailUseCase = container.read(getThumbnailUseCaseProvider);
      expect(getThumbnailUseCase, isA<GetThumbnailUseCase>());

      final saveStatusUseCase = container.read(saveStatusUseCaseProvider);
      expect(saveStatusUseCase, isA<SaveStatusUseCase>());

      final prepareVideoUseCase = container.read(
        prepareVideoPlaybackUseCaseProvider,
      );
      expect(prepareVideoUseCase, isA<PrepareVideoPlaybackUseCase>());

      final accessState = container.read(accessNotifierProvider);
      expect(accessState, isA<AccessInitial>());

      final statusListState = container.read(statusListNotifierProvider);
      expect(statusListState, isA<StatusListInitial>());

      final saveState = container.read(saveNotifierProvider);
      expect(saveState, isA<SaveIdle>());

      final viewerState = container.read(viewerNotifierProvider);
      expect(viewerState, isA<ViewerIdle>());
    });

    test('providers allow clean repository override for UI testing', () async {
      final fakeRepo = FakeStatusRepository();
      final container = ProviderContainer(
        overrides: [statusRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      final accessNotifier = container.read(accessNotifierProvider.notifier);
      await accessNotifier.checkAccess();

      final accessState = container.read(accessNotifierProvider);
      expect(accessState, isA<AccessGranted>());
    });

    test('AccessState value equality and hashCode contracts', () {
      expect(const AccessInitial(), equals(const AccessInitial()));
      expect(const AccessChecking(), equals(const AccessChecking()));
      expect(const AccessRequesting(), equals(const AccessRequesting()));
      expect(
        const AccessGranted(targetPackage: 'com.whatsapp'),
        equals(const AccessGranted(targetPackage: 'com.whatsapp')),
      );
      expect(
        const AccessGranted(targetPackage: 'com.whatsapp').hashCode,
        equals(const AccessGranted(targetPackage: 'com.whatsapp').hashCode),
      );
      expect(const AccessNotGranted(), equals(const AccessNotGranted()));
      expect(
        const AccessRevoked(reason: 'r'),
        equals(const AccessRevoked(reason: 'r')),
      );
      expect(
        const AccessInvalid(reason: 'i'),
        equals(const AccessInvalid(reason: 'i')),
      );
      expect(
        const AccessUnavailable(reason: 'u'),
        equals(const AccessUnavailable(reason: 'u')),
      );
      expect(
        const AccessFailure(UnknownFailure('e')),
        equals(const AccessFailure(UnknownFailure('e'))),
      );
    });

    test('StatusListState value equality and hashCode contracts', () {
      expect(const StatusListInitial(), equals(const StatusListInitial()));
      expect(const StatusListLoading(), equals(const StatusListLoading()));
      expect(const StatusListEmpty(), equals(const StatusListEmpty()));

      final item = StatusItem(
        id: '1',
        displayName: '1.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 10,
        lastModified: DateTime(2026),
        isVideo: false,
      );

      expect(
        StatusListSuccess(items: [item]),
        equals(StatusListSuccess(items: [item])),
      );
      expect(
        StatusListRefreshing(items: [item]),
        equals(StatusListRefreshing(items: [item])),
      );
      expect(
        StatusListFailure(
          failure: const UnknownFailure('err'),
          previousItems: [item],
        ),
        equals(
          StatusListFailure(
            failure: const UnknownFailure('err'),
            previousItems: [item],
          ),
        ),
      );
    });

    test('SaveState value equality and hashCode contracts', () {
      expect(const SaveIdle(), equals(const SaveIdle()));
      expect(
        const SaveInProgress(itemId: '1'),
        equals(const SaveInProgress(itemId: '1')),
      );
      final media = SavedMedia(
        id: '1',
        originalFileName: '1.jpg',
        savedUriOrPath: 'uri',
        mediaType: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 10,
        savedAt: DateTime(2026),
      );
      expect(
        SaveSuccess(itemId: '1', savedMedia: media),
        equals(SaveSuccess(itemId: '1', savedMedia: media)),
      );
      expect(
        const SaveFailure(itemId: '1', failure: UnknownFailure('f')),
        equals(const SaveFailure(itemId: '1', failure: UnknownFailure('f'))),
      );
    });

    test('ViewerState value equality and hashCode contracts', () {
      expect(const ViewerIdle(), equals(const ViewerIdle()));
      expect(
        const ViewerPreparing(itemId: '1'),
        equals(const ViewerPreparing(itemId: '1')),
      );
      expect(
        const ViewerReady(itemId: '1', mediaPath: '/p', isVideo: true),
        equals(const ViewerReady(itemId: '1', mediaPath: '/p', isVideo: true)),
      );
      expect(
        const ViewerFailure(itemId: '1', failure: UnknownFailure('f')),
        equals(const ViewerFailure(itemId: '1', failure: UnknownFailure('f'))),
      );
    });
  });
}
