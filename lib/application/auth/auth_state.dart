import '../../domain/entities/auth_session.dart';

/// Sign-in state observed by the app gate.
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;

  bool get isRestoring => this is AuthRestoring;

  bool get isSubmitting => this is AuthSubmitting;

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

/// No valid session is stored. [errorMessage] is set after a failed attempt.
final class AuthUnauthenticated extends AuthState {
  @override
  final String? errorMessage;

  const AuthUnauthenticated({this.errorMessage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthUnauthenticated &&
          other.runtimeType == runtimeType &&
          other.errorMessage == errorMessage);

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage);

  @override
  String toString() => 'AuthUnauthenticated(errorMessage: $errorMessage)';
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
final class AuthAuthenticated extends AuthState {
  final AuthSession session;

  const AuthAuthenticated(this.session);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthAuthenticated &&
          other.runtimeType == runtimeType &&
          other.session == session);

  @override
  int get hashCode => Object.hash(runtimeType, session);

  @override
  String toString() => 'AuthAuthenticated($session)';
}
