import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/data/models/saved_media_dto.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';

void main() {
  group('SavedMediaDto', () {
    test('parses valid payload successfully', () {
      final map = <String, dynamic>{
        'id': 'stat_saved_1',
        'originalFileName': 'video.mp4',
        'savedUriOrPath': 'content://media/external/video/media/99',
        'mediaType': 'video',
        'mimeType': 'video/mp4',
        'sizeBytes': 3500000,
        'savedAt': 1757073600000,
      };

      final dto = SavedMediaDto.fromMap(map);

      expect(dto.id, equals('stat_saved_1'));
      expect(dto.originalFileName, equals('video.mp4'));
      expect(dto.mediaType, equals('video'));
      expect(dto.sizeBytes, equals(3500000));
      expect(dto.savedAt, equals(1757073600000));

      final entity = dto.toEntity();
      expect(entity.id, equals('stat_saved_1'));
      expect(entity.mediaType, equals(MediaType.video));
      expect(entity.isVideo, isTrue);
      expect(entity.savedAt.millisecondsSinceEpoch, equals(1757073600000));
    });

    test('throws FormatException on missing id', () {
      expect(
        () => SavedMediaDto.fromMap({'displayName': 'foo.jpg'}),
        throwsFormatException,
      );
    });

    test('converts fromEntity and toMap correctly', () {
      final entity = SavedMedia(
        id: 'stat_from_entity',
        originalFileName: 'pic.jpg',
        savedUriOrPath: 'path/pic.jpg',
        mediaType: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 4096,
        savedAt: DateTime.fromMillisecondsSinceEpoch(1757000000000),
      );

      final dto = SavedMediaDto.fromEntity(entity);
      expect(dto.id, equals('stat_from_entity'));
      expect(dto.mediaType, equals('image'));

      final map = dto.toMap();
      expect(map['id'], equals('stat_from_entity'));
      expect(map['sizeBytes'], equals(4096));
    });
  });
}
