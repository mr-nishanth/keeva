import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/viewer/viewer_notifier.dart';
import 'package:whatsapp_status_saver/application/viewer/viewer_state.dart';
import 'package:whatsapp_status_saver/core/constants/app_constants.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/common/brand/keeva_logo.dart';
import 'package:whatsapp_status_saver/presentation/viewer/keeva_video_player.dart';
import 'package:whatsapp_status_saver/presentation/viewer/media_viewer_screen.dart';

class MockViewerNotifier extends ViewerNotifier {
  final ViewerState initialState;
  MockViewerNotifier(this.initialState);

  @override
  ViewerState build() => initialState;

  @override
  Future<void> prepare(StatusItem item) async {}
}

void main() {
  group('Phase 2H: Brand Identity & Video Player Tests', () {
    test('AppConstants brand name and high-res dimensions are configured', () {
      expect(AppConstants.appName, equals('Keeva'));
      expect(AppConstants.highResPreviewWidth, equals(1440));
      expect(AppConstants.highResPreviewHeight, equals(2560));
    });

    testWidgets('KeevaLogo renders CustomPaint with specified size and glow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: KeevaLogo(size: 84.0, showGlow: true)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KeevaLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final keevaLogo = tester.widget<KeevaLogo>(find.byType(KeevaLogo));
      expect(keevaLogo.size, equals(84.0));
      expect(keevaLogo.showGlow, isTrue);
    });

    testWidgets(
      'MediaViewerScreen renders CircularProgressIndicator while video is preparing',
      (tester) async {
        final videoItem = StatusItem(
          id: 'test_video_1',
          displayName: 'test_moment.mp4',
          mimeType: 'video/mp4',
          sizeBytes: 1024 * 1024 * 5,
          lastModified: DateTime.now().subtract(const Duration(minutes: 5)),
          isVideo: true,
          isSaved: false,
        );

        final mockViewer = MockViewerNotifier(
          const ViewerPreparing(itemId: 'test_video_1'),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [viewerNotifierProvider.overrideWith(() => mockViewer)],
            child: MaterialApp(
              theme: KeevaTheme.darkTheme,
              home: MediaViewerScreen(item: videoItem),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'MediaViewerScreen renders KeevaVideoPlayer when video is ready',
      (tester) async {
        final videoItem = StatusItem(
          id: 'test_video_ready',
          displayName: 'test_moment.mp4',
          mimeType: 'video/mp4',
          sizeBytes: 1024 * 1024 * 5,
          lastModified: DateTime.now().subtract(const Duration(minutes: 5)),
          isVideo: true,
          isSaved: false,
        );

        final mockViewer = MockViewerNotifier(
          const ViewerReady(
            itemId: 'test_video_ready',
            mediaPath: '/test/cache/test_moment.mp4',
            isVideo: true,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [viewerNotifierProvider.overrideWith(() => mockViewer)],
            child: MaterialApp(
              theme: KeevaTheme.darkTheme,
              home: MediaViewerScreen(item: videoItem),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(KeevaVideoPlayer), findsOneWidget);
      },
    );
  });
}
