import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/data/auth/secure_session_store.dart';

void main() {
  group('SecureSessionStore', () {
    test('uses Keystore ciphers and this-device keychain accessibility', () {
      final android = SecureSessionStore.defaultStorage.aOptions.toMap();
      final ios = SecureSessionStore.defaultStorage.iOptions.toMap();
      final macos = SecureSessionStore.defaultStorage.mOptions.toMap();

      expect(
        android['keyCipherAlgorithm'],
        'RSA_ECB_OAEPwithSHA_256andMGF1Padding',
      );
      expect(android['storageCipherAlgorithm'], 'AES_GCM_NoPadding');
      expect(android['resetOnError'], 'true');
      expect(
        ios['accessibility'],
        KeychainAccessibility.first_unlock_this_device.name,
      );
      expect(ios['synchronizable'], 'false');
      expect(
        macos['accessibility'],
        KeychainAccessibility.first_unlock_this_device.name,
      );
      expect(macos['synchronizable'], 'false');
    });
  });
}
