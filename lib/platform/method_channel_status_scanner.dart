import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';
import '../data/models/status_dto.dart';
import 'channel_constants.dart';
import 'status_scanner_platform_interface.dart';

/// Concrete [StatusScannerPlatformInterface] communicating with Android native
/// services over the primary [MethodChannel].
///
/// **Architectural Boundary:**
/// This is the ONLY class in Dart permitted to communicate with [MethodChannel]
/// for status scanning. It translates raw channel maps into strongly typed DTOs
/// and converts [PlatformException] into domain-safe [AppFailure] instances.
class MethodChannelStatusScanner implements StatusScannerPlatformInterface {
  final MethodChannel _channel;

  const MethodChannelStatusScanner([
    MethodChannel channel = const MethodChannel(ChannelConstants.channelName),
  ]) : _channel = channel;

  @override
  Future<PlatformAccessCheckResult> checkFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodCheckFolderAccess,
      {'targetPackage': targetPackage},
    );
    return PlatformAccessCheckResult.fromMap(response);
  }

  @override
  Future<PlatformAccessRequestResult> requestFolderAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodRequestFolderAccess,
      {'targetPackage': targetPackage},
    );
    return PlatformAccessRequestResult.fromMap(response);
  }

  @override
  Future<List<StatusDto>> getStatuses({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    final response = await _invoke<List<Object?>>(
      ChannelConstants.methodGetStatuses,
      {'targetPackage': targetPackage},
    );

    final results = <StatusDto>[];
    for (final item in response) {
      if (item is Map<Object?, Object?>) {
        try {
          results.add(StatusDto.fromMap(item));
        } catch (_) {
          // Skip corrupt or unparseable items defensively without aborting entire scan
        }
      }
    }
    return results;
  }

  @override
  Future<String> getThumbnail({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  }) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodGetThumbnail,
      {'id': id, 'isVideo': isVideo, 'width': width, 'height': height},
    );

    final path = response['filePath'] as String?;
    if (path == null || path.isEmpty) {
      throw const ThumbnailFailedFailure(
        'Platform returned empty thumbnail file path.',
      );
    }
    return path;
  }

  @override
  Future<String> prepareVideo({required String id, int sizeBytes = 0}) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodPrepareVideo,
      {'id': id, 'sizeBytes': sizeBytes},
    );

    final path = response['filePath'] as String?;
    if (path == null || path.isEmpty) {
      throw const VideoPrepareFailedFailure(
        'Platform returned empty video cache file path.',
      );
    }
    return path;
  }

  @override
  Future<SaveResultDto> saveStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodSaveStatus,
      {
        'id': id,
        'displayName': ?displayName,
        'mimeType': ?mimeType,
        'isVideo': ?isVideo,
      },
    );

    return SaveResultDto.fromMap(response);
  }

  @override
  Future<bool> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodShareStatus,
      {
        'id': id,
        'displayName': ?displayName,
        'mimeType': ?mimeType,
        'isVideo': isVideo,
      },
    );

    return response['success'] as bool? ?? false;
  }

  @override
  Future<CacheClearResultDto> clearCaches() async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodClearCaches,
    );
    return CacheClearResultDto.fromMap(response);
  }

  @override
  Future<CacheStatsDto> getCacheStats() async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodGetCacheStats,
    );
    return CacheStatsDto.fromMap(response);
  }

  @override
  Future<bool> revokeAccess({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) async {
    final response = await _invoke<Map<Object?, Object?>>(
      ChannelConstants.methodRevokeAccess,
      {'targetPackage': targetPackage},
    );
    return response['revoked'] as bool? ?? false;
  }

  /// Internal invocation helper executing channel method and mapping [PlatformException].
  Future<T> _invoke<T>(String method, [Map<String, dynamic>? arguments]) async {
    try {
      final result = await _channel.invokeMethod<dynamic>(method, arguments);
      if (result == null && null is! T) {
        throw AppFailure.fromCode(
          ChannelConstants.errUnknown,
          'Null response received from native platform for method "$method"',
        );
      }
      return result as T;
    } on PlatformException catch (e) {
      throw AppFailure.fromCode(e.code, e.message);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw AppFailure.fromCode(
        ChannelConstants.errUnknown,
        'Failed executing native platform method "$method": $e',
      );
    }
  }
}
