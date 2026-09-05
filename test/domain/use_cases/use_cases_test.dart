import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
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
import 'package:whatsapp_status_saver/domain/use_cases/share_status_use_case.dart';

class FakeStatusRepository implements StatusRepository {
  String? lastPackageChecked;
  String? lastPackageRequested;
  String? lastPackageScanned;
  String? lastThumbnailId;
  String? lastVideoPreparedId;
  String? lastSavedId;
  String? lastSharedId;

  Result<StorageAccessState> accessStateToReturn = const Result.success(
    StorageAccessGranted(),
  );
  Result<List<StatusItem>> statusesToReturn = const Result.success([]);
  Result<String> thumbnailToReturn = const Result.success(
    '/cache/thumbnails/test.jpg',
  );
  Result<String> videoToReturn = const Result.success('/cache/videos/test.mp4');
  Result<SavedMedia> savedMediaToReturn = Result.success(
    SavedMedia(
      id: 'stat_1',
      originalFileName: 'saved.jpg',
      savedUriOrPath: 'content://path',
      mediaType: MediaType.image,
      mimeType: 'image/jpeg',
      sizeBytes: 1024,
      savedAt: DateTime.now(),
    ),
  );

  @override
  Future<Result<StorageAccessState>> checkAccess({
    String targetPackage = 'com.whatsapp',
  }) async {
    lastPackageChecked = targetPackage;
    return accessStateToReturn;
  }

  @override
  Future<Result<StorageAccessState>> requestAccess({
    String targetPackage = 'com.whatsapp',
  }) async {
    lastPackageRequested = targetPackage;
    return accessStateToReturn;
  }

  @override
  Future<Result<List<StatusItem>>> getStatuses({
    String targetPackage = 'com.whatsapp',
  }) async {
    lastPackageScanned = targetPackage;
    return statusesToReturn;
  }

  @override
  Future<Result<String>> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = 256,
    int height = 256,
  }) async {
    lastThumbnailId = id;
    return thumbnailToReturn;
  }

  @override
  Future<Result<String>> prepareVideo({
    required String id,
    int sizeBytes = 0,
  }) async {
    lastVideoPreparedId = id;
    return videoToReturn;
  }

  @override
  Future<Result<SavedMedia>> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async {
    lastSavedId = id;
    return savedMediaToReturn;
  }

  @override
  Future<Result<bool>> shareStatus({
    required String id,
    String? displayName,
    bool isVideo = false,
    String? mimeType,
  }) async {
    lastSharedId = id;
    return const Result.success(true);
  }

  @override
  Future<Result<int>> clearCaches() async => const Result.success(0);

  @override
  Future<Result<Map<String, int>>> getCacheStats() async =>
      const Result.success({});

  @override
  Future<Result<bool>> revokeAccess({
    String targetPackage = 'com.whatsapp',
  }) async => const Result.success(true);
}

void main() {
  late FakeStatusRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeStatusRepository();
  });

  group('Domain Use Cases', () {
    test(
      'CheckStorageAccessUseCase delegates to repository with package',
      () async {
        final useCase = CheckStorageAccessUseCase(fakeRepo);
        final result = await useCase(targetPackage: 'com.whatsapp.w4b');

        expect(result.isSuccess, isTrue);
        expect(fakeRepo.lastPackageChecked, equals('com.whatsapp.w4b'));
      },
    );

    test(
      'RequestStorageAccessUseCase delegates to repository with package',
      () async {
        final useCase = RequestStorageAccessUseCase(fakeRepo);
        final result = await useCase(targetPackage: 'com.whatsapp.w4b');

        expect(result.isSuccess, isTrue);
        expect(fakeRepo.lastPackageRequested, equals('com.whatsapp.w4b'));
      },
    );

    test('GetStatusesUseCase delegates to repository', () async {
      fakeRepo.statusesToReturn = Result.success([
        StatusItem(
          id: 'stat_test',
          displayName: 'pic.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 200,
          lastModified: DateTime.now(),
          isVideo: false,
        ),
      ]);

      final useCase = GetStatusesUseCase(fakeRepo);
      final result = await useCase();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, equals(1));
      expect(fakeRepo.lastPackageScanned, equals('com.whatsapp'));
    });

    test(
      'GetThumbnailUseCase delegates to repository with opaque ID',
      () async {
        final useCase = GetThumbnailUseCase(fakeRepo);
        final result = await useCase(id: 'stat_opaque_token', isVideo: false);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('/cache/thumbnails/test.jpg'));
        expect(fakeRepo.lastThumbnailId, equals('stat_opaque_token'));
      },
    );

    test(
      'PrepareVideoPlaybackUseCase delegates to repository with opaque ID',
      () async {
        final useCase = PrepareVideoPlaybackUseCase(fakeRepo);
        final result = await useCase(
          id: 'stat_video_opaque',
          sizeBytes: 1048576,
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('/cache/videos/test.mp4'));
        expect(fakeRepo.lastVideoPreparedId, equals('stat_video_opaque'));
      },
    );

    test(
      'SaveStatusUseCase delegates to repository with opaque ID and details',
      () async {
        final useCase = SaveStatusUseCase(fakeRepo);
        final result = await useCase(
          id: 'stat_save_opaque',
          displayName: 'custom.jpg',
        );

        expect(result.isSuccess, isTrue);
        expect(fakeRepo.lastSavedId, equals('stat_save_opaque'));
      },
    );

    test('ShareStatusUseCase delegates to repository with opaque ID', () async {
      final useCase = ShareStatusUseCase(fakeRepo);
      final result = await useCase(
        id: 'stat_share_opaque',
        isVideo: true,
        mimeType: 'video/mp4',
      );

      expect(result.isSuccess, isTrue);
      expect(fakeRepo.lastSharedId, equals('stat_share_opaque'));
    });
  });
}
