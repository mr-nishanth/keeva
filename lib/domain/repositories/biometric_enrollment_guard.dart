/// Whether the biometric enrollment captured at opt-in is still current.
enum EnrollmentContinuity { unchanged, changed, unavailable, unsupported }

/// Binds biometric unlock to the device's current biometric enrollment.
///
/// Android uses a Keystore key with biometric-enrollment invalidation.
/// iOS compares `LAContext.evaluatedPolicyDomainState`.
/// Platforms that cannot observe enrollment return [EnrollmentContinuity.unsupported].
abstract interface class BiometricEnrollmentGuard {
  /// Captures the current enrollment. Returns null when the platform cannot
  /// bind enrollment changes.
  Future<String?> bind();

  /// Compares [storedToken] with the current enrollment.
  Future<EnrollmentContinuity> check(String? storedToken);

  /// Drops any platform enrollment binding. Secure-storage flags are separate.
  Future<void> clear();
}
