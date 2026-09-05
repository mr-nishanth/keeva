import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:whatsapp_status_saver/app/app.dart';
import 'package:whatsapp_status_saver/application/access/access_notifier.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_notifier.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/moments/status_card.dart';
import 'package:whatsapp_status_saver/presentation/viewer/media_viewer_screen.dart';

class TestAccessNotifier extends AccessNotifier {
  final AccessState initial;
  TestAccessNotifier([this.initial = const AccessGranted()]);

  @override
  AccessState build() => initial;

  @override
  Future<void> checkAccess({String targetPackage = 'com.whatsapp'}) async {}
}

class TestStatusListNotifier extends StatusListNotifier {
  final StatusListState initial;
  TestStatusListNotifier(this.initial);

  @override
  StatusListState build() => initial;

  @override
  Future<void> load({String targetPackage = 'com.whatsapp'}) async {}

  @override
  Future<void> refresh({String targetPackage = 'com.whatsapp'}) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final sampleItem = StatusItem(
    id: 'int_photo_viewer_1',
    displayName: 'golden_hour.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 768,
    lastModified: DateTime.now().subtract(const Duration(minutes: 25)),
    isVideo: false,
    isSaved: false,
  );

  group('Keeva End-to-End Media Viewer Integration Test', () {
    testWidgets(
      'Open viewer from moments, toggle chrome, view info sheet, and navigate back',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              accessNotifierProvider.overrideWith(
                () => TestAccessNotifier(const AccessGranted()),
              ),
              statusListNotifierProvider.overrideWith(
                () => TestStatusListNotifier(
                  StatusListSuccess(items: [sampleItem]),
                ),
              ),
            ],
            child: const KeevaApp(),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify card appears in moments
        expect(find.byType(StatusCard), findsOneWidget);

        // 2. Tap status card to open Viewer
        await tester.tap(find.byType(StatusCard));
        await tester.pumpAndSettle();

        // Viewer should now be open
        expect(find.byType(MediaViewerScreen), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);

        // 3. Toggle Chrome on Single Tap
        final initialBackDy = tester.getTopLeft(find.byTooltip('Back')).dy;
        expect(initialBackDy, greaterThanOrEqualTo(0));

        // Tap center of screen to hide chrome
        await tester.tapAt(const Offset(200, 300));
        await tester.pumpAndSettle();

        final hiddenBackDy = tester.getTopLeft(find.byTooltip('Back')).dy;
        expect(hiddenBackDy, lessThan(0));

        // Tap again to restore chrome
        await tester.tapAt(const Offset(200, 300));
        await tester.pumpAndSettle();

        final restoredBackDy = tester.getTopLeft(find.byTooltip('Back')).dy;
        expect(restoredBackDy, greaterThanOrEqualTo(0));

        // 4. Open Info / Details Bottom Sheet
        final infoButton = find.byTooltip('Details');
        expect(infoButton, findsOneWidget);
        await tester.tap(infoButton);
        await tester.pumpAndSettle();

        expect(find.text('Media Information'), findsOneWidget);
        expect(find.text('golden_hour.jpg'), findsWidgets);

        // Close details sheet by tapping outside modal
        await tester.tapAt(const Offset(20, 50));
        await tester.pumpAndSettle();
        expect(find.text('Media Information'), findsNothing);

        // 5. Navigate back via Back Button
        final backButton = find.byTooltip('Back');
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Viewer closed, back in Moments
        expect(find.byType(MediaViewerScreen), findsNothing);
        expect(find.byType(StatusCard), findsOneWidget);
      },
    );
  });
}
