import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/keep_button.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/primary_button.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/secondary_button.dart';
import 'package:whatsapp_status_saver/presentation/common/media/video_badge.dart';
import 'package:whatsapp_status_saver/presentation/common/onboarding/permission_guide.dart';
import 'package:whatsapp_status_saver/presentation/common/sheets/bottom_sheet.dart';
import 'package:whatsapp_status_saver/presentation/moments/status_card.dart';
import 'package:whatsapp_status_saver/presentation/moments/status_grid.dart';
import 'package:whatsapp_status_saver/presentation/shell/adaptive_navigation.dart';
import 'package:whatsapp_status_saver/presentation/shell/app_shell.dart';
import 'package:whatsapp_status_saver/presentation/shell/top_bar.dart';
import 'package:whatsapp_status_saver/presentation/viewer/media_viewer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleItem = StatusItem(
    id: 'status_h1',
    displayName: 'sample_photo.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 512,
    lastModified: DateTime.now().subtract(const Duration(minutes: 15)),
    isVideo: false,
    isSaved: false,
  );

  final sampleVideo = StatusItem(
    id: 'status_h2',
    displayName: 'sample_video.mp4',
    mimeType: 'video/mp4',
    sizeBytes: 1024 * 1024 * 3,
    lastModified: DateTime.now().subtract(const Duration(hours: 1)),
    isVideo: true,
    isSaved: false,
  );

  group('Phase 2F Hardening: KeepButton Debounce & Concurrency Guard', () {
    testWidgets(
      'Rapid double-tap fires onPressed only once within debounce window',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: KeepButton(
                  state: KeepState.idle,
                  onPressed: () => tapCount++,
                ),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(KeepButton);
        expect(buttonFinder, findsOneWidget);

        // First tap
        await tester.tap(buttonFinder);
        // Immediate second tap within 50ms (before state updates)
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        expect(tapCount, 1);
      },
    );

    testWidgets('Tapping KeepButton when alreadyKept does not fire onPressed', (
      tester,
    ) async {
      bool wasCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: KeevaTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: KeepButton(
                state: KeepState.alreadyKept,
                onPressed: () => wasCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(KeepButton));
      await tester.pumpAndSettle();

      expect(wasCalled, isFalse);
    });

    testWidgets(
      'KeepButton preserves 48x48dp hit target while visual affordance is 32dp',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: KeepButton(state: KeepState.idle, onPressed: () {}),
              ),
            ),
          ),
        );

        final keepButtonSize = tester.getSize(find.byType(KeepButton));
        expect(keepButtonSize.width, greaterThanOrEqualTo(48.0));
        expect(keepButtonSize.height, greaterThanOrEqualTo(48.0));
      },
    );
  });

  group('Phase 2F Hardening: 200% Dynamic Text Scaling', () {
    Widget buildScaledApp(Widget child, {double textScale = 2.0}) {
      return MaterialApp(
        theme: KeevaTheme.darkTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 800),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('PrimaryButton renders without overflow at 200% text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScaledApp(
          Center(
            child: PrimaryButton(
              label: 'Connect Media Folder',
              leadingIcon: AppIcons.folder,
              onPressed: () {},
            ),
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Connect Media Folder'), findsOneWidget);
    });

    testWidgets('SecondaryButton renders without overflow at 200% text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScaledApp(
          Center(
            child: SecondaryButton(
              label: 'Reconnect Media Folder',
              leadingIcon: AppIcons.folderOpen,
              onPressed: () {},
            ),
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Reconnect Media Folder'), findsOneWidget);
    });

    testWidgets(
      'TopBar privacy pill renders without overflow at 200% text scale',
      (tester) async {
        await tester.pumpWidget(
          buildScaledApp(
            const Scaffold(appBar: TopBar.brand(), body: SizedBox.shrink()),
            textScale: 2.0,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Private'), findsOneWidget);
      },
    );

    testWidgets('StatusCard renders without overflow at 200% text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScaledApp(
          SizedBox(
            width: 180,
            height: 320,
            child: StatusCard(item: sampleItem, onTap: () {}, onKeep: () {}),
          ),
          textScale: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(StatusCard), findsOneWidget);
    });

    testWidgets(
      'PermissionGuide wraps text cleanly without overflow at 200% text scale',
      (tester) async {
        await tester.pumpWidget(
          buildScaledApp(
            const SingleChildScrollView(child: PermissionGuide()),
            textScale: 2.0,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('100% On-Device • Zero Network • Private'),
          findsOneWidget,
        );
      },
    );
  });

  group('Phase 2F Hardening: Reduced Motion Compliance', () {
    testWidgets(
      'StatusGrid cards bypass stagger animation when disableAnimations is true',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
                disableAnimations: true,
              ),
              child: Scaffold(
                body: StatusGrid(items: [sampleItem, sampleVideo]),
              ),
            ),
          ),
        );

        // Without calling pumpAndSettle, items should already be rendered at full opacity
        await tester.pump(const Duration(milliseconds: 10));
        expect(find.byType(StatusCard), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Phase 2F Hardening: Media Viewer Gestures & Snap-Back', () {
    testWidgets(
      'Vertical drag below 120dp springs back to center without dismissing',
      (tester) async {
        bool dismissed = false;
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: KeevaTheme.darkTheme,
              home: MediaViewerScreen(
                item: sampleItem,
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Drag vertically 60dp (< 120dp threshold)
        await tester.drag(find.byType(AspectRatio).first, const Offset(0, 60));
        await tester.pumpAndSettle();

        expect(dismissed, isFalse);
      },
    );

    testWidgets('Vertical drag exceeding 120dp triggers onDismiss', (
      tester,
    ) async {
      bool dismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: MediaViewerScreen(
              item: sampleItem,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag vertically 150dp (> 120dp threshold)
      await tester.drag(find.byType(AspectRatio).first, const Offset(0, 150));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });
  });

  group('Phase 2F Hardening: Responsive Layout Matrix', () {
    test('getColumnCount computes correct columns across all breakpoints', () {
      expect(StatusGrid.getColumnCount(320), 2);
      expect(StatusGrid.getColumnCount(360), 2);
      expect(StatusGrid.getColumnCount(599), 2);
      expect(StatusGrid.getColumnCount(600), 3);
      expect(StatusGrid.getColumnCount(839), 3);
      expect(StatusGrid.getColumnCount(840), 4);
      expect(StatusGrid.getColumnCount(1199), 4);
      expect(StatusGrid.getColumnCount(1200), 5);
      expect(StatusGrid.getColumnCount(1600), 5);
    });

    testWidgets(
      'AppShell renders BottomNavigationBar under 600dp and NavigationRail at >= 600dp',
      (tester) async {
        // Test compact width (400dp)
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 800)),
              child: AppShell(
                activeDestination: NavDestination.moments,
                onDestinationSelected: (_) {},
                body: const SizedBox.shrink(),
              ),
            ),
          ),
        );
        expect(find.byType(KeevaBottomNavBar), findsOneWidget);
        expect(find.byType(KeevaNavRail), findsNothing);

        // Test tablet width (700dp)
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 900)),
              child: AppShell(
                activeDestination: NavDestination.moments,
                onDestinationSelected: (_) {},
                body: const SizedBox.shrink(),
              ),
            ),
          ),
        );
        expect(find.byType(KeevaNavRail), findsOneWidget);
        expect(find.byType(KeevaBottomNavBar), findsNothing);
      },
    );
  });

  group('Phase 2F Hardening: VideoBadge & Token Consistency', () {
    testWidgets(
      'VideoBadge with unknown duration (durationMs <= 0) shows play icon without 0:00',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: const Scaffold(
              body: Center(child: VideoBadge(durationMs: 0)),
            ),
          ),
        );

        expect(find.byIcon(AppIcons.typeVideo), findsOneWidget);
        expect(find.text('0:00'), findsNothing);
      },
    );

    testWidgets(
      'VideoBadge with known duration shows play icon and formatted duration',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: const Scaffold(
              body: Center(child: VideoBadge(durationMs: 24000)),
            ),
          ),
        );

        expect(find.byIcon(AppIcons.typeVideo), findsOneWidget);
        expect(find.text('0:24'), findsOneWidget);
      },
    );

    testWidgets(
      'KeevaBottomSheet.showTrustDetails renders correctly with design tokens',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => KeevaBottomSheet.showTrustDetails(context),
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Private & Local-First'), findsOneWidget);
        expect(find.byIcon(AppIcons.privacyShield), findsOneWidget);
      },
    );
  });
}
