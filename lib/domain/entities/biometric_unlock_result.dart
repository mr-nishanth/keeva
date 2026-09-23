/// Outcome of one platform biometric prompt.
enum BiometricUnlockStatus {
  success,
  cancelled,
  failed,
  unavailable,
  enrollmentChanged,
  lockout,
}

/// Result of asking the platform to authenticate with biometrics.
///
/// This is not a password check and does not carry a secret.
final class BiometricUnlockResult {
  final BiometricUnlockStatus status;

  const BiometricUnlockResult(this.status);

  const BiometricUnlockResult.success()
    : status = BiometricUnlockStatus.success;

  const BiometricUnlockResult.cancelled()
    : status = BiometricUnlockStatus.cancelled;

  const BiometricUnlockResult.failed() : status = BiometricUnlockStatus.failed;

  const BiometricUnlockResult.unavailable()
    : status = BiometricUnlockStatus.unavailable;

  const BiometricUnlockResult.enrollmentChanged()
    : status = BiometricUnlockStatus.enrollmentChanged;

  const BiometricUnlockResult.lockout()
    : status = BiometricUnlockStatus.lockout;

  bool get isSuccess => status == BiometricUnlockStatus.success;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BiometricUnlockResult &&
          other.runtimeType == runtimeType &&
          other.status == status);

  @override
  int get hashCode => Object.hash(runtimeType, status);

  @override
  String toString() => 'BiometricUnlockResult($status)';
}
