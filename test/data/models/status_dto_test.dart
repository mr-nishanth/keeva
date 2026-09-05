import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/data/models/status_dto.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';

void main() {
  group('StatusDto', () {
    test('parses valid payload successfully', () {
      final map = <String, dynamic>{
        'id': 'stat_abc123',
        'displayName': 'image_01.jpg',
        'mimeType': 'image/jpeg',
        'sizeBytes': 204800,
        'lastModified': 1757073600000,
        'isVideo': false,
      };

      final dto = StatusDto.fromMap(map);

      expect(dto.id, equals('stat_abc123'));
      expect(dto.displayName, equals('image_01.jpg'));
      expect(dto.mimeType, equals('image/jpeg'));
      expect(dto.sizeBytes, equals(204800));
      expect(dto.lastModified, equals(1757073600000));
      expect(dto.isVideo, isFalse);

      final entity = dto.toEntity(isSaved: true);
      expect(entity.id, equals('stat_abc123'));
      expect(entity.displayName, equals('image_01.jpg'));
      expect(entity.isSaved, isTrue);
      expect(entity.mediaType, equals(MediaType.image));
      expect(entity.lastModified.millisecondsSinceEpoch, equals(1757073600000));
    });

    test('throws FormatException when id is missing or empty', () {
      expect(
        () => StatusDto.fromMap({'displayName': 'foo.jpg'}),
        throwsFormatException,
      );

      expect(
        () => StatusDto.fromMap({'id': '  ', 'displayName': 'foo.jpg'}),
        throwsFormatException,
      );

      expect(
        () => StatusDto.fromMap({'id': null, 'displayName': 'foo.jpg'}),
        throwsFormatException,
      );
    });

    test('handles backward-compatible "uri" key if "id" is absent', () {
      final map = <String, dynamic>{
        'uri': 'stat_legacy_fallback',
        'fileName': 'video.mp4',
        'mimeType': 'video/mp4',
      };

      final dto = StatusDto.fromMap(map);
      expect(dto.id, equals('stat_legacy_fallback'));
      expect(dto.displayName, equals('video.mp4'));
      expect(dto.isVideo, isTrue);
    });

    test('handles missing or malformed optional fields deterministically', () {
      final map = <String, dynamic>{
        'id': 'stat_minimal',
        'sizeBytes': -50, // Negative size clamped to 0
        'lastModified': 'invalid_date_string', // Should fallback to now
      };

      final dto = StatusDto.fromMap(map);

      expect(dto.id, equals('stat_minimal'));
      expect(dto.displayName, startsWith('status_'));
      expect(dto.mimeType, equals('image/jpeg'));
      expect(dto.sizeBytes, equals(0));
      expect(dto.lastModified, isPositive);
      expect(dto.isVideo, isFalse);
    });

    test('infers video from mimeType if isVideo boolean is missing', () {
      final map = <String, dynamic>{
        'id': 'stat_video_test',
        'mimeType': 'video/mp4',
      };

      final dto = StatusDto.fromMap(map);
      expect(dto.isVideo, isTrue);
    });

    test('converts fromEntity and serializes toMap', () {
      final item = StatusItem(
        id: 'stat_roundtrip',
        displayName: 'roundtrip.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 15000,
        lastModified: DateTime.fromMillisecondsSinceEpoch(1757000000000),
        isVideo: false,
      );

      final dto = StatusDto.fromEntity(item);
      expect(dto.id, equals('stat_roundtrip'));
      expect(dto.sizeBytes, equals(15000));

      final serialized = dto.toMap();
      expect(serialized['id'], equals('stat_roundtrip'));
      expect(serialized['sizeBytes'], equals(15000));
      expect(serialized['lastModified'], equals(1757000000000));
    });
  });
}
