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
import 'package:whatsapp_status_saver/presentation/moments/moments_screen.dart';

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

  final samplePhoto = StatusItem(
    id: 'int_photo_1',
    displayName: 'sunset.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 300,
    lastModified: DateTime.now().subtract(const Duration(minutes: 10)),
    isVideo: false,
    isSaved: false,
  );

  final sampleVideo = StatusItem(
    id: 'int_video_1',
    displayName: 'nature.mp4',
    mimeType: 'video/mp4',
    sizeBytes: 1024 * 1024 * 2,
    lastModified: DateTime.now().subtract(const Duration(hours: 1)),
    isVideo: true,
    isSaved: false,
  );

  group('Keeva End-to-End Navigation Integration Test', () {
    testWidgets('App launch, tab navigation, and filter switching', (
      tester,
    ) async {
      final items = [samplePhoto, sampleVideo];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessNotifierProvider.overrideWith(
              () => TestAccessNotifier(const AccessGranted()),
            ),
            statusListNotifierProvider.overrideWith(
              () => TestStatusListNotifier(StatusListSuccess(items: items)),
            ),
          ],
          child: const KeevaApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. App Launches on Moments tab
      expect(find.byType(MomentsScreen), findsOneWidget);
      expect(find.text('Keeva'), findsOneWidget);
      expect(find.text('2 moments available'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // 2. Filter tabs test
      final photosFilter = find.textContaining('Photos');
      expect(photosFilter, findsOneWidget);
      await tester.tap(photosFilter);
      await tester.pumpAndSettle();

      final videosFilter = find.textContaining('Videos');
      expect(videosFilter, findsOneWidget);
      await tester.tap(videosFilter);
      await tester.pumpAndSettle();

      final allFilter = find.textContaining('All');
      await tester.tap(allFilter);
      await tester.pumpAndSettle();

      // 3. Navigation to Kept Vault
      final keptTab = find.text('Kept');
      expect(keptTab, findsOneWidget);
      await tester.tap(keptTab);
      await tester.pumpAndSettle();

      expect(find.text('Kept Vault'), findsOneWidget);

      // 4. Navigation to Settings
      final settingsTab = find.text('Settings');
      expect(settingsTab, findsOneWidget);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      expect(find.text('Private & Local-First'), findsOneWidget);

      // 5. Open Privacy Sheet from Settings
      await tester.tap(find.text('Private & Local-First'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Keeva operates 100% locally on your device. It requires zero internet permissions, connects strictly to your selected WhatsApp folder via Android Storage Access Framework, and never uploads or logs your media.',
        ),
        findsOneWidget,
      );

      // Dismiss Privacy Sheet by tapping outside modal
      await tester.tapAt(const Offset(20, 50));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Keeva operates 100% locally on your device. It requires zero internet permissions, connects strictly to your selected WhatsApp folder via Android Storage Access Framework, and never uploads or logs your media.',
        ),
        findsNothing,
      );

      // 6. Rapid Navigation Stress Test: Switch between tabs repeatedly
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Moments'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Kept'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Ensure stable state on Settings after rapid switches
      expect(find.text('Settings'), findsWidgets);

      // Return to Moments
      await tester.tap(find.text('Moments'));
      await tester.pumpAndSettle();
      expect(find.byType(MomentsScreen), findsOneWidget);
    });
  });
}
