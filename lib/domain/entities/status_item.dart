/// Categorization of media formats supported by WhatsApp statuses.
enum MediaType { image, video }

/// An immutable domain entity representing a single discovered WhatsApp status item.
///
/// **Architectural Invariant (ADR 006):**
/// The [id] property is strictly opaque. Domain, application, and UI layers must never
/// parse, inspect, decode, or construct URIs from [id]. It is passed unmodified back
/// to repository methods for thumbnail generation, media saving, or video streaming.
class StatusItem {
  /// Opaque, stable identifier across platform boundaries.
  final String id;

  /// Display filename of the status (e.g., "6e0d286c4f34a812.jpg").
  final String displayName;

  /// MIME type string (e.g., "image/jpeg", "video/mp4").
  final String mimeType;

  /// File size in bytes.
  final int sizeBytes;

  /// Modification timestamp of the underlying status file.
  final DateTime lastModified;

  /// Whether this media represents a video status.
  final bool isVideo;

  /// Whether this status has been exported / saved to the user's gallery.
  final bool isSaved;

  const StatusItem({
    required this.id,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.lastModified,
    required this.isVideo,
    this.isSaved = false,
  });

  /// High-level [MediaType] convenience getter.
  MediaType get mediaType => isVideo ? MediaType.video : MediaType.image;

  /// Creates a copy of this [StatusItem] with the given fields replaced.
  StatusItem copyWith({
    String? id,
    String? displayName,
    String? mimeType,
    int? sizeBytes,
    DateTime? lastModified,
    bool? isVideo,
    bool? isSaved,
  }) {
    return StatusItem(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      lastModified: lastModified ?? this.lastModified,
      isVideo: isVideo ?? this.isVideo,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusItem &&
          other.runtimeType == runtimeType &&
          other.id == id &&
          other.displayName == displayName &&
          other.mimeType == mimeType &&
          other.sizeBytes == sizeBytes &&
          other.lastModified == lastModified &&
          other.isVideo == isVideo &&
          other.isSaved == isSaved);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    displayName,
    mimeType,
    sizeBytes,
    lastModified,
    isVideo,
    isSaved,
  );

  @override
  String toString() =>
      'StatusItem(id: $id, displayName: $displayName, mimeType: $mimeType, '
      'sizeBytes: $sizeBytes, lastModified: $lastModified, isVideo: $isVideo, '
      'isSaved: $isSaved)';
}
