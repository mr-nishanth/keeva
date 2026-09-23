import 'dart:async';

import 'package:whatsapp_status_saver/domain/entities/biometric_capability.dart';
import 'package:whatsapp_status_saver/domain/entities/biometric_unlock_result.dart';
import 'package:whatsapp_status_saver/domain/repositories/biometric_authenticator.dart';
import 'package:whatsapp_status_saver/domain/repositories/biometric_enrollment_guard.dart';

/// In-memory biometric prompt for tests. Does not touch a sensor.
class FakeBiometricAuthenticator implements BiometricAuthenticator {
  BiometricCapability capabilityResult = BiometricCapability.unavailable;

  BiometricUnlockResult nextResult = const BiometricUnlockResult.success();

  /// When set, [authenticate] waits on this future instead of [nextResult].
  Completer<BiometricUnlockResult>? gate;

  int authenticateCalls = 0;
  String? lastReason;

  @override
  Future<BiometricCapability> capability() async => capabilityResult;

  @override
  Future<BiometricUnlockResult> authenticate({
    required String localizedReason,
  }) {
    authenticateCalls++;
    lastReason = localizedReason;
    final pending = gate;
    if (pending != null) return pending.future;
    return Future<BiometricUnlockResult>.value(nextResult);
  }
}

/// In-memory enrollment binding for tests.
class FakeBiometricEnrollmentGuard implements BiometricEnrollmentGuard {
  EnrollmentContinuity continuity = EnrollmentContinuity.unchanged;
  String? tokenToBind = 'enrollment-token';
  int bindCount = 0;
  int clearCount = 0;
  String? lastCheckedToken;

  @override
  Future<String?> bind() async {
    bindCount++;
    return tokenToBind;
  }

  @override
  Future<EnrollmentContinuity> check(String? storedToken) async {
    lastCheckedToken = storedToken;
    return continuity;
  }

  @override
  Future<void> clear() async {
    clearCount++;
  }
}
