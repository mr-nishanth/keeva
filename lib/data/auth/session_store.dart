/// Narrow key-value store for the local sign-in session.
///
/// Production uses [SecureSessionStore]. Tests supply an in-memory fake.
abstract interface class SessionStore {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}
