import '../../core/constants/app_constants.dart';
import '../../core/result/result.dart';
import '../entities/saved_media.dart';
import '../entities/status_item.dart';
import '../entities/storage_access_state.dart';

/// Domain contract for WhatsApp status discovery, access verification, and media operations.
///
/// Implementations must hide platform details, returning domain entities wrapped in [Result].
abstract interface class StatusRepository {
  /// Checks whether access to WhatsApp status directory is already granted.
  Future<Result<StorageAccessState>> checkAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Prompts the user via SAF directory picker to grant access to the status directory.
  Future<Result<StorageAccessState>> requestAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Discovers and enumerates all status media items currently visible.
  Future<Result<List<StatusItem>>> getStatuses({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Generates or retrieves a downsampled native thumbnail file path for the given status [id].
  ///
  /// The [id] is an opaque token that the repository delegates to the platform layer.
  Future<Result<String>> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  });

  /// Prepares a video status for smooth hardware-accelerated playback by caching it locally.
  ///
  /// Returns the local filesystem path to the cached video file.
  Future<Result<String>> prepareVideo({required String id, int sizeBytes = 0});

  /// Saves the specified status to the device's public gallery (MediaStore).
  Future<Result<SavedMedia>> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  });

  /// Opens the native Android share sheet with a FileProvider content URI.
  Future<Result<bool>> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  });

  /// Revokes the persisted SAF directory permission for the target package.
  Future<Result<bool>> revokeAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  });

  /// Clears native thumbnail and video caches, returning total bytes freed.
  Future<Result<int>> clearCaches();

  /// Retrieves cache usage statistics (e.g. thumbnail bytes, video bytes).
  Future<Result<Map<String, int>>> getCacheStats();
}
