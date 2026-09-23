import '../../core/errors/app_failure.dart';
import '../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth/local_credential_checker.dart';
import '../auth/session_store.dart';

/// Local sign-in repository.
///
/// Valid credentials create an on-device session marker. The password itself
/// is never persisted.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._sessionStore, {
    this._credentialChecker = const LocalCredentialChecker(),
  });

  /// Secure-store key for the session marker.
  static const String sessionMarkerKey = 'keeva.auth.session.marker';

  final SessionStore _sessionStore;
  final LocalCredentialChecker _credentialChecker;

  @override
  Future<Result<AuthSession?>> readSession() async {
    try {
      final marker = await _sessionStore.read(key: sessionMarkerKey);
      if (!_credentialChecker.isCurrentSessionMarker(marker)) {
        if (marker != null) {
          await _sessionStore.delete(key: sessionMarkerKey);
        }
        return const Result.success(null);
      }
      return const Result.success(
        AuthSession(username: LocalCredentialChecker.accountUsername),
      );
    } on Object {
      return const Result.failure(
        AuthPersistenceFailure(
          'Could not read the saved sign-in on this device.',
        ),
      );
    }
  }

  @override
  Future<Result<AuthSession>> signIn({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedPassword = password.trim();
    if (normalizedUsername.isEmpty || normalizedPassword.isEmpty) {
      return const Result.failure(
        InvalidCredentialsFailure('Enter your username and password.'),
      );
    }

    final accepted = _credentialChecker.matches(
      username: normalizedUsername,
      password: normalizedPassword,
    );
    if (!accepted) {
      return const Result.failure(
        InvalidCredentialsFailure('That username or password is incorrect.'),
      );
    }

    try {
      await _sessionStore.write(
        key: sessionMarkerKey,
        value: _credentialChecker.sessionMarker,
      );
    } on Object {
      return const Result.failure(
        AuthPersistenceFailure(
          'Could not save your sign-in on this device. Try again.',
        ),
      );
    }

    return const Result.success(
      AuthSession(username: LocalCredentialChecker.accountUsername),
    );
  }
}
