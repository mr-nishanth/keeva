import '../entities/biometric_capability.dart';
import '../entities/biometric_unlock_result.dart';

/// Platform biometric prompt.
///
/// Implementations must call the operating system's biometric API. They must
/// not compare fingerprints, face images, or password hashes themselves.
abstract interface class BiometricAuthenticator {
  Future<BiometricCapability> capability();

  Future<BiometricUnlockResult> authenticate({required String localizedReason});
}
