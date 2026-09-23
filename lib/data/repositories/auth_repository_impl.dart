import 'dart:math';

import '../../core/errors/app_failure.dart';
import '../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/biometric_unlock_preference.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth/local_credential_checker.dart';
import '../auth/session_store.dart';

/// Local sign-in repository.
///
/// A successful sign-in writes a random session token and the current
/// credentials version. The password is never persisted.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._sessionStore, {
    this._credentialChecker = const LocalCredentialChecker(),
    Random? random,
  }) : _random = random ?? Random.secure();

  /// Secure-store key for the random session token.
  static const String sessionTokenKey = 'keeva.auth.session.token';

  /// Secure-store key for the credentials version that invalidates old sessions.
  static const String credentialsVersionKey = 'keeva.auth.session.credentials';

  /// Secure-store flag that biometric success is required before restoring
  /// [sessionTokenKey]. The value is [biometricEnabledValue], never a password.
  static const String biometricEnabledKey = 'keeva.auth.biometric.enabled';

  /// Opaque enrollment binding. Not a credential.
  static const String biometricEnrollmentKey =
      'keeva.auth.biometric.enrollment';

  /// Set when the user declines the one-time biometric offer.
  static const String biometricOfferDismissedKey =
      'keeva.auth.biometric.offer_dismissed';

  static const String biometricEnabledValue = '1';

  static const int _tokenBytes = 32;

  final SessionStore _sessionStore;
  final LocalCredentialChecker _credentialChecker;
  final Random _random;

  @override
  Future<Result<AuthSession?>> readSession() async {
    try {
      final token = await _sessionStore.read(key: sessionTokenKey);
      final version = await _sessionStore.read(key: credentialsVersionKey);
      final valid =
          _isSessionToken(token) &&
          _credentialChecker.isCurrentCredentialsVersion(version);
      if (!valid) {
        if (token != null || version != null) {
          await _deleteSession();
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
    if (normalizedUsername.isEmpty || password.isEmpty) {
      return const Result.failure(
        InvalidCredentialsFailure('Enter your username and password.'),
      );
    }

    final accepted = _credentialChecker.matches(
      username: normalizedUsername,
      password: password,
    );
    if (!accepted) {
      return const Result.failure(
        InvalidCredentialsFailure('That username or password is incorrect.'),
      );
    }

    try {
      await _sessionStore.write(
        key: credentialsVersionKey,
        value: LocalCredentialChecker.credentialsVersionHex,
      );
      await _sessionStore.write(
        key: sessionTokenKey,
        value: _newSessionToken(),
      );
    } on Object {
      await _deleteSession();
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

  @override
  Future<Result<bool>> signOut() async {
    final deleted = await _deleteKeys(const [
      sessionTokenKey,
      credentialsVersionKey,
      biometricEnabledKey,
      biometricEnrollmentKey,
      biometricOfferDismissedKey,
    ]);
    if (!deleted) {
      return const Result.failure(
        AuthPersistenceFailure('Could not sign out on this device. Try again.'),
      );
    }
    return const Result.success(true);
  }

  @override
  Future<Result<BiometricUnlockPreference>> readBiometricUnlock() async {
    try {
      final enabled = await _sessionStore.read(key: biometricEnabledKey);
      final token = await _sessionStore.read(key: biometricEnrollmentKey);
      final dismissed = await _sessionStore.read(
        key: biometricOfferDismissedKey,
      );
      return Result.success(
        BiometricUnlockPreference(
          enabled: enabled == biometricEnabledValue,
          enrollmentToken: token,
          offerDismissed: dismissed == biometricEnabledValue,
        ),
      );
    } on Object {
      return const Result.failure(
        AuthPersistenceFailure(
          'Could not read biometric unlock settings on this device.',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> enableBiometricUnlock({String? enrollmentToken}) async {
    try {
      if (enrollmentToken == null || enrollmentToken.isEmpty) {
        await _sessionStore.delete(key: biometricEnrollmentKey);
      } else {
        await _sessionStore.write(
          key: biometricEnrollmentKey,
          value: enrollmentToken,
        );
      }
      await _sessionStore.write(
        key: biometricEnabledKey,
        value: biometricEnabledValue,
      );
      return const Result.success(true);
    } on Object {
      await _deleteBiometricUnlockKeys();
      return const Result.failure(
        AuthPersistenceFailure(
          'Could not turn on biometric unlock on this device. Try again.',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> disableBiometricUnlock() async {
    try {
      await _deleteBiometricUnlockKeys();
      return const Result.success(true);
    } on Object {
      return const Result.failure(
        AuthPersistenceFailure(
          'Could not turn off biometric unlock on this device. Try again.',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> dismissBiometricOffer() async {
    try {
      await _sessionStore.write(
        key: biometricOfferDismissedKey,
        value: biometricEnabledValue,
      );
      return const Result.success(true);
    } on Object {
      return const Result.failure(
        AuthPersistenceFailure(
          'Could not save your biometric choice on this device.',
        ),
      );
    }
  }

  String _newSessionToken() {
    final buffer = StringBuffer();
    for (var index = 0; index < _tokenBytes; index++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  bool _isSessionToken(String? token) {
    if (token == null || token.length != _tokenBytes * 2) return false;
    for (final unit in token.codeUnits) {
      final isDigit = unit >= 0x30 && unit <= 0x39;
      final isLowerHex = unit >= 0x61 && unit <= 0x66;
      if (!isDigit && !isLowerHex) return false;
    }
    return true;
  }

  /// Removes any partial session. Failures here are ignored because the
  /// caller is already returning a persistence error or an empty session.
  Future<void> _deleteSession() async {
    try {
      await _sessionStore.delete(key: sessionTokenKey);
    } on Object {
      // Cleanup is best-effort. Sign-in still fails closed.
    }
    try {
      await _sessionStore.delete(key: credentialsVersionKey);
    } on Object {
      // Cleanup is best-effort. Sign-in still fails closed.
    }
  }

  /// Removes the biometric flag and enrollment binding. The declined-offer
  /// marker is kept so disabling unlock does not immediately ask again.
  Future<void> _deleteBiometricUnlockKeys() async {
    try {
      await _sessionStore.delete(key: biometricEnabledKey);
    } on Object {
      // Cleanup is best-effort. The caller reports the original failure.
    }
    try {
      await _sessionStore.delete(key: biometricEnrollmentKey);
    } on Object {
      // Cleanup is best-effort. The caller reports the original failure.
    }
  }

  /// Deletes every [keys] entry. Returns false when any delete throws so
  /// sign-out can fail closed instead of leaving a restorable session.
  Future<bool> _deleteKeys(List<String> keys) async {
    var deleted = true;
    for (final key in keys) {
      try {
        await _sessionStore.delete(key: key);
      } on Object {
        deleted = false;
      }
    }
    return deleted;
  }
}
