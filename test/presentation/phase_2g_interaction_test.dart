import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/domain/entities/status_item.dart';
import 'package:whatsapp_status_saver/presentation/common/buttons/keep_button.dart';
import 'package:whatsapp_status_saver/presentation/common/sheets/bottom_sheet.dart';
import 'package:whatsapp_status_saver/presentation/viewer/media_viewer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleItem = StatusItem(
    id: 'status_g1',
    displayName: 'sample_photo.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1024 * 512,
    lastModified: DateTime.now().subtract(const Duration(minutes: 15)),
    isVideo: false,
    isSaved: true,
  );

  group('Phase 2G: KeepButton Already-Kept Interaction', () {
    testWidgets(
      'KeepButton fires onAlreadyKeptPressed and performs shake micro-interaction',
      (tester) async {
        bool alreadyKeptPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: KeepButton(
                  state: KeepState.alreadyKept,
                  onPressed: () {},
                  onAlreadyKeptPressed: () {
                    alreadyKeptPressed = true;
                  },
                ),
              ),
            ),
          ),
        );

        // Tap the already kept button
        await tester.tap(find.byType(KeepButton));
        // Advance animation
        await tester.pump(const Duration(milliseconds: 50));

        expect(alreadyKeptPressed, isTrue);

        // Verify shake offset has occurred
        final transformFinder = find.descendant(
          of: find.byType(KeepButton),
          matching: find.byType(Transform),
        );
        expect(transformFinder, findsOneWidget);

        // Settle animation (180ms total)
        await tester.pumpAndSettle();
      },
    );
  });

  group('Phase 2G: Already Kept Options Modal', () {
    testWidgets(
      'showAlreadyKeptOptions renders View in Kept Vault and Save Copy and executes callbacks',
      (tester) async {
        bool viewedInVault = false;
        bool savedCopy = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: KeevaTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      KeevaBottomSheet.showAlreadyKeptOptions(
                        context: context,
                        item: sampleItem,
                        onViewInVault: () {
                          viewedInVault = true;
                        },
                        onSaveCopy: () {
                          savedCopy = true;
                        },
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        );

        // Open bottom sheet
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Already Kept'), findsOneWidget);
        expect(find.text('View in Kept Vault'), findsOneWidget);
        expect(find.text('Save Copy'), findsOneWidget);

        // Tap View in Kept Vault
        await tester.tap(find.text('View in Kept Vault'));
        await tester.pumpAndSettle();

        expect(viewedInVault, isTrue);
        expect(find.text('Already Kept'), findsNothing);

        // Open modal again for Save Copy
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Copy'));
        await tester.pumpAndSettle();

        expect(savedCopy, isTrue);
      },
    );
  });

  group('Phase 2G: MediaViewerScreen Share & Already-Kept Action', () {
    testWidgets(
      'MediaViewerScreen triggers onShare callback when Share button is tapped',
      (tester) async {
        StatusItem? sharedItem;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: KeevaTheme.darkTheme,
              home: MediaViewerScreen(
                item: sampleItem,
                onShare: (item) async {
                  sharedItem = item;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Share button should be present in bottom bar
        final shareFinder = find.widgetWithText(TextButton, 'Share');
        expect(shareFinder, findsOneWidget);

        await tester.tap(shareFinder);
        await tester.pumpAndSettle();

        expect(sharedItem, isNotNull);
        expect(sharedItem?.id, equals('status_g1'));
      },
    );

    testWidgets(
      'MediaViewerScreen shows already kept modal and triggers onNavigateToKept',
      (tester) async {
        bool navigatedToKept = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: KeevaTheme.darkTheme,
              home: MediaViewerScreen(
                item: sampleItem, // isSaved = true
                onNavigateToKept: () {
                  navigatedToKept = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the Keep/Kept pill in the viewer
        final keepButtonFinder = find.byType(KeepButton);
        expect(keepButtonFinder, findsOneWidget);

        await tester.tap(keepButtonFinder);
        await tester.pumpAndSettle();

        // Bottom sheet appears
        expect(find.text('Already Kept'), findsOneWidget);
        expect(find.text('View in Kept Vault'), findsOneWidget);

        // Tap View in Kept Vault
        await tester.tap(find.text('View in Kept Vault'));
        await tester.pumpAndSettle();

        expect(navigatedToKept, isTrue);
      },
    );
  });
}
