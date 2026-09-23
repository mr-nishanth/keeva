import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:whatsapp_status_saver/data/auth/local_auth_biometric_authenticator.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_capability.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_unlock_result.dart';

void main() {
  group('capabilityFromEnrollment', () {
    test('hides enablement when nothing is enrolled', () {
      final capability = capabilityFromEnrollment(
        deviceSupported: true,
        canCheckBiometrics: true,
        enrolled: const [],
      );

      expect(capability.canAuthenticate, isFalse);
      expect(capability.hardwarePresent, isTrue);
      expect(capability.summary, contains('Enroll'));
    });

    test('reports no hardware when the device cannot check biometrics', () {
      final capability = capabilityFromEnrollment(
        deviceSupported: false,
        canCheckBiometrics: false,
        enrolled: const [],
      );

      expect(capability, BiometricCapability.unavailable);
      expect(capability.summary, contains('not available'));
    });

    test('recognizes fingerprint and face enrollment', () {
      final capability = capabilityFromEnrollment(
        deviceSupported: true,
        canCheckBiometrics: true,
        enrolled: const [BiometricType.fingerprint, BiometricType.face],
      );

      expect(capability.canAuthenticate, isTrue);
      expect(capability.hasFingerprint, isTrue);
      expect(capability.hasFace, isTrue);
      expect(capability.summary, contains('fingerprint or face'));
    });

    test('treats a strong or weak classification as usable biometrics', () {
      final capability = capabilityFromEnrollment(
        deviceSupported: true,
        canCheckBiometrics: true,
        enrolled: const [BiometricType.strong],
      );

      expect(capability.canAuthenticate, isTrue);
      expect(capability.kinds, {BiometricKind.strong});
    });
  });

  group('resultFromLocalAuthException', () {
    test('maps cancel, lockout, and missing hardware', () {
      expect(
        resultFromLocalAuthException(
          const LocalAuthException(code: LocalAuthExceptionCode.userCanceled),
        ),
        const BiometricUnlockResult.cancelled(),
      );
      expect(
        resultFromLocalAuthException(
          const LocalAuthException(
            code: LocalAuthExceptionCode.userRequestedFallback,
          ),
        ).status,
        BiometricUnlockStatus.cancelled,
      );
      expect(
        resultFromLocalAuthException(
          const LocalAuthException(
            code: LocalAuthExceptionCode.biometricLockout,
          ),
        ).status,
        BiometricUnlockStatus.lockout,
      );
      expect(
        resultFromLocalAuthException(
          const LocalAuthException(
            code: LocalAuthExceptionCode.noBiometricHardware,
          ),
        ).status,
        BiometricUnlockStatus.unavailable,
      );
      expect(
        resultFromLocalAuthException(
          const LocalAuthException(code: LocalAuthExceptionCode.unknownError),
        ).status,
        BiometricUnlockStatus.failed,
      );
    });
  });

  group('LocalAuthBiometricAuthenticator', () {
    test('returns success only when the gateway accepts the prompt', () async {
      final gateway = _FakeGateway(accepted: true);
      final authenticator = LocalAuthBiometricAuthenticator(gateway: gateway);

      final result = await authenticator.authenticate(
        localizedReason: 'Unlock Keeva',
      );

      expect(result.isSuccess, isTrue);
      expect(gateway.lastReason, 'Unlock Keeva');
    });

    test('maps a false result to failure and a cancel exception', () async {
      final rejected = LocalAuthBiometricAuthenticator(
        gateway: _FakeGateway(accepted: false),
      );
      expect(
        (await rejected.authenticate(localizedReason: 'Unlock')).status,
        BiometricUnlockStatus.failed,
      );

      final cancelled = LocalAuthBiometricAuthenticator(
        gateway: _FakeGateway(
          accepted: false,
          error: const LocalAuthException(
            code: LocalAuthExceptionCode.systemCanceled,
          ),
        ),
      );
      expect(
        (await cancelled.authenticate(localizedReason: 'Unlock')).status,
        BiometricUnlockStatus.cancelled,
      );
    });

    test('capability follows the gateway enrollment list', () async {
      final authenticator = LocalAuthBiometricAuthenticator(
        gateway: _FakeGateway(
          accepted: false,
          enrolled: const [BiometricType.fingerprint],
        ),
      );

      final capability = await authenticator.capability();

      expect(capability.canAuthenticate, isTrue);
      expect(capability.hasFingerprint, isTrue);
    });
  });
}

class _FakeGateway implements LocalAuthGateway {
  _FakeGateway({required this.accepted, this.error, this.enrolled = const []});

  final bool accepted;
  final LocalAuthException? error;
  final List<BiometricType> enrolled;
  String? lastReason;

  @override
  Future<List<BiometricType>> availableBiometrics() async => enrolled;

  @override
  Future<bool> canCheckBiometrics() async => true;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    lastReason = localizedReason;
    final thrown = error;
    if (thrown != null) throw thrown;
    return accepted;
  }
}
