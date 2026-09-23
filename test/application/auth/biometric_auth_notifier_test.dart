import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/auth/auth_copy.dart';
import 'package:whatsapp_status_saver/application/auth/auth_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/data/repositories/auth_repository_impl.dart';
import 'package:whatsapp_status_saver/domain/entities/auth_session.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_capability.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_unlock_result.dart';
import 'package:whatsapp_status_saver/domain/repositories/biometric_enrollment_guard.dart';

import '../../support/fake_biometric.dart';
import '../../support/fake_session_store.dart';

void main() {
  const session = AuthSession(username: 'nishanth');
  late FakeSessionStore store;
  late FakeBiometricAuthenticator biometrics;
  late FakeBiometricEnrollmentGuard enrollment;
  late ProviderContainer container;

  setUp(() {
    store = FakeSessionStore();
    biometrics = FakeBiometricAuthenticator()
      ..capabilityResult = const BiometricCapability(
        canAuthenticate: true,
        hardwarePresent: true,
        kinds: {BiometricKind.fingerprint, BiometricKind.face},
      );
    enrollment = FakeBiometricEnrollmentGuard();
    container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
        biometricAuthenticatorProvider.overrideWithValue(biometrics),
        biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> signIn() {
    return container
        .read(authNotifierProvider.notifier)
        .signIn(username: 'nishanth', password: 'mr-nishanth');
  }

  group('biometric unlock', () {
    test(
      'first password sign-in offers setup when biometrics are enrolled',
      () async {
        await signIn();

        expect(
          container.read(authNotifierProvider),
          const AuthAuthenticated(session, offerBiometricSetup: true),
        );
        expect(
          store.values.values.any((value) => value.contains('mr-nishanth')),
          isFalse,
        );
      },
    );

    test('does not offer setup when hardware is unavailable', () async {
      biometrics.capabilityResult = BiometricCapability.unavailable;

      await signIn();

      expect(
        container.read(authNotifierProvider),
        const AuthAuthenticated(session),
      );
    });

    test('enable stores an enrollment binding and not the password', () async {
      await signIn();

      final enabled = await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();

      expect(enabled, isTrue);
      expect(
        store.values[AuthRepositoryImpl.biometricEnabledKey],
        AuthRepositoryImpl.biometricEnabledValue,
      );
      expect(
        store.values[AuthRepositoryImpl.biometricEnrollmentKey],
        'enrollment-token',
      );
      expect(
        store.values.values.any((value) => value.contains('mr-nishanth')),
        isFalse,
      );
      expect(biometrics.lastReason, AuthCopy.enableReason);
    });

    test('a cancelled enable leaves unlock off', () async {
      biometrics.nextResult = const BiometricUnlockResult.cancelled();
      await signIn();

      final enabled = await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();

      expect(enabled, isFalse);
      expect(
        store.values.containsKey(AuthRepositoryImpl.biometricEnabledKey),
        isFalse,
      );
      expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
    });

    test('restore waits for biometrics before opening the session', () async {
      await signIn();
      await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();

      final relaunched = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => store),
          biometricAuthenticatorProvider.overrideWithValue(biometrics),
          biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
        ],
      );
      addTearDown(relaunched.dispose);

      await relaunched.read(authNotifierProvider.notifier).restore();

      expect(relaunched.read(authNotifierProvider), isA<AuthBiometricLocked>());
      expect(relaunched.read(authNotifierProvider).isAuthenticated, isFalse);

      await relaunched
          .read(authNotifierProvider.notifier)
          .unlockWithBiometrics();

      expect(
        relaunched.read(authNotifierProvider),
        const AuthAuthenticated(session),
      );
    });

    test('cancel and failure fall back to the password form', () async {
      await signIn();
      await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();
      final relaunched = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => store),
          biometricAuthenticatorProvider.overrideWithValue(biometrics),
          biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
        ],
      );
      addTearDown(relaunched.dispose);
      await relaunched.read(authNotifierProvider.notifier).restore();

      biometrics.nextResult = const BiometricUnlockResult.cancelled();
      await relaunched
          .read(authNotifierProvider.notifier)
          .unlockWithBiometrics();

      final cancelled = relaunched.read(authNotifierProvider);
      expect(cancelled, isA<AuthUnauthenticated>());
      expect(cancelled.errorMessage, AuthCopy.cancelled);
      expect(cancelled.canRetryBiometric, isTrue);
      expect(
        store.values.containsKey(AuthRepositoryImpl.sessionTokenKey),
        isTrue,
      );

      biometrics.nextResult = const BiometricUnlockResult.failed();
      await relaunched
          .read(authNotifierProvider.notifier)
          .unlockWithBiometrics();
      expect(
        relaunched.read(authNotifierProvider).errorMessage,
        AuthCopy.failed,
      );
    });

    test('missing hardware does not restore the session', () async {
      await signIn();
      await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();
      biometrics.capabilityResult = BiometricCapability.unavailable;

      final relaunched = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => store),
          biometricAuthenticatorProvider.overrideWithValue(biometrics),
          biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
        ],
      );
      addTearDown(relaunched.dispose);
      await relaunched.read(authNotifierProvider.notifier).restore();

      final state = relaunched.read(authNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, AuthCopy.unavailable);
      expect(
        store.values.containsKey(AuthRepositoryImpl.sessionTokenKey),
        isTrue,
      );
    });

    test('enrollment change clears the session and biometric flag', () async {
      await signIn();
      await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();
      enrollment.continuity = EnrollmentContinuity.changed;

      final relaunched = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWith((ref) => store),
          biometricAuthenticatorProvider.overrideWithValue(biometrics),
          biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
        ],
      );
      addTearDown(relaunched.dispose);
      await relaunched.read(authNotifierProvider.notifier).restore();

      final state = relaunched.read(authNotifierProvider);
      expect(state, isA<AuthUnauthenticated>());
      expect(state.errorMessage, AuthCopy.enrollmentChanged);
      expect(
        store.values.containsKey(AuthRepositoryImpl.sessionTokenKey),
        isFalse,
      );
      expect(
        store.values.containsKey(AuthRepositoryImpl.biometricEnabledKey),
        isFalse,
      );
      expect(enrollment.clearCount, greaterThan(0));
    });

    test('disable leaves the session and sign-out removes both', () async {
      await signIn();
      await container
          .read(authNotifierProvider.notifier)
          .enableBiometricUnlock();

      final disabled = await container
          .read(authNotifierProvider.notifier)
          .disableBiometricUnlock();

      expect(disabled, isTrue);
      expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
      expect(
        store.values.containsKey(AuthRepositoryImpl.biometricEnabledKey),
        isFalse,
      );
      expect(
        store.values.containsKey(AuthRepositoryImpl.sessionTokenKey),
        isTrue,
      );

      final signedOut = await container
          .read(authNotifierProvider.notifier)
          .signOut();

      expect(signedOut, isTrue);
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
      expect(store.values, isEmpty);
    });

    test(
      'dismissing the offer skips it on the next password sign-in',
      () async {
        await signIn();
        await container
            .read(authNotifierProvider.notifier)
            .dismissBiometricOffer();
        store.values.remove(AuthRepositoryImpl.sessionTokenKey);
        store.values.remove(AuthRepositoryImpl.credentialsVersionKey);

        final relaunched = ProviderContainer(
          overrides: [
            sessionStoreProvider.overrideWith((ref) => store),
            biometricAuthenticatorProvider.overrideWithValue(biometrics),
            biometricEnrollmentGuardProvider.overrideWithValue(enrollment),
          ],
        );
        addTearDown(relaunched.dispose);
        await relaunched.read(authNotifierProvider.notifier).restore();
        await relaunched
            .read(authNotifierProvider.notifier)
            .signIn(username: 'nishanth', password: 'mr-nishanth');

        expect(
          relaunched.read(authNotifierProvider),
          const AuthAuthenticated(session),
        );
      },
    );

    test(
      'sign-out lets the next password sign-in offer biometrics again',
      () async {
        await signIn();
        await container
            .read(authNotifierProvider.notifier)
            .dismissBiometricOffer();
        await container.read(authNotifierProvider.notifier).signOut();
        await signIn();

        expect(
          container.read(authNotifierProvider),
          const AuthAuthenticated(session, offerBiometricSetup: true),
        );
      },
    );
  });
}
