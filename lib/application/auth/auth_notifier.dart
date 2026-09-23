import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/biometric_unlock_preference.dart';
import '../../domain/entities/biometric_unlock_result.dart';
import '../../domain/repositories/biometric_enrollment_guard.dart';
import '../providers.dart';
import 'auth_copy.dart';
import 'auth_state.dart';

/// Restores and creates the local sign-in session.
///
/// A stored session token opens the app on its own only when biometric unlock
/// is off. When biometric unlock is on, the token stays in secure storage
/// until the platform biometric prompt succeeds.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthRestoring();

  /// Reads the saved session and moves to signed-in, biometric lock, or signed-out.
  Future<void> restore() async {
    if (state is AuthSubmitting || state.isAuthenticated) {
      return;
    }

    state = const AuthRestoring();
    final result = await ref.read(restoreAuthSessionUseCaseProvider)();
    if (!ref.mounted) return;

    switch (result) {
      case Failure(:final failure):
        state = AuthUnauthenticated(errorMessage: failure.message);
      case Success(:final data) when data == null:
        state = const AuthUnauthenticated();
      case Success(:final data):
        await _restoreExistingSession(data!);
    }
  }

  /// Attempts sign-in. A mismatch stays on the login screen with [AuthUnauthenticated.errorMessage].
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    if (state is AuthSubmitting || state.isAuthenticated) {
      return;
    }

    state = const AuthSubmitting();
    final result = await ref.read(signInUseCaseProvider)(
      username: username,
      password: password,
    );
    if (!ref.mounted) return;

    switch (result) {
      case Success(:final data):
        state = await _sessionAfterPassword(data);
      case Failure(:final failure):
        final canRetry = await _biometricRetryAvailable();
        if (!ref.mounted) return;
        state = AuthUnauthenticated(
          errorMessage: failure.message,
          canRetryBiometric: canRetry,
        );
    }
  }

  /// Asks the platform for biometrics, then restores the saved session.
  Future<void> unlockWithBiometrics() async {
    final current = state;
    final allowed =
        current is AuthBiometricLocked ||
        (current is AuthUnauthenticated && current.canRetryBiometric);
    if (!allowed) return;
    if (current is AuthBiometricLocked && current.isPrompting) return;

    state = const AuthBiometricLocked(isPrompting: true);
    final preference = await ref
        .read(authRepositoryProvider)
        .readBiometricUnlock();
    if (!ref.mounted) return;
    if (preference case Failure(:final failure)) {
      state = AuthUnauthenticated(errorMessage: failure.message);
      return;
    }
    final stored = preference.dataOrNull ?? BiometricUnlockPreference.disabled;
    if (!stored.enabled) {
      state = const AuthUnauthenticated(errorMessage: AuthCopy.unavailable);
      return;
    }

    final continuity = await ref
        .read(biometricEnrollmentGuardProvider)
        .check(stored.enrollmentToken);
    if (!ref.mounted) return;
    if (continuity == EnrollmentContinuity.changed) {
      await _invalidateBiometricSession();
      if (!ref.mounted) return;
      state = const AuthUnauthenticated(
        errorMessage: AuthCopy.enrollmentChanged,
      );
      return;
    }

    final result = await ref
        .read(biometricAuthenticatorProvider)
        .authenticate(localizedReason: AuthCopy.unlockReason);
    if (!ref.mounted) return;
    await _applyUnlockResult(result);
  }

  /// Leaves the biometric screen for the username and password form.
  ///
  /// The stored session and biometric preference stay, so a later launch can
  /// prompt again.
  void usePasswordInstead() {
    final current = state;
    if (current is! AuthBiometricLocked &&
        !(current is AuthUnauthenticated && current.canRetryBiometric)) {
      return;
    }
    state = const AuthUnauthenticated(canRetryBiometric: true);
  }

  /// Confirms biometrics and arms unlock for later launches.
  ///
  /// Returns false when the prompt is cancelled, enrollment cannot be bound
  /// safely, or the preference cannot be saved. The in-memory session stays.
  Future<bool> enableBiometricUnlock() async {
    final current = state;
    if (current is! AuthAuthenticated) return false;

    final capability = await ref
        .read(biometricAuthenticatorProvider)
        .capability();
    if (!ref.mounted) return false;
    if (!capability.canAuthenticate) {
      state = AuthAuthenticated(current.session);
      return false;
    }

    final result = await ref
        .read(biometricAuthenticatorProvider)
        .authenticate(localizedReason: AuthCopy.enableReason);
    if (!ref.mounted) return false;
    if (!result.isSuccess) {
      state = AuthAuthenticated(current.session);
      return false;
    }

    final guard = ref.read(biometricEnrollmentGuardProvider);
    final token = await guard.bind();
    if (!ref.mounted) return false;
    final continuity = await guard.check(token);
    if (!ref.mounted) return false;
    if (continuity == EnrollmentContinuity.changed ||
        continuity == EnrollmentContinuity.unavailable) {
      await guard.clear();
      state = AuthAuthenticated(current.session);
      return false;
    }

    final saved = await ref
        .read(authRepositoryProvider)
        .enableBiometricUnlock(enrollmentToken: token);
    if (!ref.mounted) return false;
    state = AuthAuthenticated(current.session);
    return saved.isSuccess;
  }

  /// Turns biometric unlock off. The current session remains signed in.
  Future<bool> disableBiometricUnlock() async {
    final current = state;
    if (current is! AuthAuthenticated) return false;
    final saved = await ref
        .read(authRepositoryProvider)
        .disableBiometricUnlock();
    await ref.read(biometricEnrollmentGuardProvider).clear();
    if (!ref.mounted) return false;
    state = AuthAuthenticated(current.session);
    return saved.isSuccess;
  }

  /// Remembers that the user does not want the post-sign-in biometric offer.
  Future<void> dismissBiometricOffer() async {
    final current = state;
    if (current is AuthAuthenticated) {
      state = AuthAuthenticated(current.session);
    }
    await ref.read(authRepositoryProvider).dismissBiometricOffer();
  }

  /// Deletes the session and biometric preference so the next launch needs
  /// the password.
  Future<bool> signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    await ref.read(biometricEnrollmentGuardProvider).clear();
    if (!ref.mounted) return false;
    if (result.isFailure) return false;
    state = const AuthUnauthenticated();
    return true;
  }

  /// Clears a visible sign-in error after the user edits a field.
  void clearError() {
    final current = state;
    if (current is AuthUnauthenticated && current.errorMessage != null) {
      state = AuthUnauthenticated(canRetryBiometric: current.canRetryBiometric);
    }
  }

  Future<void> _restoreExistingSession(AuthSession session) async {
    final preference = await ref
        .read(authRepositoryProvider)
        .readBiometricUnlock();
    if (!ref.mounted) return;
    if (preference case Failure(:final failure)) {
      // Fail closed: a stored token must not skip the gate when we cannot
      // tell whether biometric unlock is required.
      state = AuthUnauthenticated(errorMessage: failure.message);
      return;
    }
    final stored = preference.dataOrNull ?? BiometricUnlockPreference.disabled;
    if (!stored.enabled) {
      state = AuthAuthenticated(session);
      return;
    }

    final continuity = await ref
        .read(biometricEnrollmentGuardProvider)
        .check(stored.enrollmentToken);
    if (!ref.mounted) return;
    if (continuity == EnrollmentContinuity.changed) {
      await _invalidateBiometricSession();
      if (!ref.mounted) return;
      state = const AuthUnauthenticated(
        errorMessage: AuthCopy.enrollmentChanged,
      );
      return;
    }

    final capability = await ref
        .read(biometricAuthenticatorProvider)
        .capability();
    if (!ref.mounted) return;
    if (!capability.canAuthenticate) {
      state = const AuthUnauthenticated(errorMessage: AuthCopy.unavailable);
      return;
    }

    state = const AuthBiometricLocked();
  }

  Future<AuthState> _sessionAfterPassword(AuthSession session) async {
    final preference = await ref
        .read(authRepositoryProvider)
        .readBiometricUnlock();
    final capability = await ref
        .read(biometricAuthenticatorProvider)
        .capability();
    if (!ref.mounted) return AuthAuthenticated(session);
    final stored = preference.dataOrNull;
    final offer =
        stored != null &&
        capability.canAuthenticate &&
        !stored.enabled &&
        !stored.offerDismissed;
    return AuthAuthenticated(session, offerBiometricSetup: offer);
  }

  Future<void> _applyUnlockResult(BiometricUnlockResult result) async {
    switch (result.status) {
      case BiometricUnlockStatus.success:
        final restored = await ref.read(restoreAuthSessionUseCaseProvider)();
        if (!ref.mounted) return;
        state = switch (restored) {
          Success(:final data) when data != null => AuthAuthenticated(data),
          Success() => const AuthUnauthenticated(),
          Failure(:final failure) => AuthUnauthenticated(
            errorMessage: failure.message,
          ),
        };
      case BiometricUnlockStatus.cancelled:
        state = const AuthUnauthenticated(
          errorMessage: AuthCopy.cancelled,
          canRetryBiometric: true,
        );
      case BiometricUnlockStatus.failed:
        state = const AuthUnauthenticated(
          errorMessage: AuthCopy.failed,
          canRetryBiometric: true,
        );
      case BiometricUnlockStatus.lockout:
        state = const AuthUnauthenticated(
          errorMessage: AuthCopy.lockout,
          canRetryBiometric: true,
        );
      case BiometricUnlockStatus.enrollmentChanged:
        await _invalidateBiometricSession();
        if (!ref.mounted) return;
        state = const AuthUnauthenticated(
          errorMessage: AuthCopy.enrollmentChanged,
        );
      case BiometricUnlockStatus.unavailable:
        state = const AuthUnauthenticated(errorMessage: AuthCopy.unavailable);
    }
  }

  Future<void> _invalidateBiometricSession() async {
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(biometricEnrollmentGuardProvider).clear();
  }

  Future<bool> _biometricRetryAvailable() async {
    final preference = await ref
        .read(authRepositoryProvider)
        .readBiometricUnlock();
    final capability = await ref
        .read(biometricAuthenticatorProvider)
        .capability();
    final stored = preference.dataOrNull;
    return stored != null && stored.enabled && capability.canAuthenticate;
  }
}
