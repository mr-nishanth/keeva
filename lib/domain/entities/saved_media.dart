import 'status_item.dart';

/// An immutable domain entity representing a media item exported to the device's public gallery.
///
/// Kept intentionally minimal for Phase 2C; local persistence implementation is deferred to Phase 2I.
class SavedMedia {
  /// Unique identifier of the saved media record (corresponds to the status id).
  final String id;

  /// Original filename of the status (e.g., "6e0d286c4f34a812.jpg").
  final String originalFileName;

  /// The destination path or MediaStore URI where the media was saved.
  final String savedUriOrPath;

  /// High-level media categorization (image or video).
  final MediaType mediaType;

  /// MIME type string (e.g. "image/jpeg", "video/mp4").
  final String mimeType;

  /// File size in bytes.
  final int sizeBytes;

  /// Timestamp when the media was saved.
  final DateTime savedAt;

  const SavedMedia({
    required this.id,
    required this.originalFileName,
    required this.savedUriOrPath,
    required this.mediaType,
    required this.mimeType,
    required this.sizeBytes,
    required this.savedAt,
  });

  /// Convenience helper to check if this saved media is a video.
  bool get isVideo => mediaType == MediaType.video;

  /// Creates a copy of this [SavedMedia] with the given fields replaced.
  SavedMedia copyWith({
    String? id,
    String? originalFileName,
    String? savedUriOrPath,
    MediaType? mediaType,
    String? mimeType,
    int? sizeBytes,
    DateTime? savedAt,
  }) {
    return SavedMedia(
      id: id ?? this.id,
      originalFileName: originalFileName ?? this.originalFileName,
      savedUriOrPath: savedUriOrPath ?? this.savedUriOrPath,
      mediaType: mediaType ?? this.mediaType,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMedia &&
          other.runtimeType == runtimeType &&
          other.id == id &&
          other.originalFileName == originalFileName &&
          other.savedUriOrPath == savedUriOrPath &&
          other.mediaType == mediaType &&
          other.mimeType == mimeType &&
          other.sizeBytes == sizeBytes &&
          other.savedAt == savedAt);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    originalFileName,
    savedUriOrPath,
    mediaType,
    mimeType,
    sizeBytes,
    savedAt,
  );

  @override
  String toString() =>
      'SavedMedia(id: $id, originalFileName: $originalFileName, '
      'savedUriOrPath: $savedUriOrPath, mediaType: $mediaType, '
      'mimeType: $mimeType, sizeBytes: $sizeBytes, savedAt: $savedAt)';
}
