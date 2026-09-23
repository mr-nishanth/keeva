import '../../domain/entities/auth_session.dart';

/// Sign-in state observed by the app gate.
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;

  bool get isRestoring => this is AuthRestoring;

  bool get isSubmitting => this is AuthSubmitting;

  /// Password login can offer another biometric attempt.
  bool get canRetryBiometric => false;

  String? get errorMessage => null;
}

/// The saved session has not been read yet.
final class AuthRestoring extends AuthState {
  const AuthRestoring();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthRestoring && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthRestoring()';
}

/// No restored session is active. [errorMessage] is set after a failed attempt.
///
/// [canRetryBiometric] stays true when a session is still stored and biometric
/// unlock remains armed, so the password form can try biometrics again.
final class AuthUnauthenticated extends AuthState {
  @override
  final String? errorMessage;

  @override
  final bool canRetryBiometric;

  const AuthUnauthenticated({
    this.errorMessage,
    this.canRetryBiometric = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthUnauthenticated &&
          other.runtimeType == runtimeType &&
          other.errorMessage == errorMessage &&
          other.canRetryBiometric == canRetryBiometric);

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage, canRetryBiometric);

  @override
  String toString() =>
      'AuthUnauthenticated(errorMessage: $errorMessage, canRetryBiometric: $canRetryBiometric)';
}

/// A saved session exists, but it is not restored until biometrics succeed.
final class AuthBiometricLocked extends AuthState {
  final bool isPrompting;

  @override
  final String? errorMessage;

  const AuthBiometricLocked({this.isPrompting = false, this.errorMessage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthBiometricLocked &&
          other.runtimeType == runtimeType &&
          other.isPrompting == isPrompting &&
          other.errorMessage == errorMessage);

  @override
  int get hashCode => Object.hash(runtimeType, isPrompting, errorMessage);

  @override
  String toString() =>
      'AuthBiometricLocked(isPrompting: $isPrompting, errorMessage: $errorMessage)';
}

/// A sign-in attempt is in progress. The login screen stays visible.
final class AuthSubmitting extends AuthState {
  const AuthSubmitting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthSubmitting && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthSubmitting()';
}

/// A valid local session is active.
///
/// [offerBiometricSetup] is true only immediately after a password sign-in
/// when biometrics are available and the user has not already chosen.
final class AuthAuthenticated extends AuthState {
  final AuthSession session;
  final bool offerBiometricSetup;

  const AuthAuthenticated(this.session, {this.offerBiometricSetup = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthAuthenticated &&
          other.runtimeType == runtimeType &&
          other.session == session &&
          other.offerBiometricSetup == offerBiometricSetup);

  @override
  int get hashCode => Object.hash(runtimeType, session, offerBiometricSetup);

  @override
  String toString() =>
      'AuthAuthenticated($session, offerBiometricSetup: $offerBiometricSetup)';
}
