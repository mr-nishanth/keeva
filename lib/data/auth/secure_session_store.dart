import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_store.dart';

/// Session store backed by the platform secure store.
///
/// Android keeps values in the Keystore-wrapped cipher provided by
/// `flutter_secure_storage`, not in plain SharedPreferences. iOS uses the
/// Keychain. Nothing written here leaves the device.
final class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }
}
