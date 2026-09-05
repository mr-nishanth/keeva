import '../../domain/entities/status_item.dart';

/// Data transfer object for status media items across the platform boundary.
///
/// Performs safe, defensive validation of raw channel maps into structured Dart data.
class StatusDto {
  final String id;
  final String displayName;
  final String mimeType;
  final int sizeBytes;
  final int lastModified;
  final bool isVideo;
  final bool isSaved;

  const StatusDto({
    required this.id,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.lastModified,
    required this.isVideo,
    this.isSaved = false,
  });

  /// Safely parses a dynamic map returned from the platform channel into a [StatusDto].
  ///
  /// Enforces strict validation without unsafe type casts. Throws [FormatException]
  /// if the mandatory opaque [id] is missing or empty.
  factory StatusDto.fromMap(Map<Object?, Object?> map) {
    final rawId = map['id'] ?? map['uri'];
    if (rawId == null || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException(
        'Malformed status payload: missing or empty required field "id"',
      );
    }

    final rawName = map['displayName'] ?? map['fileName'];
    final displayName = (rawName is String && rawName.isNotEmpty)
        ? rawName
        : 'status_${DateTime.now().millisecondsSinceEpoch}';

    final rawMime = map['mimeType'];
    final mimeType = (rawMime is String && rawMime.isNotEmpty)
        ? rawMime
        : 'image/jpeg';

    final sizeBytes = _parseNumber(map['sizeBytes'])?.toInt() ?? 0;
    final lastModified =
        _parseNumber(map['lastModified'])?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;

    final rawIsVideo = map['isVideo'];
    final isVideo = rawIsVideo is bool
        ? rawIsVideo
        : mimeType.toLowerCase().startsWith('video/');

    final rawIsSaved = map['isSaved'];
    final isSaved = rawIsSaved is bool ? rawIsSaved : false;

    return StatusDto(
      id: rawId.trim(),
      displayName: displayName,
      mimeType: mimeType,
      sizeBytes: sizeBytes < 0 ? 0 : sizeBytes,
      lastModified: lastModified,
      isVideo: isVideo,
      isSaved: isSaved,
    );
  }

  /// Converts this DTO into a domain [StatusItem] entity.
  StatusItem toEntity({bool? isSaved}) {
    return StatusItem(
      id: id,
      displayName: displayName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      lastModified: DateTime.fromMillisecondsSinceEpoch(lastModified),
      isVideo: isVideo,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  /// Creates a DTO from an existing domain [StatusItem].
  factory StatusDto.fromEntity(StatusItem entity) {
    return StatusDto(
      id: entity.id,
      displayName: entity.displayName,
      mimeType: entity.mimeType,
      sizeBytes: entity.sizeBytes,
      lastModified: entity.lastModified.millisecondsSinceEpoch,
      isVideo: entity.isVideo,
      isSaved: entity.isSaved,
    );
  }

  /// Serializes to a standard Map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'lastModified': lastModified,
      'isVideo': isVideo,
      'isSaved': isSaved,
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
      (other is StatusDto &&
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
      'StatusDto(id: $id, displayName: $displayName, mimeType: $mimeType, '
      'sizeBytes: $sizeBytes, lastModified: $lastModified, isVideo: $isVideo, isSaved: $isSaved)';
}
