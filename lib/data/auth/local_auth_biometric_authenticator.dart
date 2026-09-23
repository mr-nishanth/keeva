import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/entities/biometric_capability.dart';
import '../../domain/entities/biometric_unlock_result.dart';
import '../../domain/repositories/biometric_authenticator.dart';

/// Narrow wrapper around [LocalAuthentication] so tests can fake the plugin.
abstract interface class LocalAuthGateway {
  Future<bool> canCheckBiometrics();

  Future<bool> isDeviceSupported();

  Future<List<BiometricType>> availableBiometrics();

  Future<bool> authenticate({required String localizedReason});
}

/// Production gateway. Prompts are biometric-only so device PIN is not a
/// substitute for the Keeva password.
final class PluginLocalAuthGateway implements LocalAuthGateway {
  PluginLocalAuthGateway({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> canCheckBiometrics() => _authentication.canCheckBiometrics;

  @override
  Future<bool> isDeviceSupported() => _authentication.isDeviceSupported();

  @override
  Future<List<BiometricType>> availableBiometrics() =>
      _authentication.getAvailableBiometrics();

  @override
  Future<bool> authenticate({required String localizedReason}) {
    return _authentication.authenticate(
      localizedReason: localizedReason,
      biometricOnly: true,
      sensitiveTransaction: true,
      persistAcrossBackgrounding: true,
    );
  }
}

/// Maps plugin enrollment to a [BiometricCapability].
///
/// An empty enrollment list means biometric unlock cannot be offered, even
/// when the device has hardware.
BiometricCapability capabilityFromEnrollment({
  required bool deviceSupported,
  required bool canCheckBiometrics,
  required List<BiometricType> enrolled,
}) {
  final kinds = <BiometricKind>{
    for (final type in enrolled)
      switch (type) {
        BiometricType.fingerprint => BiometricKind.fingerprint,
        BiometricType.face => BiometricKind.face,
        BiometricType.iris => BiometricKind.iris,
        BiometricType.strong => BiometricKind.strong,
        BiometricType.weak => BiometricKind.weak,
      },
  };
  return BiometricCapability(
    canAuthenticate: kinds.isNotEmpty,
    hardwarePresent: deviceSupported || canCheckBiometrics || kinds.isNotEmpty,
    kinds: kinds,
  );
}

/// Maps a plugin failure onto the app's unlock result.
///
/// Unknown future error codes fall through to [BiometricUnlockStatus.failed]
/// so a new plugin code cannot be treated as success.
BiometricUnlockResult resultFromLocalAuthException(
  LocalAuthException exception,
) {
  return switch (exception.code) {
    LocalAuthExceptionCode.userCanceled ||
    LocalAuthExceptionCode.systemCanceled ||
    LocalAuthExceptionCode.timeout ||
    LocalAuthExceptionCode.userRequestedFallback =>
      const BiometricUnlockResult.cancelled(),
    LocalAuthExceptionCode.temporaryLockout ||
    LocalAuthExceptionCode.biometricLockout =>
      const BiometricUnlockResult.lockout(),
    LocalAuthExceptionCode.noBiometricHardware ||
    LocalAuthExceptionCode.noBiometricsEnrolled ||
    LocalAuthExceptionCode.noCredentialsSet ||
    LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
      const BiometricUnlockResult.unavailable(),
    _ => const BiometricUnlockResult.failed(),
  };
}

/// Biometric prompts via the `local_auth` plugin.
///
/// The plugin calls Android BiometricPrompt and iOS LocalAuthentication.
/// Keeva does not capture or compare biometric samples.
final class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthGateway? gateway})
    : _gateway = gateway ?? PluginLocalAuthGateway();

  final LocalAuthGateway _gateway;

  @override
  Future<BiometricCapability> capability() async {
    try {
      final supported = await _gateway.isDeviceSupported();
      final canCheck = await _gateway.canCheckBiometrics();
      final enrolled = await _gateway.availableBiometrics();
      return capabilityFromEnrollment(
        deviceSupported: supported,
        canCheckBiometrics: canCheck,
        enrolled: enrolled,
      );
    } on LocalAuthException {
      return BiometricCapability.unavailable;
    } on MissingPluginException {
      // Desktop tests and platforms without the plugin stay password-only.
      return BiometricCapability.unavailable;
    } on PlatformException {
      return BiometricCapability.unavailable;
    }
  }

  @override
  Future<BiometricUnlockResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      final accepted = await _gateway.authenticate(
        localizedReason: localizedReason,
      );
      if (accepted) return const BiometricUnlockResult.success();
      return const BiometricUnlockResult.failed();
    } on LocalAuthException catch (exception) {
      return resultFromLocalAuthException(exception);
    } on MissingPluginException {
      return const BiometricUnlockResult.unavailable();
    } on PlatformException {
      return const BiometricUnlockResult.unavailable();
    }
  }
}
