import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/saver/save_notifier.dart';
import 'package:whatsapp_status_saver/application/saver/save_state.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_notifier.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/domain/entities/saved_media.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/keep_button.dart';
import 'package:whatsapp_status_saver/presentation/common/feedback/empty_state.dart';
import 'package:whatsapp_status_saver/presentation/common/feedback/error_state.dart';
import 'package:whatsapp_status_saver/presentation/common/media/video_badge.dart';
import 'package:whatsapp_status_saver/presentation/moments/moments_screen.dart';
import 'package:whatsapp_status_saver/presentation/moments/status_card.dart';
import 'package:whatsapp_status_saver/presentation/moments/status_grid.dart';

class MockStatusListNotifier extends StatusListNotifier {
  final StatusListState initialState;
  bool refreshCalled = false;

  MockStatusListNotifier([this.initialState = const StatusListInitial()]);

  @override
  StatusListState build() => initialState;

  @override
  Future<void> refresh({String targetPackage = ''}) async {
    refreshCalled = true;
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

  void triggerState(SaveState newState) {
    state = newState;
  }
}

void main() {
  final testImageItem = StatusItem(
    id: 'status_img_1',
    displayName: 'image_1.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 500,
    lastModified: DateTime.now().subtract(const Duration(minutes: 15)),
    isVideo: false,
    isSaved: false,
  );

  final testVideoItem = StatusItem(
    id: 'status_vid_1',
    displayName: 'video_1.mp4',
    mimeType: 'video/mp4',
    sizeBytes: 1024 * 1024 * 5,
    lastModified: DateTime.now().subtract(const Duration(hours: 2)),
    isVideo: true,
    isSaved: true,
  );

  Widget buildTestable(
    Widget child, {
    MockStatusListNotifier? mockStatusListNotifier,
    MockSaveNotifier? mockSaveNotifier,
  }) {
    return ProviderScope(
      overrides: [
        if (mockStatusListNotifier != null)
          statusListNotifierProvider.overrideWith(() => mockStatusListNotifier),
        if (mockSaveNotifier != null)
          saveNotifierProvider.overrideWith(() => mockSaveNotifier),
      ],
      child: MaterialApp(theme: KeevaTheme.darkTheme, home: child),
    );
  }

  setUp(() {
    // Tests set dimensions per test when needed
  });

  group('Phase 2E-B5: Moments & Status Grid', () {
    // =========================================================================
    // STATUS CARD
    // =========================================================================
    group('StatusCard', () {
      testWidgets('renders photo status without video badge', (tester) async {
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: StatusCard(item: testImageItem),
                ),
              ),
            ),
          ),
        );

        expect(find.text('15m ago'), findsOneWidget);
        expect(find.byType(VideoBadge), findsNothing);
        expect(find.text('Kept'), findsNothing);
        expect(find.byType(KeepButton), findsOneWidget);
      });

      testWidgets('renders video status with VideoBadge and Kept badge', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: StatusCard(
                    item: testVideoItem,
                    keepState: KeepState.alreadyKept,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(VideoBadge), findsOneWidget);
        expect(find.text('Kept'), findsOneWidget);
        expect(find.text('2h ago'), findsOneWidget);
      });

      testWidgets('tapping card invokes onTap callback', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: StatusCard(
                    item: testImageItem,
                    onTap: () => tapped = true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(StatusCard));
        await tester.pump();
        expect(tapped, isTrue);
      });

      testWidgets('tapping KeepButton invokes onKeep callback', (tester) async {
        var kept = false;
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: StatusCard(
                    item: testImageItem,
                    onKeep: () => kept = true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(KeepButton));
        await tester.pump();
        expect(kept, isTrue);
      });
    });

    // =========================================================================
    // STATUS GRID
    // =========================================================================
    group('StatusGrid', () {
      testWidgets('renders loading shimmer grid when isLoading is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            const Scaffold(body: StatusGrid(items: [], isLoading: true)),
          ),
        );

        expect(find.byType(StatusCard), findsNothing);
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('renders EmptyState when items list is empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            const Scaffold(
              body: StatusGrid(
                items: [],
                isLoading: false,
                emptyScenario: EmptyScenario.noStatuses,
              ),
            ),
          ),
        );

        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.text('No moments right now'), findsOneWidget);
      });

      testWidgets('renders ErrorState when failure is provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              body: StatusGrid(
                items: const [],
                failure: const ReadFailedFailure('Failed to access storage'),
              ),
            ),
          ),
        );

        expect(find.byType(ErrorState), findsOneWidget);
        expect(find.text('Failed to access storage'), findsOneWidget);
      });

      testWidgets('renders populated grid with correct columns', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1000);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final items = [testImageItem, testVideoItem];
        await tester.pumpWidget(
          buildTestable(Scaffold(body: StatusGrid(items: items))),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StatusCard), findsNWidgets(2));
      });
    });

    // =========================================================================
    // MOMENTS SCREEN
    // =========================================================================
    group('MomentsScreen', () {
      testWidgets('filters items between All, Photos, and Videos', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1000);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final items = [testImageItem, testVideoItem];
        final listMock = MockStatusListNotifier(
          StatusListSuccess(items: items),
        );

        await tester.pumpWidget(
          buildTestable(
            const MomentsScreen(),
            mockStatusListNotifier: listMock,
            mockSaveNotifier: MockSaveNotifier(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('2 moments available'), findsOneWidget);
        expect(find.text('All (2)'), findsOneWidget);
        expect(find.text('Photos (1)'), findsOneWidget);
        expect(find.text('Videos (1)'), findsOneWidget);
        expect(find.byType(StatusCard), findsNWidgets(2));

        // Filter to Photos only
        await tester.tap(find.text('Photos (1)'));
        await tester.pumpAndSettle();
        expect(find.byType(StatusCard), findsOneWidget);
        expect(find.text('15m ago'), findsOneWidget);

        // Filter to Videos only
        await tester.tap(find.text('Videos (1)'));
        await tester.pumpAndSettle();
        expect(find.byType(StatusCard), findsOneWidget);
        expect(find.text('2h ago'), findsOneWidget);
      });

      testWidgets(
        'tapping KeepButton saves item and triggers toast on success',
        (tester) async {
          tester.view.devicePixelRatio = 1.0;
          tester.view.physicalSize = const Size(800, 1000);
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final items = [testImageItem];
          final listMock = MockStatusListNotifier(
            StatusListSuccess(items: items),
          );
          final saveMock = MockSaveNotifier();

          await tester.pumpWidget(
            buildTestable(
              const MomentsScreen(),
              mockStatusListNotifier: listMock,
              mockSaveNotifier: saveMock,
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byType(KeepButton));
          await tester.pump();
          expect(saveMock.savedItem?.id, equals(testImageItem.id));

          // Trigger save success state
          saveMock.triggerState(
            SaveSuccess(
              itemId: testImageItem.id,
              savedMedia: SavedMedia(
                id: 'saved_1',
                originalFileName: testImageItem.displayName,
                savedUriOrPath: '/storage/emulated/0/DCIM/Keeva/img.jpg',
                mediaType: MediaType.image,
                mimeType: testImageItem.mimeType,
                sizeBytes: testImageItem.sizeBytes,
                savedAt: DateTime.now(),
              ),
            ),
          );
          await tester.pump();

          expect(find.text('Saved to gallery'), findsOneWidget);
        },
      );
    });
  });
}
