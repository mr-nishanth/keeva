import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/saver/save_notifier.dart';
import 'package:whatsapp_status_saver/application/saver/save_state.dart';
import 'package:whatsapp_status_saver/application/viewer/viewer_notifier.dart';
import 'package:whatsapp_status_saver/application/viewer/viewer_state.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/keep_button.dart';
import 'package:whatsapp_status_saver/presentation/common/feedback/error_state.dart';
import 'package:whatsapp_status_saver/presentation/viewer/media_viewer_screen.dart';
import 'package:whatsapp_status_saver/core/result/result.dart';
import 'package:whatsapp_status_saver/domain/repositories/status_repository.dart';

class FakeStatusRepository extends Fake implements StatusRepository {
  final Result<bool> shareResult;
  FakeStatusRepository({this.shareResult = const Success(true)});

  @override
  Future<Result<bool>> shareStatus({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) async {
    return shareResult;
  }
}

class MockViewerNotifier extends ViewerNotifier {
  final ViewerState initialState;
  StatusItem? preparedItem;

  MockViewerNotifier([this.initialState = const ViewerIdle()]);

  @override
  ViewerState build() => initialState;

  @override
  Future<void> prepare(StatusItem item) async {
    preparedItem = item;
  }

  void triggerState(ViewerState newState) {
    state = newState;
  }
}

class MockSaveNotifier extends SaveNotifier {
  final SaveState initialState;
  StatusItem? savedItem;

  MockSaveNotifier([this.initialState = const SaveIdle()]);

  @override
  SaveState build() => initialState;

  @override
  Future<void> save(StatusItem item) async {
    savedItem = item;
  }
}

void main() {
  final testItem = StatusItem(
    id: 'view_stat_1',
    displayName: 'my_moment.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 1024 * 2, // 2MB
    lastModified: DateTime.now().subtract(const Duration(minutes: 15)),
    isVideo: false,
    isSaved: false,
  );

  Widget buildTestable({
    required StatusItem item,
    VoidCallback? onDismiss,
    ValueChanged<StatusItem>? onShare,
    MockViewerNotifier? mockViewerNotifier,
    MockSaveNotifier? mockSaveNotifier,
    StatusRepository? mockStatusRepository,
  }) {
    return ProviderScope(
      overrides: [
        if (mockViewerNotifier != null)
          viewerNotifierProvider.overrideWith(() => mockViewerNotifier),
        if (mockSaveNotifier != null)
          saveNotifierProvider.overrideWith(() => mockSaveNotifier),
        if (mockStatusRepository != null)
          statusRepositoryProvider.overrideWithValue(mockStatusRepository),
      ],
      child: MaterialApp(
        theme: KeevaTheme.darkTheme,
        home: MediaViewerScreen(
          item: item,
          onDismiss: onDismiss,
          onShare: onShare,
        ),
      ),
    );
  }

  group('Phase 2E-B7: MediaViewerScreen', () {
    testWidgets(
      'renders media canvas, top chrome, and bottom floating pill bar',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1000);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final viewerMock = MockViewerNotifier();
        final saveMock = MockSaveNotifier();

        await tester.pumpWidget(
          buildTestable(
            item: testItem,
            mockViewerNotifier: viewerMock,
            mockSaveNotifier: saveMock,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('15m ago'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Keep'), findsOneWidget);
        expect(find.byType(KeepButton), findsOneWidget);
        expect(viewerMock.preparedItem?.id, equals(testItem.id));
      },
    );

    testWidgets('single tap toggles chrome controls', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(
          item: testItem,
          mockViewerNotifier: MockViewerNotifier(),
          mockSaveNotifier: MockSaveNotifier(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially top chrome is visible
      final initialTopFinder = find.byType(AnimatedPositioned).first;
      expect(initialTopFinder, findsOneWidget);

      // Tap canvas to toggle off
      await tester.tap(find.byType(AspectRatio).first);
      await tester.pumpAndSettle();

      // Tap canvas again to toggle on
      await tester.tap(find.byType(AspectRatio).first);
      await tester.pumpAndSettle();
      expect(find.text('15m ago'), findsOneWidget);
    });

    testWidgets('tapping Info opens media details bottom sheet', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(
          item: testItem,
          mockViewerNotifier: MockViewerNotifier(),
          mockSaveNotifier: MockSaveNotifier(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Info icon
      await tester.tap(find.byIcon(AppIcons.actionInfo).first);
      await tester.pumpAndSettle();

      expect(find.text('Media Information'), findsOneWidget);
      expect(find.text('my_moment.jpg'), findsOneWidget);
      expect(find.text('Photo (JPEG)'), findsOneWidget);
      expect(find.text('2.00 MB'), findsOneWidget);
    });

    testWidgets('tapping Keep button saves item', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final saveMock = MockSaveNotifier();

      await tester.pumpWidget(
        buildTestable(
          item: testItem,
          mockViewerNotifier: MockViewerNotifier(),
          mockSaveNotifier: saveMock,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(KeepButton));
      await tester.pump();

      expect(saveMock.savedItem?.id, equals(testItem.id));
    });

    testWidgets('vertical drag beyond 120dp triggers onDismiss', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var dismissed = false;

      await tester.pumpWidget(
        buildTestable(
          item: testItem,
          onDismiss: () => dismissed = true,
          mockViewerNotifier: MockViewerNotifier(),
          mockSaveNotifier: MockSaveNotifier(),
        ),
      );
      await tester.pumpAndSettle();

      // Drag down by 150dp
      await tester.drag(find.byType(AspectRatio).first, const Offset(0, 150));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('renders ErrorState when ViewerFailure is emitted', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final viewerMock = MockViewerNotifier(
        const ViewerFailure(
          itemId: 'view_stat_1',
          failure: VideoPrepareFailedFailure('Video stream corrupted'),
        ),
      );

      await tester.pumpWidget(
        buildTestable(
          item: testItem,
          mockViewerNotifier: viewerMock,
          mockSaveNotifier: MockSaveNotifier(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Video stream corrupted'), findsOneWidget);
    });

    testWidgets('tapping Share displays error toast if shareStatus fails', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeRepo = FakeStatusRepository(
        shareResult: const Failure(
          UnknownFailure('Failed to open system share sheet'),
        ),
      );

      await tester.pumpWidget(
        buildTestable(
          item: testItem,
          mockViewerNotifier: MockViewerNotifier(),
          mockSaveNotifier: MockSaveNotifier(),
          mockStatusRepository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(AppIcons.actionShare).first);
      await tester.pumpAndSettle();

      expect(find.text('Failed to open system share sheet'), findsOneWidget);
    });
  });
}
