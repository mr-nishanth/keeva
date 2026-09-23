import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/app.dart';
import 'package:whatsapp_status_saver/application/access/access_notifier.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_notifier.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/data/repositories/auth_repository_impl.dart';
import 'package:whatsapp_status_saver/presentation/auth/login_screen.dart';
import 'package:whatsapp_status_saver/presentation/moments/moments_screen.dart';
import 'package:whatsapp_status_saver/presentation/onboarding/permission_onboarding_screen.dart';

import '../support/fake_session_store.dart';

class _QuietAccessNotifier extends AccessNotifier {
  final AccessState initialState;

  _QuietAccessNotifier(this.initialState);

  @override
  AccessState build() => initialState;

  @override
  Future<void> checkAccess({String targetPackage = ''}) async {}
}

class _QuietStatusListNotifier extends StatusListNotifier {
  final StatusListState initialState;

  _QuietStatusListNotifier(this.initialState);

  @override
  StatusListState build() => initialState;

  @override
  Future<void> load({String targetPackage = ''}) async {}
}

void main() {
  late FakeSessionStore store;

  setUp(() {
    store = FakeSessionStore();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    AccessState accessState = const AccessNotGranted(),
    StatusListState statusState = const StatusListInitial(),
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => store),
          accessNotifierProvider.overrideWith(
            () => _QuietAccessNotifier(accessState),
          ),
          statusListNotifierProvider.overrideWith(
            () => _QuietStatusListNotifier(statusState),
          ),
        ],
        child: const KeevaApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  group('Login gate', () {
    testWidgets('cold start without a session shows the login screen', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sign in to Keeva'), findsOneWidget);
      expect(find.byKey(const Key('login_username')), findsOneWidget);
      expect(find.byKey(const Key('login_password')), findsOneWidget);
      expect(find.byType(PermissionOnboardingScreen), findsNothing);
      expect(find.byType(MomentsScreen), findsNothing);
    });

    testWidgets('incorrect credentials stay on the login screen', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.enterText(
        find.byKey(const Key('login_username')),
        'nishanth',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'wrong-password',
      );
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.text('That username or password is incorrect.'),
        findsOneWidget,
      );
      expect(find.byType(PermissionOnboardingScreen), findsNothing);
      expect(find.byType(MomentsScreen), findsNothing);
      expect(store.values, isEmpty);
    });

    testWidgets('empty credentials explain what to enter', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pump();
      await tester.pump();

      expect(find.text('Enter your username and password.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('correct credentials open onboarding when access is missing', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.enterText(
        find.byKey(const Key('login_username')),
        'nishanth',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'mr-nishanth',
      );
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(PermissionOnboardingScreen), findsOneWidget);
      expect(find.text('Welcome to Keeva'), findsOneWidget);
      expect(store.values, contains(AuthRepositoryImpl.sessionTokenKey));
      expect(store.values, contains(AuthRepositoryImpl.credentialsVersionKey));
    });

    testWidgets('a saved session skips login on the next launch', (
      tester,
    ) async {
      final repository = AuthRepositoryImpl(store);
      final signedIn = await repository.signIn(
        username: 'nishanth',
        password: 'mr-nishanth',
      );
      expect(signedIn.isSuccess, isTrue);

      await pumpApp(
        tester,
        accessState: const AccessGranted(),
        statusState: StatusListSuccess(items: const []),
      );

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(MomentsScreen), findsOneWidget);
      expect(find.text('Sign in to Keeva'), findsNothing);
    });
  });
}
