import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/platform/channel_constants.dart';

void main() {
  group('AppFailure.fromCode', () {
    test('maps ACCESS_NOT_GRANTED to AccessNotGrantedFailure', () {
      final failure = AppFailure.fromCode(
        ChannelConstants.errAccessNotGranted,
        'No permission',
      );
      expect(failure, isA<AccessNotGrantedFailure>());
      expect(failure.message, equals('No permission'));
      expect(failure.code, equals('ACCESS_NOT_GRANTED'));
    });

    test(
      'maps ACCESS_REVOKED and PERMISSION_REVOKED to AccessRevokedFailure',
      () {
        final f1 = AppFailure.fromCode(ChannelConstants.errAccessRevoked);
        expect(f1, isA<AccessRevokedFailure>());

        final f2 = AppFailure.fromCode('PERMISSION_REVOKED');
        expect(f2, isA<AccessRevokedFailure>());
      },
    );

    test('maps INVALID_FOLDER to InvalidFolderFailure', () {
      final failure = AppFailure.fromCode(ChannelConstants.errInvalidFolder);
      expect(failure, isA<InvalidFolderFailure>());
    });

    test('maps STATUSES_UNAVAILABLE to StatusesUnavailableFailure', () {
      final failure = AppFailure.fromCode(
        ChannelConstants.errStatusesUnavailable,
      );
      expect(failure, isA<StatusesUnavailableFailure>());
    });

    test('maps DOCUMENT_NOT_FOUND to DocumentNotFoundFailure', () {
      final failure = AppFailure.fromCode(ChannelConstants.errDocumentNotFound);
      expect(failure, isA<DocumentNotFoundFailure>());
    });

    test('maps READ_FAILED to ReadFailedFailure', () {
      final failure = AppFailure.fromCode(ChannelConstants.errReadFailed);
      expect(failure, isA<ReadFailedFailure>());
    });

    test('maps THUMBNAIL_FAILED to ThumbnailFailedFailure', () {
      final failure = AppFailure.fromCode(ChannelConstants.errThumbnailFailed);
      expect(failure, isA<ThumbnailFailedFailure>());
    });

    test('maps VIDEO_CACHE_FAILED and VIDEO_PREPARE_FAILED to VideoPrepareFailedFailure', () {
      final f1 = AppFailure.fromCode(ChannelConstants.errVideoCacheFailed);
      expect(f1, isA<VideoPrepareFailedFailure>());

      final f2 = AppFailure.fromCode('VIDEO_PREPARE_FAILED');
      expect(f2, isA<VideoPrepareFailedFailure>());
    });

    test('maps MediaStore errors to SaveFailedFailure', () {
      expect(
        AppFailure.fromCode(ChannelConstants.errMediaStoreInsertFailed),
        isA<SaveFailedFailure>(),
      );
      expect(
        AppFailure.fromCode(ChannelConstants.errMediaStoreCopyFailed),
        isA<SaveFailedFailure>(),
      );
      expect(
        AppFailure.fromCode(ChannelConstants.errMediaStoreFinalizeFailed),
        isA<SaveFailedFailure>(),
      );
    });

    test('maps CACHE_WRITE_FAILED to CacheWriteFailure', () {
      final failure = AppFailure.fromCode(ChannelConstants.errCacheWriteFailed);
      expect(failure, isA<CacheWriteFailure>());
    });

    test('maps null or unknown codes to UnknownFailure', () {
      final f1 = AppFailure.fromCode(null);
      expect(f1, isA<UnknownFailure>());

      final f2 = AppFailure.fromCode('SOME_RANDOM_CODE', 'Custom message');
      expect(f2, isA<UnknownFailure>());
      expect(f2.message, equals('Custom message'));
      expect(f2.code, equals('SOME_RANDOM_CODE'));
    });

    test('equality and hashcode verification', () {
      const f1 = DocumentNotFoundFailure('Not found', code: 'DOC_404');
      const f2 = DocumentNotFoundFailure('Not found', code: 'DOC_404');
      const f3 = DocumentNotFoundFailure('Other error', code: 'DOC_404');

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
    });
  });
}
