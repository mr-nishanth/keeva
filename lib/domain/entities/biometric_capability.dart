/// A biometric sensor the platform reports as enrolled.
enum BiometricKind { fingerprint, face, iris, strong, weak }

/// Whether this device can unlock Keeva with platform biometrics.
///
/// [canAuthenticate] is true only when biometric hardware is present and at
/// least one biometric is enrolled. A device without hardware, or with
/// hardware but nothing enrolled, stays on the username and password gate.
final class BiometricCapability {
  final bool canAuthenticate;
  final bool hardwarePresent;
  final Set<BiometricKind> kinds;

  const BiometricCapability({
    required this.canAuthenticate,
    this.hardwarePresent = false,
    this.kinds = const {},
  });

  static const unavailable = BiometricCapability(canAuthenticate: false);

  bool get hasFingerprint => kinds.contains(BiometricKind.fingerprint);

  bool get hasFace => kinds.contains(BiometricKind.face);

  /// Short label for settings and the unlock screen.
  String get summary {
    if (!canAuthenticate && !hardwarePresent) {
      return 'Biometric hardware is not available on this device.';
    }
    if (!canAuthenticate) {
      return 'Enroll a fingerprint or face in system settings to use biometric unlock.';
    }
    if (hasFingerprint && hasFace) {
      return 'Use fingerprint or face unlock to open Keeva.';
    }
    if (hasFace) {
      return 'Use Face ID or face unlock to open Keeva.';
    }
    if (hasFingerprint) {
      return 'Use fingerprint unlock to open Keeva.';
    }
    return 'Use biometric unlock to open Keeva.';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BiometricCapability &&
          other.runtimeType == runtimeType &&
          other.canAuthenticate == canAuthenticate &&
          other.hardwarePresent == hardwarePresent &&
          _sameKinds(other.kinds));

  bool _sameKinds(Set<BiometricKind> other) {
    if (kinds.length != other.length) return false;
    return kinds.containsAll(other);
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    canAuthenticate,
    hardwarePresent,
    Object.hashAllUnordered(kinds),
  );

  @override
  String toString() =>
      'BiometricCapability(canAuthenticate: $canAuthenticate, hardwarePresent: $hardwarePresent, kinds: $kinds)';
}
