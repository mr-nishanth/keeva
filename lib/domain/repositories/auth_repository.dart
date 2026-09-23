import '../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../entities/biometric_unlock_preference.dart';

/// Source of truth for the local Keeva sign-in session.
///
/// Implementations persist the session on-device. Callers do not choose
/// the storage mechanism. The password is never persisted.
abstract interface class AuthRepository {
  /// Returns the saved session, or null when no valid session is stored.
  Future<Result<AuthSession?>> readSession();

  /// Checks [username] and [password], then persists a session on success.
  Future<Result<AuthSession>> signIn({
    required String username,
    required String password,
  });

  /// Deletes the session token and biometric unlock preference.
  Future<Result<bool>> signOut();

  /// Reads whether biometric unlock may restore the saved session.
  Future<Result<BiometricUnlockPreference>> readBiometricUnlock();

  /// Arms biometric unlock. [enrollmentToken] is an opaque enrollment binding.
  Future<Result<bool>> enableBiometricUnlock({String? enrollmentToken});

  /// Disarms biometric unlock. The current session token is left in place.
  Future<Result<bool>> disableBiometricUnlock();

  /// Records that the user declined the post-sign-in biometric offer.
  Future<Result<bool>> dismissBiometricOffer();
}
