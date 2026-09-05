import '../../core/constants/app_constants.dart';
import '../../platform/status_scanner_platform_interface.dart';
import '../models/status_dto.dart';

/// Datasource contract for querying and invoking platform status capabilities.
abstract interface class StatusPlatformDatasource {
  /// Checks whether folder access is granted for [targetPackage].
  Future<PlatformAccessCheckResult> checkFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Requests folder access via SAF picker for [targetPackage].
  Future<PlatformAccessRequestResult> requestFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Scans status documents from storage.
  Future<List<StatusDto>> getStatuses({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Decodes and returns local thumbnail path for status [id].
  Future<String> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  });

  /// Caches and returns local video file path for status [id].
  Future<String> prepareVideo({required String id, int sizeBytes = 0});

  /// Exports status [id] to MediaStore public collections.
  Future<SaveResultDto> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  });

  /// Opens native Android share sheet with a FileProvider content URI for status [id].
  Future<bool> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  });

  /// Clears native disk caches.
  Future<CacheClearResultDto> clearCaches();

  /// Retrieves cache usage metrics.
  Future<CacheStatsDto> getCacheStats();

  /// Revokes persisted SAF directory permission.
  Future<bool> revokeAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });
}

/// Default implementation of [StatusPlatformDatasource] delegating directly to [StatusScannerPlatformInterface].
class StatusPlatformDatasourceImpl implements StatusPlatformDatasource {
  final StatusScannerPlatformInterface _platform;

  const StatusPlatformDatasourceImpl(this._platform);

  @override
  Future<PlatformAccessCheckResult> checkFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _platform.checkFolderAccess(targetPackage: targetPackage);
  }

  @override
  Future<PlatformAccessRequestResult> requestFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _platform.requestFolderAccess(targetPackage: targetPackage);
  }

  @override
  Future<List<StatusDto>> getStatuses({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _platform.getStatuses(targetPackage: targetPackage);
  }

  @override
  Future<String> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  }) {
    return _platform.getThumbnail(
      id: id,
      isVideo: isVideo,
      width: width,
      height: height,
    );
  }

  @override
  Future<String> prepareVideo({required String id, int sizeBytes = 0}) {
    return _platform.prepareVideo(id: id, sizeBytes: sizeBytes);
  }

  @override
  Future<SaveResultDto> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) {
    return _platform.saveStatus(
      id: id,
      displayName: displayName,
      mimeType: mimeType,
      isVideo: isVideo,
    );
  }

  @override
  Future<bool> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) {
    return _platform.shareStatus(
      id: id,
      displayName: displayName,
      mimeType: mimeType,
      isVideo: isVideo,
    );
  }

  @override
  Future<CacheClearResultDto> clearCaches() {
    return _platform.clearCaches();
  }

  @override
  Future<CacheStatsDto> getCacheStats() {
    return _platform.getCacheStats();
  }

  @override
  Future<bool> revokeAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _platform.revokeAccess(targetPackage: targetPackage);
  }
}
