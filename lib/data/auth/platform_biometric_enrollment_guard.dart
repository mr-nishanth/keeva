import 'package:flutter/services.dart';

import '../../domain/repositories/biometric_enrollment_guard.dart';
import '../../platform/channel_constants.dart';

/// Parses the native enrollment-guard status strings.
EnrollmentContinuity parseEnrollmentStatus(String? value) {
  return switch (value) {
    'unchanged' => EnrollmentContinuity.unchanged,
    'changed' => EnrollmentContinuity.changed,
    'unavailable' => EnrollmentContinuity.unavailable,
    _ => EnrollmentContinuity.unsupported,
  };
}

/// Method-channel enrollment guard.
///
/// Android creates a Keystore key that the platform invalidates when biometric
/// enrollment changes. iOS returns `evaluatedPolicyDomainState`. A missing
/// plugin means this platform cannot observe enrollment, which is not treated
/// as a change.
final class PlatformBiometricEnrollmentGuard
    implements BiometricEnrollmentGuard {
  PlatformBiometricEnrollmentGuard({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel(ChannelConstants.biometricGuardChannelName);

  final MethodChannel _channel;

  @override
  Future<String?> bind() async {
    try {
      final token = await _channel.invokeMethod<String>('bind');
      if (token == null || token.isEmpty) return null;
      return token;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<EnrollmentContinuity> check(String? storedToken) async {
    try {
      final status = await _channel.invokeMethod<String>('check', {
        'token': storedToken,
      });
      return parseEnrollmentStatus(status);
    } on MissingPluginException {
      return EnrollmentContinuity.unsupported;
    } on PlatformException {
      return EnrollmentContinuity.unsupported;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _channel.invokeMethod<void>('clear');
    } on MissingPluginException {
      // Nothing to clear when the platform has no enrollment binding.
    } on PlatformException {
      // Clearing is best-effort. Sign-out still deletes the secure-store flag.
    }
  }
}
