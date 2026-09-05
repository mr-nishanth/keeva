import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/data/datasources/status_platform_datasource.dart';
import 'package:whatsapp_status_saver/data/models/status_dto.dart';
import 'package:whatsapp_status_saver/data/repositories/status_repository_impl.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';
import 'package:whatsapp_status_saver/platform/status_scanner_platform_interface.dart';

/// Fake datasource enabling precise simulation of platform behavior and failures.
class FakeStatusPlatformDatasource implements StatusPlatformDatasource {
  PlatformAccessCheckResult accessCheckResult = const PlatformAccessCheckResult(
    hasAccess: true,
    status: 'valid',
    targetPackage: 'com.whatsapp',
  );

  PlatformAccessRequestResult accessRequestResult =
      const PlatformAccessRequestResult(granted: true, persisted: true);

  List<StatusDto> statusesToReturn = [];
  String thumbnailPathToReturn = '/cache/thumbnails/thumb_01.jpg';
  String videoPathToReturn = '/cache/videos/vid_01.mp4';
  SaveResultDto saveResultToReturn = const SaveResultDto(
    success: true,
    mediaType: 'image',
    displayName: 'saved_pic.jpg',
    bytesSaved: 10240,
    publicCollection: 'Pictures/SavedStatus',
    insertedUri: 'content://media/external/images/media/100',
  );

  CacheClearResultDto clearResultToReturn = const CacheClearResultDto(
    freedBytes: 15000000,
    thumbnailFreedBytes: 5000000,
    videoFreedBytes: 10000000,
  );

  CacheStatsDto cacheStatsToReturn = const CacheStatsDto(
    thumbnailCacheBytes: 10000000,
    videoCacheBytes: 20000000,
    totalCacheBytes: 30000000,
  );

  bool revokeResultToReturn = true;
  bool shareResultToReturn = true;
  AppFailure? failureToThrow;

  @override
  Future<PlatformAccessCheckResult> checkFolderAccess({
    String targetPackage = 'com.whatsapp',
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    return accessCheckResult;
  }

  @override
  Future<PlatformAccessRequestResult> requestFolderAccess({
    String targetPackage = 'com.whatsapp',
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    return accessRequestResult;
  }

  @override
  Future<List<StatusDto>> getStatuses({
    String targetPackage = 'com.whatsapp',
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    return statusesToReturn;
  }

  @override
  Future<String> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = 256,
    int height = 256,
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    return thumbnailPathToReturn;
  }

  @override
  Future<String> prepareVideo({required String id, int sizeBytes = 0}) async {
    if (failureToThrow != null) throw failureToThrow!;
    return videoPathToReturn;
  }

  @override
  Future<SaveResultDto> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    return saveResultToReturn;
  }

  @override
  Future<bool> shareStatus({
    required String id,
    String? displayName,
    bool isVideo = false,
    String? mimeType,
  }) async {
    if (failureToThrow != null) throw failureToThrow!;
    return shareResultToReturn;
  }

  @override
  Future<CacheClearResultDto> clearCaches() async {
    if (failureToThrow != null) throw failureToThrow!;
    return clearResultToReturn;
  }

  @override
  Future<CacheStatsDto> getCacheStats() async {
    if (failureToThrow != null) throw failureToThrow!;
    return cacheStatsToReturn;
  }

  @override
  Future<bool> revokeAccess({String targetPackage = 'com.whatsapp'}) async {
    if (failureToThrow != null) throw failureToThrow!;
    return revokeResultToReturn;
  }
}

void main() {
  late FakeStatusPlatformDatasource fakeDatasource;
  late StatusRepositoryImpl repository;

  setUp(() {
    fakeDatasource = FakeStatusPlatformDatasource();
    repository = StatusRepositoryImpl(fakeDatasource);
  });

  group('StatusRepositoryImpl', () {
    test(
      'checkAccess returns StorageAccessGranted when hasAccess is true',
      () async {
        fakeDatasource.accessCheckResult = const PlatformAccessCheckResult(
          hasAccess: true,
          status: 'valid',
          targetPackage: 'com.whatsapp',
        );

        final result = await repository.checkAccess();

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isA<StorageAccessGranted>());
        expect(
          (result.dataOrNull as StorageAccessGranted).targetPackage,
          equals('com.whatsapp'),
        );
      },
    );

    test('checkAccess maps revoked and invalid status states', () async {
      fakeDatasource.accessCheckResult = const PlatformAccessCheckResult(
        hasAccess: false,
        status: 'permission_revoked',
        targetPackage: 'com.whatsapp',
      );

      final resultRevoked = await repository.checkAccess();
      expect(resultRevoked.dataOrNull, isA<StorageAccessRevoked>());

      fakeDatasource.accessCheckResult = const PlatformAccessCheckResult(
        hasAccess: false,
        status: 'invalid',
        targetPackage: 'com.whatsapp',
      );

      final resultInvalid = await repository.checkAccess();
      expect(resultInvalid.dataOrNull, isA<StorageAccessInvalid>());
    });

    test('checkAccess propagates AppFailure correctly', () async {
      fakeDatasource.failureToThrow = const AccessRevokedFailure(
        'Revoked by user',
      );

      final result = await repository.checkAccess();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AccessRevokedFailure>());
      expect(result.failureOrNull?.message, equals('Revoked by user'));
    });

    test('requestAccess returns StorageAccessGranted on grant', () async {
      fakeDatasource.accessRequestResult = const PlatformAccessRequestResult(
        granted: true,
        persisted: true,
      );

      final result = await repository.requestAccess();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isA<StorageAccessGranted>());
    });

    test(
      'requestAccess maps denied user interaction to StorageAccessNotGranted',
      () async {
        fakeDatasource.accessRequestResult = const PlatformAccessRequestResult(
          granted: false,
          persisted: false,
          error: 'User cancelled',
        );

        final result = await repository.requestAccess();

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isA<StorageAccessNotGranted>());
      },
    );

    test('getStatuses maps DTO list to domain entity list', () async {
      fakeDatasource.statusesToReturn = [
        const StatusDto(
          id: 'stat_1',
          displayName: 'img1.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1000,
          lastModified: 1757000000000,
          isVideo: false,
        ),
        const StatusDto(
          id: 'stat_2',
          displayName: 'vid1.mp4',
          mimeType: 'video/mp4',
          sizeBytes: 50000,
          lastModified: 1757000001000,
          isVideo: true,
        ),
      ];

      final result = await repository.getStatuses();

      expect(result.isSuccess, isTrue);
      final items = result.dataOrNull!;
      expect(items.length, equals(2));

      expect(items[0].id, equals('stat_1'));
      expect(items[0].displayName, equals('img1.jpg'));
      expect(items[0].mediaType, equals(MediaType.image));

      expect(items[1].id, equals('stat_2'));
      expect(items[1].isVideo, isTrue);
      expect(items[1].mediaType, equals(MediaType.video));
    });

    test('getThumbnail delegates and returns local path', () async {
      fakeDatasource.thumbnailPathToReturn = '/cache/thumbnails/test.jpg';

      final result = await repository.getThumbnail(id: 'stat_opaque');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('/cache/thumbnails/test.jpg'));
    });

    test('prepareVideo delegates and returns video cache path', () async {
      fakeDatasource.videoPathToReturn = '/cache/videos/vid_test.mp4';

      final result = await repository.prepareVideo(id: 'stat_vid');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals('/cache/videos/vid_test.mp4'));
    });

    test('saveStatus maps SaveResultDto to SavedMedia domain entity', () async {
      fakeDatasource.saveResultToReturn = const SaveResultDto(
        success: true,
        mediaType: 'image',
        displayName: 'status_pic.jpg',
        bytesSaved: 2048,
        publicCollection: 'Pictures/SavedStatus',
        insertedUri: 'content://media/external/images/media/420',
      );

      final result = await repository.saveStatus(id: 'stat_save');

      expect(result.isSuccess, isTrue);
      final savedMedia = result.dataOrNull!;
      expect(savedMedia.id, equals('stat_save'));
      expect(savedMedia.originalFileName, equals('status_pic.jpg'));
      expect(
        savedMedia.savedUriOrPath,
        equals('content://media/external/images/media/420'),
      );
      expect(savedMedia.mediaType, equals(MediaType.image));
      expect(savedMedia.sizeBytes, equals(2048));
    });

    test(
      'saveStatus converts unsuccessful save into SaveFailedFailure',
      () async {
        fakeDatasource.saveResultToReturn = const SaveResultDto(
          success: false,
          mediaType: 'image',
          displayName: 'fail.jpg',
          bytesSaved: 0,
          publicCollection: '',
          error: 'MediaStore copy failed',
        );

        final result = await repository.saveStatus(id: 'stat_fail');

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<SaveFailedFailure>());
        expect(
          result.failureOrNull?.message,
          contains('MediaStore copy failed'),
        );
      },
    );

    test('clearCaches and getCacheStats map correctly', () async {
      final clearResult = await repository.clearCaches();
      expect(clearResult.isSuccess, isTrue);
      expect(clearResult.dataOrNull, equals(15000000));

      final statsResult = await repository.getCacheStats();
      expect(statsResult.isSuccess, isTrue);
      expect(statsResult.dataOrNull?['thumbnailBytes'], equals(10000000));
      expect(statsResult.dataOrNull?['totalBytes'], equals(30000000));
    });

    test('revokeAccess delegates to platform', () async {
      final result = await repository.revokeAccess();
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isTrue);
    });

    test('shareStatus delegates to platform successfully', () async {
      final result = await repository.shareStatus(
        id: 'status_123',
        isVideo: false,
        mimeType: 'image/jpeg',
      );
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isTrue);
    });

    test('shareStatus wraps failure if platform throws', () async {
      fakeDatasource.failureToThrow = const UnknownFailure(
        'Share intent failed',
      );
      final result = await repository.shareStatus(
        id: 'status_123',
        isVideo: false,
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });
}
