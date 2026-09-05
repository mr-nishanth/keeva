import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/theme/app_icons.dart';
import 'package:whatsapp_status_saver/app/theme/app_theme.dart';
import 'package:whatsapp_status_saver/presentation/shell/adaptive_navigation.dart';
import 'package:whatsapp_status_saver/presentation/shell/app_shell.dart';
import 'package:whatsapp_status_saver/presentation/shell/top_bar.dart';

void main() {
  Widget buildTestable(Widget child, {Size size = const Size(390, 844)}) {
    return MaterialApp(
      theme: KeevaTheme.darkTheme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    );
  }

  group('Phase 2E-B3: AppShell & Navigation Components', () {
    // =========================================================================
    // TOP BAR
    // =========================================================================
    group('TopBar', () {
      testWidgets('TopBar.brand renders wordmark and Private trust pill', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestable(const Scaffold(appBar: TopBar.brand())),
        );

        expect(find.text('Keeva'), findsOneWidget);
        expect(find.text('Private'), findsOneWidget);
        expect(find.byIcon(AppIcons.lock), findsOneWidget);

        // Tapping Private opens bottom sheet
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();
        expect(find.text('Private & Local-First'), findsOneWidget);
      });

      testWidgets('TopBar.contextual renders back button and title', (
        tester,
      ) async {
        var backed = false;
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              appBar: TopBar.contextual(
                title: 'Photo Preview',
                onBack: () => backed = true,
              ),
            ),
          ),
        );

        expect(find.text('Photo Preview'), findsOneWidget);
        expect(find.byIcon(AppIcons.actionBack), findsOneWidget);

        await tester.tap(find.byIcon(AppIcons.actionBack));
        await tester.pump();
        expect(backed, isTrue);
      });

      testWidgets('TopBar.selection renders counter and clear action', (
        tester,
      ) async {
        var cleared = false;
        await tester.pumpWidget(
          buildTestable(
            Scaffold(
              appBar: TopBar.selection(
                selectedCount: 3,
                onClearSelection: () => cleared = true,
              ),
            ),
          ),
        );

        expect(find.text('3 selected'), findsOneWidget);
        expect(find.byIcon(AppIcons.actionClose), findsOneWidget);

        await tester.tap(find.byIcon(AppIcons.actionClose));
        await tester.pump();
        expect(cleared, isTrue);
      });
    });

    // =========================================================================
    // APP SHELL RESPONSIVE LAYOUT
    // =========================================================================
    group('AppShell Responsive Layout', () {
      testWidgets('renders BottomNavigationBar on phone widths (< 600dp)', (
        tester,
      ) async {
        NavDestination? selected;
        await tester.pumpWidget(
          buildTestable(
            AppShell(
              activeDestination: NavDestination.moments,
              onDestinationSelected: (dest) => selected = dest,
              body: const Text('Body Content'),
            ),
            size: const Size(400, 800), // phone
          ),
        );

        expect(find.byType(KeevaBottomNavBar), findsOneWidget);
        expect(find.byType(KeevaNavRail), findsNothing);
        expect(find.text('Body Content'), findsOneWidget);

        // Tap Kept tab
        await tester.tap(find.text('Kept'));
        await tester.pump();
        expect(selected, NavDestination.kept);
      });

      testWidgets('renders NavigationRail on tablet widths (>= 600dp)', (
        tester,
      ) async {
        NavDestination? selected;
        await tester.pumpWidget(
          buildTestable(
            AppShell(
              activeDestination: NavDestination.moments,
              onDestinationSelected: (dest) => selected = dest,
              body: const Text('Tablet Content'),
            ),
            size: const Size(700, 1000), // tablet
          ),
        );

        expect(find.byType(KeevaNavRail), findsOneWidget);
        expect(find.byType(KeevaBottomNavBar), findsNothing);
        expect(find.text('Tablet Content'), findsOneWidget);

        // Tap Settings
        await tester.tap(find.text('Settings'));
        await tester.pump();
        expect(selected, NavDestination.settings);
      });
    });
  });
}
