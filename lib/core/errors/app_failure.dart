/// Domain-safe failures representing operations that did not succeed.
///
/// Decouples UI, application, and domain layers from platform-specific exceptions
/// (such as MethodChannel, PlatformException, ContentResolver, or Android SAF).
sealed class AppFailure {
  final String message;
  final String? code;

  const AppFailure(this.message, {this.code});

  /// Factory constructor to map native platform error codes into domain-safe [AppFailure] instances.
  factory AppFailure.fromCode(String? code, [String? message]) {
    final normalizedCode = code?.toUpperCase().trim() ?? '';
    switch (normalizedCode) {
      case 'ACCESS_NOT_GRANTED':
        return AccessNotGrantedFailure(
          message ?? 'Folder access was not granted.',
          code: code,
        );
      case 'ACCESS_REVOKED':
      case 'PERMISSION_REVOKED':
        return AccessRevokedFailure(
          message ?? 'Storage access permission has been revoked.',
          code: code,
        );
      case 'INVALID_FOLDER':
        return InvalidFolderFailure(
          message ?? 'The selected directory is not a valid WhatsApp folder.',
          code: code,
        );
      case 'STATUSES_UNAVAILABLE':
        return StatusesUnavailableFailure(
          message ?? 'WhatsApp Status directory is unavailable or not found.',
          code: code,
        );
      case 'DOCUMENT_NOT_FOUND':
        return DocumentNotFoundFailure(
          message ?? 'The requested media item was not found.',
          code: code,
        );
      case 'READ_FAILED':
        return ReadFailedFailure(
          message ?? 'Failed to read media from storage.',
          code: code,
        );
      case 'THUMBNAIL_FAILED':
        return ThumbnailFailedFailure(
          message ?? 'Failed to generate media thumbnail.',
          code: code,
        );
      case 'VIDEO_PREPARE_FAILED':
      case 'VIDEO_CACHE_FAILED':
        return VideoPrepareFailedFailure(
          message ?? 'Failed to prepare video for playback.',
          code: code,
        );
      case 'SAVE_FAILED':
      case 'MEDIASTORE_INSERT_FAILED':
      case 'MEDIASTORE_COPY_FAILED':
      case 'MEDIASTORE_FINALIZE_FAILED':
        return SaveFailedFailure(
          message ?? 'Failed to save media to gallery.',
          code: code,
        );
      case 'CACHE_WRITE_FAILED':
        return CacheWriteFailure(
          message ?? 'Failed to write cache entry.',
          code: code,
        );
      default:
        return UnknownFailure(
          message ?? 'An unexpected error occurred.',
          code: code,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppFailure &&
          other.runtimeType == runtimeType &&
          other.message == message &&
          other.code == code);

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Indicates storage access was requested but not granted by the user.
final class AccessNotGrantedFailure extends AppFailure {
  const AccessNotGrantedFailure(
    super.message, {
    super.code = 'ACCESS_NOT_GRANTED',
  });
}

/// Indicates storage permission was granted previously but was subsequently revoked by the OS or user.
final class AccessRevokedFailure extends AppFailure {
  const AccessRevokedFailure(super.message, {super.code = 'ACCESS_REVOKED'});
}

/// Indicates the directory chosen does not match WhatsApp media structure expectations.
final class InvalidFolderFailure extends AppFailure {
  const InvalidFolderFailure(super.message, {super.code = 'INVALID_FOLDER'});
}

/// Indicates the `.Statuses` directory could not be resolved or opened.
final class StatusesUnavailableFailure extends AppFailure {
  const StatusesUnavailableFailure(
    super.message, {
    super.code = 'STATUSES_UNAVAILABLE',
  });
}

/// Indicates the specific media document ID does not exist in storage or cache.
final class DocumentNotFoundFailure extends AppFailure {
  const DocumentNotFoundFailure(
    super.message, {
    super.code = 'DOCUMENT_NOT_FOUND',
  });
}

/// Indicates reading bytes from the document stream failed.
final class ReadFailedFailure extends AppFailure {
  const ReadFailedFailure(super.message, {super.code = 'READ_FAILED'});
}

/// Indicates native thumbnail downsampling or decoding failed.
final class ThumbnailFailedFailure extends AppFailure {
  const ThumbnailFailedFailure(
    super.message, {
    super.code = 'THUMBNAIL_FAILED',
  });
}

/// Indicates on-demand video streaming cache preparation failed.
final class VideoPrepareFailedFailure extends AppFailure {
  const VideoPrepareFailedFailure(
    super.message, {
    super.code = 'VIDEO_PREPARE_FAILED',
  });
}

/// Indicates MediaStore insertion or stream transfer failed.
final class SaveFailedFailure extends AppFailure {
  const SaveFailedFailure(super.message, {super.code = 'SAVE_FAILED'});
}

/// Indicates writing into app-internal cache directory failed.
final class CacheWriteFailure extends AppFailure {
  const CacheWriteFailure(super.message, {super.code = 'CACHE_WRITE_FAILED'});
}

/// Fallback failure for unclassified exceptions.
final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message, {super.code = 'UNKNOWN'});
}
