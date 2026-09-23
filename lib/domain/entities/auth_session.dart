/// An on-device sign-in session for the local Keeva account.
///
/// Holds only the account name. The password is never part of the session.
final class AuthSession {
  final String username;

  const AuthSession({required this.username});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthSession &&
          other.runtimeType == runtimeType &&
          other.username == username);

  @override
  int get hashCode => Object.hash(runtimeType, username);

  @override
  String toString() => 'AuthSession(username: $username)';
}
