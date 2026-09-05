import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/platform/channel_constants.dart';
import 'package:whatsapp_status_saver/platform/method_channel_status_scanner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelStatusScanner scanner;
  late List<MethodCall> log;

  setUp(() {
    log = [];
    scanner = const MethodChannelStatusScanner();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(ChannelConstants.channelName),
          (MethodCall methodCall) async {
            log.add(methodCall);
            switch (methodCall.method) {
              case ChannelConstants.methodCheckFolderAccess:
                return <String, dynamic>{
                  'hasAccess': true,
                  'status': 'valid',
                  'targetPackage': 'com.whatsapp',
                  'treeUri': 'content://com.android.externalstorage.documents/tree/primary%3AAndroid',
                  'resolvedStatusesDocId': 'primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
                };

              case ChannelConstants.methodRequestFolderAccess:
                return <String, dynamic>{
                  'granted': true,
                  'persisted': true,
                  'status': 'valid',
                };

              case ChannelConstants.methodGetStatuses:
                return <dynamic>[
                  <String, dynamic>{
                    'id': 'stat_test_01',
                    'displayName': 'image_test.jpg',
                    'mimeType': 'image/jpeg',
                    'sizeBytes': 10240,
                    'lastModified': 1757000000000,
                    'isVideo': false,
                  },
                ];

              case ChannelConstants.methodGetThumbnail:
                return <String, dynamic>{
                  'filePath': '/data/user/0/com.example/cache/thumbnails/stat_test_01.jpg',
                };

              case ChannelConstants.methodPrepareVideo:
                return <String, dynamic>{
                  'filePath':
                      '/data/user/0/com.example/cache/videos/stat_vid_01.mp4',
                };

              case ChannelConstants.methodSaveStatus:
                return <String, dynamic>{
                  'success': true,
                  'mediaType': 'image',
                  'displayName': 'status_pic.jpg',
                  'bytesSaved': 10240,
                  'publicCollection': 'Pictures/SavedStatus',
                  'insertedUri': 'content://media/external/images/media/777',
                };

              case ChannelConstants.methodClearCaches:
                return <String, dynamic>{
                  'freedBytes': 25000000,
                  'thumbnailFreedBytes': 10000000,
                  'videoFreedBytes': 15000000,
                };

              case ChannelConstants.methodGetCacheStats:
                return <String, dynamic>{
                  'thumbnailCacheBytes': 10000000,
                  'videoCacheBytes': 15000000,
                  'totalCacheBytes': 25000000,
                };

              case ChannelConstants.methodRevokeAccess:
                return <String, dynamic>{'revoked': true};

              default:
                return null;
            }
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(ChannelConstants.channelName),
          null,
        );
  });

  group('MethodChannelStatusScanner', () {
    test('checkFolderAccess invokes correct method and arguments', () async {
      final result = await scanner.checkFolderAccess(
        targetPackage: 'com.whatsapp.w4b',
      );

      expect(log, hasLength(1));
      expect(
        log.first.method,
        equals(ChannelConstants.methodCheckFolderAccess),
      );
      expect(
        log.first.arguments,
        equals({'targetPackage': 'com.whatsapp.w4b'}),
      );

      expect(result.hasAccess, isTrue);
      expect(result.status, equals('valid'));
      expect(result.targetPackage, equals('com.whatsapp'));
    });

    test(
      'requestFolderAccess invokes correct method and parses result',
      () async {
        final result = await scanner.requestFolderAccess(
          targetPackage: 'com.whatsapp',
        );

        expect(log, hasLength(1));
        expect(
          log.first.method,
          equals(ChannelConstants.methodRequestFolderAccess),
        );
        expect(result.granted, isTrue);
        expect(result.persisted, isTrue);
      },
    );

    test('getStatuses invokes method and safely parses DTO array', () async {
      final statuses = await scanner.getStatuses(targetPackage: 'com.whatsapp');

      expect(log, hasLength(1));
      expect(log.first.method, equals(ChannelConstants.methodGetStatuses));
      expect(statuses, hasLength(1));
      expect(statuses.first.id, equals('stat_test_01'));
      expect(statuses.first.displayName, equals('image_test.jpg'));
    });

    test('getThumbnail invokes method with serialized arguments', () async {
      final path = await scanner.getThumbnail(
        id: 'stat_thumb_id',
        isVideo: true,
        width: 128,
        height: 128,
      );

      expect(log, hasLength(1));
      expect(log.first.method, equals(ChannelConstants.methodGetThumbnail));
      expect(
        log.first.arguments,
        equals({
          'id': 'stat_thumb_id',
          'isVideo': true,
          'width': 128,
          'height': 128,
        }),
      );
      expect(path, contains('stat_test_01.jpg'));
    });

    test('prepareVideo invokes method with sizeBytes', () async {
      final path = await scanner.prepareVideo(
        id: 'stat_video_id',
        sizeBytes: 5242880,
      );

      expect(log, hasLength(1));
      expect(log.first.method, equals(ChannelConstants.methodPrepareVideo));
      expect(
        log.first.arguments,
        equals({'id': 'stat_video_id', 'sizeBytes': 5242880}),
      );
      expect(path, contains('stat_vid_01.mp4'));
    });

    test(
      'saveStatus invokes method with arguments and parses result',
      () async {
        final result = await scanner.saveStatus(
          id: 'stat_save_01',
          displayName: 'custom_name.jpg',
          mimeType: 'image/jpeg',
          isVideo: false,
        );

        expect(log, hasLength(1));
        expect(log.first.method, equals(ChannelConstants.methodSaveStatus));
        expect(result.success, isTrue);
        expect(result.displayName, equals('status_pic.jpg'));
        expect(result.bytesSaved, equals(10240));
      },
    );

    test(
      'clearCaches and getCacheStats invoke methods and parse metrics',
      () async {
        final clearResult = await scanner.clearCaches();
        expect(clearResult.freedBytes, equals(25000000));
        expect(clearResult.thumbnailFreedBytes, equals(10000000));

        final statsResult = await scanner.getCacheStats();
        expect(statsResult.thumbnailCacheBytes, equals(10000000));
        expect(statsResult.totalCacheBytes, equals(25000000));
      },
    );

    test('revokeAccess returns boolean result', () async {
      final revoked = await scanner.revokeAccess();
      expect(revoked, isTrue);
    });

    test('translates PlatformException to domain-safe AppFailure', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(ChannelConstants.channelName),
            (MethodCall methodCall) async {
              throw PlatformException(
                code: ChannelConstants.errStatusesUnavailable,
                message: 'SAF .Statuses directory missing',
              );
            },
          );

      expect(
        () => scanner.getStatuses(),
        throwsA(
          isA<StatusesUnavailableFailure>().having(
            (e) => e.message,
            'message',
            contains('.Statuses directory missing'),
          ),
        ),
      );
    });

    test('translates DOCUMENT_NOT_FOUND PlatformException to DocumentNotFoundFailure', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(ChannelConstants.channelName),
            (MethodCall methodCall) async {
              throw PlatformException(
                code: ChannelConstants.errDocumentNotFound,
                message: 'Target doc not found',
              );
            },
          );

      expect(
        () => scanner.getThumbnail(id: 'stat_missing'),
        throwsA(isA<DocumentNotFoundFailure>()),
      );
    });

    test(
      'handles empty thumbnail path by throwing ThumbnailFailedFailure',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(ChannelConstants.channelName),
              (MethodCall methodCall) async {
                return <String, dynamic>{'filePath': ''};
              },
            );

        expect(
          () => scanner.getThumbnail(id: 'stat_empty_path'),
          throwsA(isA<ThumbnailFailedFailure>()),
        );
      },
    );
  });
}
