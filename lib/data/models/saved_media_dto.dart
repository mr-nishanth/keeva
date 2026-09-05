import '../../domain/entities/saved_media.dart';
import '../../domain/entities/status_item.dart';

/// Data transfer object for saved media persistence and transport.
class SavedMediaDto {
  final String id;
  final String originalFileName;
  final String savedUriOrPath;
  final String mediaType;
  final String mimeType;
  final int sizeBytes;
  final int savedAt;

  const SavedMediaDto({
    required this.id,
    required this.originalFileName,
    required this.savedUriOrPath,
    required this.mediaType,
    required this.mimeType,
    required this.sizeBytes,
    required this.savedAt,
  });

  /// Parses a map into a [SavedMediaDto] safely with fallback validation.
  factory SavedMediaDto.fromMap(Map<Object?, Object?> map) {
    final rawId = map['id'];
    if (rawId == null || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException(
        'Malformed saved media payload: missing or empty required field "id"',
      );
    }

    final rawFileName = map['originalFileName'] ?? map['displayName'];
    final originalFileName = (rawFileName is String && rawFileName.isNotEmpty)
        ? rawFileName
        : 'saved_${DateTime.now().millisecondsSinceEpoch}';

    final rawPath = map['savedUriOrPath'] ?? map['insertedUri'];
    final savedUriOrPath = (rawPath is String && rawPath.isNotEmpty)
        ? rawPath
        : '';

    final rawMediaType = map['mediaType'];
    final mediaType = (rawMediaType is String && rawMediaType.isNotEmpty)
        ? rawMediaType.toLowerCase()
        : 'image';

    final rawMime = map['mimeType'];
    final mimeType = (rawMime is String && rawMime.isNotEmpty)
        ? rawMime
        : (mediaType == 'video' ? 'video/mp4' : 'image/jpeg');

    final sizeBytes = _parseNumber(map['sizeBytes'])?.toInt() ?? 0;
    final savedAt =
        _parseNumber(map['savedAt'])?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;

    return SavedMediaDto(
      id: rawId.trim(),
      originalFileName: originalFileName,
      savedUriOrPath: savedUriOrPath,
      mediaType: mediaType,
      mimeType: mimeType,
      sizeBytes: sizeBytes < 0 ? 0 : sizeBytes,
      savedAt: savedAt,
    );
  }

  /// Converts this DTO into a domain [SavedMedia] entity.
  SavedMedia toEntity() {
    return SavedMedia(
      id: id,
      originalFileName: originalFileName,
      savedUriOrPath: savedUriOrPath,
      mediaType: mediaType == 'video' ? MediaType.video : MediaType.image,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      savedAt: DateTime.fromMillisecondsSinceEpoch(savedAt),
    );
  }

  /// Creates a DTO from a domain [SavedMedia] entity.
  factory SavedMediaDto.fromEntity(SavedMedia entity) {
    return SavedMediaDto(
      id: entity.id,
      originalFileName: entity.originalFileName,
      savedUriOrPath: entity.savedUriOrPath,
      mediaType: entity.mediaType == MediaType.video ? 'video' : 'image',
      mimeType: entity.mimeType,
      sizeBytes: entity.sizeBytes,
      savedAt: entity.savedAt.millisecondsSinceEpoch,
    );
  }

  /// Serializes to a standard Map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalFileName': originalFileName,
      'savedUriOrPath': savedUriOrPath,
      'mediaType': mediaType,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'savedAt': savedAt,
    };
  }

  static num? _parseNumber(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMediaDto &&
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
      'SavedMediaDto(id: $id, originalFileName: $originalFileName, '
      'savedUriOrPath: $savedUriOrPath, mediaType: $mediaType, '
      'mimeType: $mimeType, sizeBytes: $sizeBytes, savedAt: $savedAt)';
}
