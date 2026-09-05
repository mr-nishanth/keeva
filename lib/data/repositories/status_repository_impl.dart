import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';
import '../../core/result/result.dart';
import '../../domain/entities/saved_media.dart';
import '../../domain/entities/status_item.dart';
import '../../domain/entities/storage_access_state.dart';
import '../../domain/repositories/status_repository.dart';
import '../datasources/status_platform_datasource.dart';

/// Concrete implementation of [StatusRepository] coordinating the platform datasource
/// and mapping transport DTOs to immutable domain entities.
class StatusRepositoryImpl implements StatusRepository {
  final StatusPlatformDatasource _datasource;

  const StatusRepositoryImpl(this._datasource);

  @override
  Future<Result<StorageAccessState>> checkAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    try {
      final result = await _datasource.checkFolderAccess(
        targetPackage: targetPackage,
      );

      if (result.hasAccess) {
        return Result.success(
          StorageAccessGranted(targetPackage: result.targetPackage),
        );
      }

      final normalizedStatus = result.status.toLowerCase().trim();
      final accessState = switch (normalizedStatus) {
        'permission_revoked' || 'revoked' => const StorageAccessRevoked(
          reason: 'Storage access permission has been revoked.',
        ),
        'invalid' => const StorageAccessInvalid(
          reason: 'Selected directory does not contain WhatsApp statuses.',
        ),
        'unavailable' => const StorageAccessUnavailable(
          reason: 'WhatsApp status folder is unavailable on this device.',
        ),
        _ => const StorageAccessNotGranted(),
      };

      return Result.success(accessState);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure checking storage access: $e'),
      );
    }
  }

  @override
  Future<Result<StorageAccessState>> requestAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    try {
      final result = await _datasource.requestFolderAccess(
        targetPackage: targetPackage,
      );

      if (result.granted) {
        return Result.success(
          StorageAccessGranted(targetPackage: targetPackage),
        );
      }

      final normalizedStatus = result.status?.toLowerCase().trim();
      final accessState = switch (normalizedStatus) {
        'permission_revoked' || 'revoked' => StorageAccessRevoked(
          reason: result.error ?? 'Permission was revoked.',
        ),
        'invalid' => StorageAccessInvalid(
          reason: result.error ?? 'Invalid directory selected.',
        ),
        'unavailable' => StorageAccessUnavailable(
          reason: result.error ?? 'Statuses unavailable.',
        ),
        _ => const StorageAccessNotGranted(),
      };

      return Result.success(accessState);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure requesting storage access: $e'),
      );
    }
  }

  @override
  Future<Result<List<StatusItem>>> getStatuses({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    try {
      final dts = await _datasource.getStatuses(targetPackage: targetPackage);
      final items = dts.map((dto) => dto.toEntity()).toList();
      return Result.success(items);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure scanning status items: $e'),
      );
    }
  }

  @override
  Future<Result<String>> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  }) async {
    try {
      final path = await _datasource.getThumbnail(
        id: id,
        isVideo: isVideo,
        width: width,
        height: height,
      );
      return Result.success(path);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure generating thumbnail: $e'),
      );
    }
  }

  @override
  Future<Result<String>> prepareVideo({
    required String id,
    int sizeBytes = 0,
  }) async {
    try {
      final path = await _datasource.prepareVideo(id: id, sizeBytes: sizeBytes);
      return Result.success(path);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure preparing video: $e'),
      );
    }
  }

  @override
  Future<Result<SavedMedia>> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async {
    try {
      final saveResult = await _datasource.saveStatus(
        id: id,
        displayName: displayName,
        mimeType: mimeType,
        isVideo: isVideo,
      );

      if (!saveResult.success) {
        return Result.failure(
          SaveFailedFailure(saveResult.error ?? 'Failed to save media item.'),
        );
      }

      final isVideoMedia = isVideo ?? (saveResult.mediaType == 'video');
      final resolvedMime =
          mimeType ?? (isVideoMedia ? 'video/mp4' : 'image/jpeg');

      final savedMedia = SavedMedia(
        id: id,
        originalFileName: saveResult.displayName,
        savedUriOrPath: saveResult.insertedUri ?? saveResult.publicCollection,
        mediaType: isVideoMedia ? MediaType.video : MediaType.image,
        mimeType: resolvedMime,
        sizeBytes: saveResult.bytesSaved,
        savedAt: DateTime.now(),
      );

      return Result.success(savedMedia);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure saving status: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) async {
    try {
      final success = await _datasource.shareStatus(
        id: id,
        displayName: displayName,
        mimeType: mimeType,
        isVideo: isVideo,
      );
      return Result.success(success);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure sharing status media: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> revokeAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    try {
      final revoked = await _datasource.revokeAccess(
        targetPackage: targetPackage,
      );
      return Result.success(revoked);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure revoking storage access: $e'),
      );
    }
  }

  @override
  Future<Result<int>> clearCaches() async {
    try {
      final stats = await _datasource.clearCaches();
      return Result.success(stats.freedBytes);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure clearing caches: $e'),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getCacheStats() async {
    try {
      final stats = await _datasource.getCacheStats();
      return Result.success({
        'thumbnailBytes': stats.thumbnailCacheBytes,
        'videoBytes': stats.videoCacheBytes,
        'totalBytes': stats.totalCacheBytes,
      });
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        UnknownFailure('Unexpected failure retrieving cache stats: $e'),
      );
    }
  }
}
