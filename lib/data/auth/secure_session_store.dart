import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_store.dart';

/// Session store backed by the platform secure store.
///
/// Android uses the Keystore: RSA-OAEP wraps the key and AES-GCM encrypts
/// the value. `flutter_secure_storage` 11 removed `encryptedSharedPreferences`;
/// these cipher options are the supported replacement and are not plain
/// SharedPreferences. iOS and macOS use the Keychain with
/// `first_unlock_this_device`, so the item stays on this device and is
/// unavailable until the first unlock after boot. iCloud sync is off.
/// Nothing written here leaves the device.
final class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? defaultStorage;

  /// Hardened platform options used in production.
  static const FlutterSecureStorage defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
      migrateOnAlgorithmChange: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

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
