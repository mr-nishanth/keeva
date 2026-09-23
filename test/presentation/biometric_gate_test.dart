import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/app/app.dart';
import 'package:whatsapp_status_saver/application/access/access_notifier.dart';
import 'package:whatsapp_status_saver/application/access/access_state.dart';
import 'package:whatsapp_status_saver/application/auth/auth_copy.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_notifier.dart';
import 'package:whatsapp_status_saver/application/statuses/status_list_state.dart';
import 'package:whatsapp_status_saver/data/repositories/auth_repository_impl.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_capability.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_unlock_result.dart';
import 'package:whatsapp_status_saver/domain/repositories/biometric_enrollment_guard.dart';
import 'package:whatsapp_status_saver/presentation/auth/biometric_unlock_screen.dart';
import 'package:whatsapp_status_saver/presentation/auth/login_screen.dart';
import 'package:whatsapp_status_saver/presentation/moments/moments_screen.dart';
import 'package:whatsapp_status_saver/presentation/settings/settings_screen.dart';

import '../support/fake_biometric.dart';
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
  @override
  StatusListState build() => StatusListSuccess(items: const []);

  @override
  Future<void> load({String targetPackage = ''}) async {}
}

/// Cold start runs restore, then a biometric prompt, across several
/// completed futures and post-frame callbacks. A spinner stays scheduled,
/// so this advances a fixed number of frames instead of settling.
Future<void> pumpAuthFrames(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  late FakeSessionStore store;
  late FakeBiometricAuthenticator biometrics;
  late FakeBiometricEnrollmentGuard enrollment;

  setUp(() {
    store = FakeSessionStore();
    biometrics = FakeBiometricAuthenticator()
      ..capabilityResult = const BiometricCapability(
        canAuthenticate: true,
        hardwarePresent: true,
        kinds: {BiometricKind.fingerprint, BiometricKind.face},
      );
    enrollment = FakeBiometricEnrollmentGuard();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          sessionStoreProvider.overrideWith((ref) => store),
          biometricAuthenticatorProvider.overrideWithValue(biometrics),
          biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
          accessNotifierProvider.overrideWith(
            () => _QuietAccessNotifier(const AccessGranted()),
          ),
          statusListNotifierProvider.overrideWith(_QuietStatusListNotifier.new),
        ],
        child: const KeevaApp(),
      ),
    );
    await pumpAuthFrames(tester);
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('login_username')), 'nishanth');
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'mr-nishanth',
    );
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    await tester.pump();
  }

  group('Biometric gate', () {
    testWidgets('offers biometric unlock after the first password sign-in', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('Unlock with biometrics?'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      await tester.tap(find.byKey(const Key('biometric_offer_dismiss')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MomentsScreen), findsOneWidget);
      expect(
        store.values.containsKey(AuthRepositoryImpl.biometricEnabledKey),
        isFalse,
      );
      expect(
        store.values[AuthRepositoryImpl.biometricOfferDismissedKey],
        AuthRepositoryImpl.biometricEnabledValue,
      );
    });

    testWidgets('does not offer biometrics when none are enrolled', (
      tester,
    ) async {
      biometrics.capabilityResult = BiometricCapability.unavailable;

      await pumpApp(tester);
      await signIn(tester);

      expect(find.text('Unlock with biometrics?'), findsNothing);
      expect(find.byType(MomentsScreen), findsOneWidget);
    });

    testWidgets('enabled biometrics prompt before restoring the session', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await tester.tap(find.byKey(const Key('biometric_offer_enable')));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MomentsScreen), findsOneWidget);
      expect(
        store.values[AuthRepositoryImpl.biometricEnabledKey],
        AuthRepositoryImpl.biometricEnabledValue,
      );
      expect(
        store.values.values.any((value) => value.contains('mr-nishanth')),
        isFalse,
      );

      biometrics.gate = Completer<BiometricUnlockResult>();
      await pumpApp(tester);

      expect(find.byType(BiometricUnlockScreen), findsOneWidget);
      expect(find.byType(MomentsScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);

      biometrics.gate!.complete(const BiometricUnlockResult.success());
      await pumpAuthFrames(tester);

      expect(find.byType(MomentsScreen), findsOneWidget);
    });

    testWidgets('a cancelled prompt falls back to the password form', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await tester.tap(find.byKey(const Key('biometric_offer_enable')));
      await tester.pump();
      await tester.pump();

      biometrics.nextResult = const BiometricUnlockResult.cancelled();
      await pumpApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(AuthCopy.cancelled), findsOneWidget);
      expect(find.byKey(const Key('login_biometric_retry')), findsOneWidget);
      expect(find.byType(MomentsScreen), findsNothing);
      expect(
        store.values.containsKey(AuthRepositoryImpl.sessionTokenKey),
        isTrue,
      );
    });

    testWidgets('enrollment changes require the password again', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);
      await tester.tap(find.byKey(const Key('biometric_offer_enable')));
      await tester.pump();
      await tester.pump();

      enrollment.continuity = EnrollmentContinuity.changed;
      await pumpApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(AuthCopy.enrollmentChanged), findsOneWidget);
      expect(find.byType(BiometricUnlockScreen), findsNothing);
      expect(
        store.values.containsKey(AuthRepositoryImpl.sessionTokenKey),
        isFalse,
      );
      expect(
        store.values.containsKey(AuthRepositoryImpl.biometricEnabledKey),
        isFalse,
      );
    });

    testWidgets('settings can enable, disable, and sign out', (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      await tester.tap(find.byKey(const Key('biometric_offer_dismiss')));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Settings'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SettingsScreen), findsOneWidget);
      final switchFinder = find.byKey(const Key('settings_biometric_switch'));
      await tester.scrollUntilVisible(switchFinder, 200);
      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump();

      expect(tester.widget<Switch>(switchFinder).value, isTrue);
      expect(
        store.values[AuthRepositoryImpl.biometricEnabledKey],
        AuthRepositoryImpl.biometricEnabledValue,
      );

      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump();

      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      expect(
        store.values.containsKey(AuthRepositoryImpl.biometricEnabledKey),
        isFalse,
      );

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
    });

    testWidgets('settings disables biometric enablement without hardware', (
      tester,
    ) async {
      biometrics.capabilityResult = BiometricCapability.unavailable;
      await pumpApp(tester);
      await signIn(tester);

      await tester.tap(find.text('Settings'));
      await tester.pump();
      await tester.pump();

      final toggleFinder = find.byKey(const Key('settings_biometric_switch'));
      await tester.scrollUntilVisible(toggleFinder, 200);
      final toggle = tester.widget<Switch>(toggleFinder);
      expect(toggle.onChanged, isNull);
      expect(find.textContaining('not available'), findsOneWidget);
      expect(find.byType(MomentsScreen), findsNothing);
    });
  });
}
