import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';

void main() {
  group('SavedMedia Entity', () {
    final testDate = DateTime.utc(2026, 9, 5, 12, 0, 0);

    test('instantiates with correct fields and detects media type', () {
      final media = SavedMedia(
        id: 'stat_123',
        originalFileName: 'vid.mp4',
        savedUriOrPath: 'content://media/external/video/media/42',
        mediaType: MediaType.video,
        mimeType: 'video/mp4',
        sizeBytes: 5000000,
        savedAt: testDate,
      );

      expect(media.id, equals('stat_123'));
      expect(media.originalFileName, equals('vid.mp4'));
      expect(
        media.savedUriOrPath,
        equals('content://media/external/video/media/42'),
      );
      expect(media.isVideo, isTrue);
      expect(media.mediaType, equals(MediaType.video));
      expect(media.sizeBytes, equals(5000000));
      expect(media.savedAt, equals(testDate));
    });

    test('copyWith and value equality', () {
      final original = SavedMedia(
        id: 'stat_1',
        originalFileName: 'pic.jpg',
        savedUriOrPath: 'path/to/pic.jpg',
        mediaType: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 12000,
        savedAt: testDate,
      );

      final copy = original.copyWith(sizeBytes: 15000);
      expect(copy.id, equals(original.id));
      expect(copy.sizeBytes, equals(15000));
      expect(copy.originalFileName, equals('pic.jpg'));

      final identicalInstance = SavedMedia(
        id: 'stat_1',
        originalFileName: 'pic.jpg',
        savedUriOrPath: 'path/to/pic.jpg',
        mediaType: MediaType.image,
        mimeType: 'image/jpeg',
        sizeBytes: 12000,
        savedAt: testDate,
      );

      expect(original, equals(identicalInstance));
      expect(original.hashCode, equals(identicalInstance.hashCode));
    });
  });
}
