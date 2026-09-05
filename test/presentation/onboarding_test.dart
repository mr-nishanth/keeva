import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/application/access/access_notifier.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/presentation/onboarding/permission_onboarding_screen.dart';

class MockAccessNotifier extends AccessNotifier {
  final AccessState initialState;
  bool requested = false;

  MockAccessNotifier([this.initialState = const AccessInitial()]);

  @override
  AccessState build() => initialState;

  @override
  Future<void> requestAccess({String targetPackage = ''}) async {
    requested = true;
  }

  void setState(AccessState newState) {
    state = newState;
  }
}

void main() {
  Widget buildTestable({
    required MockAccessNotifier mockNotifier,
    VoidCallback? onAccessGranted,
  }) {
    return ProviderScope(
      overrides: [accessNotifierProvider.overrideWith(() => mockNotifier)],
      child: MaterialApp(
        theme: KeevaTheme.darkTheme,
        home: PermissionOnboardingScreen(onAccessGranted: onAccessGranted),
      ),
    );
  }

  group('Phase 2E-B4: PermissionOnboardingScreen', () {
    testWidgets(
      'renders guide, copy, and active Connect button in initial state',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1200);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mock = MockAccessNotifier(const AccessInitial());

        await tester.pumpWidget(buildTestable(mockNotifier: mock));

        expect(find.text('Welcome to Keeva'), findsOneWidget);
        expect(
          find.text('Your private place for the moments you want to keep.'),
          findsOneWidget,
        );
        expect(find.text('1. View statuses in WhatsApp'), findsOneWidget);
        expect(find.text('2. Tap Connect Folder below'), findsOneWidget);
        expect(find.text('3. Tap "Use this folder"'), findsOneWidget);
        expect(find.text('Connect Media Folder'), findsOneWidget);
        expect(find.text('Learn how Keeva protects you'), findsOneWidget);

        // Tapping Connect triggers requestAccess()
        await tester.tap(find.text('Connect Media Folder'));
        await tester.pump();
        expect(mock.requested, isTrue);
      },
    );

    testWidgets('displays loading state on CTA during AccessRequesting', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mock = MockAccessNotifier(const AccessRequesting());

      await tester.pumpWidget(buildTestable(mockNotifier: mock));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Button should be disabled during loading
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(mock.requested, isFalse);
    });

    testWidgets('displays warning banner on AccessInvalid state', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mock = MockAccessNotifier(
        const AccessInvalid(reason: 'Please select the WhatsApp media folder'),
      );

      await tester.pumpWidget(buildTestable(mockNotifier: mock));

      expect(
        find.text('Please select the WhatsApp media folder'),
        findsOneWidget,
      );
    });

    testWidgets('displays error banner on AccessFailure state', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mock = MockAccessNotifier(
        const AccessFailure(AccessNotGrantedFailure('SAF permission denied')),
      );

      await tester.pumpWidget(buildTestable(mockNotifier: mock));

      expect(find.text('SAF permission denied'), findsOneWidget);
    });

    testWidgets('triggers onAccessGranted callback when access is granted', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var grantedCalled = false;
      final mock = MockAccessNotifier(const AccessInitial());

      await tester.pumpWidget(
        buildTestable(
          mockNotifier: mock,
          onAccessGranted: () => grantedCalled = true,
        ),
      );

      expect(grantedCalled, isFalse);

      // State changes to granted
      mock.setState(const AccessGranted());
      await tester.pump();

      expect(grantedCalled, isTrue);
    });

    testWidgets('tapping Learn how Keeva protects you opens privacy sheet', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mock = MockAccessNotifier(const AccessInitial());

      await tester.pumpWidget(buildTestable(mockNotifier: mock));

      await tester.tap(find.text('Learn how Keeva protects you'));
      await tester.pumpAndSettle();

      expect(find.text('Private & Local-First'), findsOneWidget);
    });
  });
}
