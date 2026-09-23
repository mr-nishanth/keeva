import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:whatsapp_status_saver/app/app.dart';
import 'package:whatsapp_status_saver/application/access/access_notifier.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/auth/auth_copy.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_notifier.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_capability.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_unlock_result.dart';
import 'package:whatsapp_status_saver/presentation/auth/login_screen.dart';
import 'package:whatsapp_status_saver/presentation/moments/moments_screen.dart';
import 'package:whatsapp_status_saver/presentation/settings/settings_screen.dart';

import '../test/support/fake_biometric.dart';
import '../test/support/fake_session_store.dart';

class _QuietAccessNotifier extends AccessNotifier {
  @override
  AccessState build() => const AccessGranted();

  @override
  Future<void> checkAccess({String targetPackage = ''}) async {}
}

class _QuietStatusListNotifier extends StatusListNotifier {
  @override
  StatusListState build() => StatusListSuccess(items: const []);

  @override
  Future<void> load({String targetPackage = ''}) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'password sign-in, biometric opt-in, relaunch, cancel, and sign-out',
    (tester) async {
      final store = FakeSessionStore();
      final biometrics = FakeBiometricAuthenticator()
        ..capabilityResult = const BiometricCapability(
          canAuthenticate: true,
          hardwarePresent: true,
          kinds: {BiometricKind.face},
        );
      final enrollment = FakeBiometricEnrollmentGuard();

      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> launch() async {
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              sessionStoreProvider.overrideWith((ref) => store),
              biometricAuthenticatorProvider.overrideWithValue(biometrics),
              biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
              accessNotifierProvider.overrideWith(_QuietAccessNotifier.new),
              statusListNotifierProvider.overrideWith(
                _QuietStatusListNotifier.new,
              ),
            ],
            child: const KeevaApp(),
          ),
        );
        for (var i = 0; i < 12; i++) {
          await tester.pump();
        }
      }

      await launch();
      expect(find.byType(LoginScreen), findsOneWidget);

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

      expect(find.text('Unlock with biometrics?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('biometric_offer_enable')));
      await tester.pump();
      await tester.pump();
      expect(find.byType(MomentsScreen), findsOneWidget);
      expect(
        store.values.values.any((value) => value.contains('mr-nishanth')),
        isFalse,
      );

      biometrics.nextResult = const BiometricUnlockResult.cancelled();
      await launch();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(AuthCopy.cancelled), findsOneWidget);
      expect(find.byType(MomentsScreen), findsNothing);

      biometrics.nextResult = const BiometricUnlockResult.success();
      await tester.tap(find.byKey(const Key('login_biometric_retry')));
      for (var i = 0; i < 12; i++) {
        await tester.pump();
      }
      expect(find.byType(MomentsScreen), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(SettingsScreen), findsOneWidget);
      final signOut = find.byKey(const Key('settings_sign_out'));
      await tester.scrollUntilVisible(signOut, 200);
      await tester.tap(signOut);
      await tester.pump();
      await tester.pump();
      await tester.tap(find.byKey(const Key('settings_sign_out_confirm')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(store.values, isEmpty);
    },
  );
}
