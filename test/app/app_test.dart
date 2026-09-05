import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/app.dart';
import 'package:whatsapp_status_saver/application/access/access_notifier.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_notifier.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/kept/kept_vault_screen.dart';
import 'package:whatsapp_status_saver/presentation/moments/moments_screen.dart';
import 'package:whatsapp_status_saver/presentation/moments/status_card.dart';
import 'package:whatsapp_status_saver/presentation/onboarding/permission_onboarding_screen.dart';
import 'package:whatsapp_status_saver/presentation/settings/settings_screen.dart';
import 'package:whatsapp_status_saver/presentation/viewer/media_viewer_screen.dart';

class MockAccessNotifier extends AccessNotifier {
  final AccessState initialState;

  MockAccessNotifier([this.initialState = const AccessInitial()]);

  @override
  AccessState build() => initialState;

  @override
  Future<void> checkAccess({String targetPackage = ''}) async {}
}

class MockStatusListNotifier extends StatusListNotifier {
  final StatusListState initialState;

  MockStatusListNotifier([this.initialState = const StatusListInitial()]);

  @override
  StatusListState build() => initialState;

  @override
  Future<void> load({String targetPackage = ''}) async {}
}

void main() {
  final testItem = StatusItem(
    id: 'app_test_stat',
    displayName: 'test_moment.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 300,
    lastModified: DateTime.now(),
    isVideo: false,
    isSaved: true,
  );

  Widget buildTestable({
    required AccessState accessState,
    List<StatusItem> items = const [],
  }) {
    return ProviderScope(
      overrides: [
        accessNotifierProvider.overrideWith(
          () => MockAccessNotifier(accessState),
        ),
        statusListNotifierProvider.overrideWith(
          () => MockStatusListNotifier(StatusListSuccess(items: items)),
        ),
      ],
      child: const KeevaApp(),
    );
  }

  group('Phase 2E-B8: KeevaApp Top-Level Integration', () {
    testWidgets(
      'renders PermissionOnboardingScreen when access is not granted',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1000);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestable(accessState: const AccessNotGranted()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PermissionOnboardingScreen), findsOneWidget);
        expect(find.text('Welcome to Keeva'), findsOneWidget);
        expect(find.byType(MomentsScreen), findsNothing);
      },
    );

    testWidgets('renders MomentsScreen in AppShell when access is granted', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(accessState: const AccessGranted(), items: [testItem]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MomentsScreen), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(StatusCard), findsOneWidget);
    });

    testWidgets('bottom navigation switches to Kept Vault and Settings', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 800); // phone
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(accessState: const AccessGranted(), items: [testItem]),
      );
      await tester.pumpAndSettle();

      // Switch to Kept tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Kept'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(KeptVaultScreen), findsOneWidget);
      expect(find.text('1 moments safely kept'), findsOneWidget);

      // Switch to Settings tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Storage & Access'), findsOneWidget);
    });

    testWidgets('tapping status card in Moments opens MediaViewerScreen', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(accessState: const AccessGranted(), items: [testItem]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(StatusCard));
      await tester.pumpAndSettle();

      expect(find.byType(MediaViewerScreen), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Kept ✓'), findsOneWidget);
    });
  });
}
