import '../core/constants/app_constants.dart';
import '../data/models/status_dto.dart';

/// Result of querying folder access state across the platform channel.
class PlatformAccessCheckResult {
  final bool hasAccess;
  final String status;
  final String targetPackage;
  final String? treeUri;
  final String? resolvedStatusesDocId;

  const PlatformAccessCheckResult({
    required this.hasAccess,
    required this.status,
    required this.targetPackage,
    this.treeUri,
    this.resolvedStatusesDocId,
  });

  factory PlatformAccessCheckResult.fromMap(Map<Object?, Object?> map) {
    final hasAccess = map['hasAccess'] as bool? ?? false;
    final status =
        map['status'] as String? ?? (hasAccess ? 'valid' : 'invalid');
    final targetPackage =
        map['targetPackage'] as String? ?? AppConstants.whatsappStandardPackage;
    final treeUri = map['treeUri'] as String?;
    final resolvedStatusesDocId = map['resolvedStatusesDocId'] as String?;

    return PlatformAccessCheckResult(
      hasAccess: hasAccess,
      status: status,
      targetPackage: targetPackage,
      treeUri: treeUri,
      resolvedStatusesDocId: resolvedStatusesDocId,
    );
  }
}

/// Result of requesting SAF directory access via the system document picker.
class PlatformAccessRequestResult {
  final bool granted;
  final bool persisted;
  final String? status;
  final String? error;

  const PlatformAccessRequestResult({
    required this.granted,
    required this.persisted,
    this.status,
    this.error,
  });

  factory PlatformAccessRequestResult.fromMap(Map<Object?, Object?> map) {
    final granted = map['granted'] as bool? ?? false;
    final persisted = map['persisted'] as bool? ?? false;
    final status = map['status'] as String?;
    final error = map['error'] as String?;

    return PlatformAccessRequestResult(
      granted: granted,
      persisted: persisted,
      status: status,
      error: error,
    );
  }
}

/// Result of exporting media to the device's public MediaStore collections.
class SaveResultDto {
  final bool success;
  final String mediaType;
  final String displayName;
  final int bytesSaved;
  final String publicCollection;
  final String? insertedUri;
  final String? error;

  const SaveResultDto({
    required this.success,
    required this.mediaType,
    required this.displayName,
    required this.bytesSaved,
    required this.publicCollection,
    this.insertedUri,
    this.error,
  });

  factory SaveResultDto.fromMap(Map<Object?, Object?> map) {
    final success = map['success'] as bool? ?? false;
    final mediaType = map['mediaType'] as String? ?? 'image';
    final displayName = map['displayName'] as String? ?? '';
    final bytesSaved = (map['bytesSaved'] as num?)?.toInt() ?? 0;
    final publicCollection = map['publicCollection'] as String? ?? '';
    final insertedUri = map['insertedUri'] as String?;
    final error = map['error'] as String?;

    return SaveResultDto(
      success: success,
      mediaType: mediaType,
      displayName: displayName,
      bytesSaved: bytesSaved,
      publicCollection: publicCollection,
      insertedUri: insertedUri,
      error: error,
    );
  }
}

/// Cache capacity and usage statistics returned by the native storage subsystem.
class CacheStatsDto {
  final int thumbnailCacheBytes;
  final int videoCacheBytes;
  final int totalCacheBytes;

  const CacheStatsDto({
    required this.thumbnailCacheBytes,
    required this.videoCacheBytes,
    required this.totalCacheBytes,
  });

  factory CacheStatsDto.fromMap(Map<Object?, Object?> map) {
    final thumb = (map['thumbnailCacheBytes'] as num?)?.toInt() ?? 0;
    final video = (map['videoCacheBytes'] as num?)?.toInt() ?? 0;
    final total = (map['totalCacheBytes'] as num?)?.toInt() ?? (thumb + video);

    return CacheStatsDto(
      thumbnailCacheBytes: thumb,
      videoCacheBytes: video,
      totalCacheBytes: total,
    );
  }
}

/// Statistics for disk space freed after a cache clearance operation.
class CacheClearResultDto {
  final int freedBytes;
  final int thumbnailFreedBytes;
  final int videoFreedBytes;

  const CacheClearResultDto({
    required this.freedBytes,
    required this.thumbnailFreedBytes,
    required this.videoFreedBytes,
  });

  factory CacheClearResultDto.fromMap(Map<Object?, Object?> map) {
    final freed = (map['freedBytes'] as num?)?.toInt() ?? 0;
    final thumb = (map['thumbnailFreedBytes'] as num?)?.toInt() ?? 0;
    final video = (map['videoFreedBytes'] as num?)?.toInt() ?? 0;

    return CacheClearResultDto(
      freedBytes: freed,
      thumbnailFreedBytes: thumb,
      videoFreedBytes: video,
    );
  }
}

/// Abstract contract for interacting with the native platform's status discovery subsystem.
///
/// Implemented by [MethodChannelStatusScanner] for production Android execution and
/// mockable for isolated unit tests without device or engine dependencies.
abstract interface class StatusScannerPlatformInterface {
  /// Queries persisted SAF permissions and validates tree health.
  Future<PlatformAccessCheckResult> checkFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Requests directory access from the user via the system SAF tree picker.
  Future<PlatformAccessRequestResult> requestFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Scans the resolved `.Statuses` directory and returns all status DTO items.
  Future<List<StatusDto>> getStatuses({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Requests background thumbnail generation for an opaque status [id].
  Future<String> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  });

  /// Prepares an on-demand video cache file for an opaque status [id].
  Future<String> prepareVideo({required String id, int sizeBytes = 0});

  /// Exports an opaque status [id] to public MediaStore collections.
  Future<SaveResultDto> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  });

  /// Opens the native Android share sheet with a FileProvider content URI for status [id].
  Future<bool> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  });

  /// Clears native disk caches for thumbnails and prepared videos.
  Future<CacheClearResultDto> clearCaches();

  /// Retrieves cache usage statistics from native managers.
  Future<CacheStatsDto> getCacheStats();

  /// Revokes persisted SAF permissions for the target package.
  Future<bool> revokeAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });
}
