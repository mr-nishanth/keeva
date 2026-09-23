import '../../core/result/result.dart';
import '../entities/auth_session.dart';

/// Source of truth for the local Keeva sign-in session.
///
/// Implementations persist the session on-device. Callers do not choose
/// the storage mechanism.
abstract interface class AuthRepository {
  /// Returns the saved session, or null when no valid session is stored.
  Future<Result<AuthSession?>> readSession();

  /// Checks [username] and [password], then persists a session on success.
  Future<Result<AuthSession>> signIn({
    required String username,
    required String password,
  });
}
