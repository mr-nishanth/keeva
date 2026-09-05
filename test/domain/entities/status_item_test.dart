import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';

void main() {
  group('StatusItem Entity', () {
    final testDate = DateTime.utc(2026, 9, 5, 12, 0, 0);

    test('preserves opaque ID exactly without alteration', () {
      const opaqueId = 'stat_cHJpbWFyeTpBbmRyb2lkL21lZGlhL2NvbS53aGF0c2FwcA';
      final item = StatusItem(
        id: opaqueId,
        displayName: 'status_sample.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 102400,
        lastModified: testDate,
        isVideo: false,
      );

      // Verify opaque ID is strictly preserved
      expect(item.id, equals(opaqueId));
      expect(item.mediaType, equals(MediaType.image));
      expect(item.isSaved, isFalse);
    });

    test('correctly identifies video media type', () {
      final item = StatusItem(
        id: 'stat_video_123',
        displayName: 'status_video.mp4',
        mimeType: 'video/mp4',
        sizeBytes: 2048000,
        lastModified: testDate,
        isVideo: true,
        isSaved: true,
      );

      expect(item.isVideo, isTrue);
      expect(item.mediaType, equals(MediaType.video));
      expect(item.isSaved, isTrue);
    });

    test('copyWith produces updated copy with unchanged fields preserved', () {
      final original = StatusItem(
        id: 'stat_original_id',
        displayName: 'pic.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 500,
        lastModified: testDate,
        isVideo: false,
      );

      final updated = original.copyWith(
        isSaved: true,
        displayName: 'renamed.jpg',
      );

      expect(updated.id, equals(original.id));
      expect(updated.isSaved, isTrue);
      expect(updated.displayName, equals('renamed.jpg'));
      expect(updated.sizeBytes, equals(500));
      expect(updated.lastModified, equals(testDate));
    });

    test('value equality and hashCode', () {
      final i1 = StatusItem(
        id: 'stat_1',
        displayName: 'img.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 100,
        lastModified: testDate,
        isVideo: false,
      );
      final i2 = StatusItem(
        id: 'stat_1',
        displayName: 'img.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 100,
        lastModified: testDate,
        isVideo: false,
      );
      final i3 = StatusItem(
        id: 'stat_2',
        displayName: 'img.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 100,
        lastModified: testDate,
        isVideo: false,
      );

      expect(i1, equals(i2));
      expect(i1.hashCode, equals(i2.hashCode));
      expect(i1, isNot(equals(i3)));
    });
  });
}
