/// Constants for platform channel communication with the Android native status subsystem.
abstract final class ChannelConstants {
  /// The primary MethodChannel identifier for status operations.
  static const String channelName = 'com.example.whatsapp_status_saver/scanner';

  // --- Production Method Names ---
  static const String methodCheckFolderAccess = 'checkFolderAccess';
  static const String methodRequestFolderAccess = 'requestFolderAccess';
  static const String methodScanStatuses = 'scanStatuses';
  static const String methodGetStatuses = 'getStatuses';
  static const String methodGetThumbnail = 'getThumbnail';
  static const String methodPrepareVideo = 'prepareVideo';
  static const String methodSaveStatus = 'saveStatus';
  static const String methodShareStatus = 'shareStatus';
  static const String methodClearCaches = 'clearCaches';
  static const String methodGetCacheStats = 'getCacheStats';
  static const String methodRevokeAccess = 'revokeAccess';

  // --- Transitional POC Method Names (Do not use in production domain) ---
  static const String methodVerifyMediaRead = 'verifyMediaRead';
  static const String methodSaveTestImage = 'saveTestImage';

  // --- Native Error Codes from AndroidStatusScanner.ErrorCodes ---
  static const String errAccessNotGranted = 'ACCESS_NOT_GRANTED';
  static const String errAccessRevoked = 'ACCESS_REVOKED';
  static const String errInvalidFolder = 'INVALID_FOLDER';
  static const String errStatusesUnavailable = 'STATUSES_UNAVAILABLE';
  static const String errDocumentNotFound = 'DOCUMENT_NOT_FOUND';
  static const String errReadFailed = 'READ_FAILED';
  static const String errThumbnailFailed = 'THUMBNAIL_FAILED';
  static const String errVideoCacheFailed = 'VIDEO_CACHE_FAILED';
  static const String errMediaStoreInsertFailed = 'MEDIASTORE_INSERT_FAILED';
  static const String errMediaStoreCopyFailed = 'MEDIASTORE_COPY_FAILED';
  static const String errMediaStoreFinalizeFailed =
      'MEDIASTORE_FINALIZE_FAILED';
  static const String errCacheWriteFailed = 'CACHE_WRITE_FAILED';
  static const String errUnknown = 'UNKNOWN';
}
