/// On-device preference for unlocking the saved session with biometrics.
///
/// The password is never part of this preference. [enrollmentToken] is an
/// opaque binding to the current biometric enrollment when the platform can
/// provide one. It is not a credential.
final class BiometricUnlockPreference {
  final bool enabled;
  final String? enrollmentToken;
  final bool offerDismissed;

  const BiometricUnlockPreference({
    required this.enabled,
    this.enrollmentToken,
    required this.offerDismissed,
  });

  static const disabled = BiometricUnlockPreference(
    enabled: false,
    offerDismissed: false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BiometricUnlockPreference &&
          other.runtimeType == runtimeType &&
          other.enabled == enabled &&
          other.enrollmentToken == enrollmentToken &&
          other.offerDismissed == offerDismissed);

  @override
  int get hashCode =>
      Object.hash(runtimeType, enabled, enrollmentToken, offerDismissed);

  @override
  String toString() =>
      'BiometricUnlockPreference(enabled: $enabled, offerDismissed: $offerDismissed)';
}
