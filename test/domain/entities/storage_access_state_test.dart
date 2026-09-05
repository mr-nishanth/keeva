import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/domain/entities/storage_access_state.dart';

void main() {
  group('StorageAccessState', () {
    test('StorageAccessInitial properties', () {
      const state = StorageAccessInitial();
      expect(state.isGranted, isFalse);
      expect(state.isNotGranted, isFalse);
      expect(state.isRevoked, isFalse);
      expect(state.isInvalid, isFalse);
      expect(state.isUnavailable, isFalse);
      expect(state, equals(const StorageAccessInitial()));
    });

    test('StorageAccessGranted properties', () {
      const state = StorageAccessGranted(targetPackage: 'com.whatsapp.w4b');
      expect(state.isGranted, isTrue);
      expect(state.targetPackage, equals('com.whatsapp.w4b'));
      expect(
        state,
        equals(const StorageAccessGranted(targetPackage: 'com.whatsapp.w4b')),
      );
      expect(
        state,
        isNot(
          equals(const StorageAccessGranted(targetPackage: 'com.whatsapp')),
        ),
      );
    });

    test('StorageAccessNotGranted properties', () {
      const state = StorageAccessNotGranted();
      expect(state.isGranted, isFalse);
      expect(state.isNotGranted, isTrue);
      expect(state, equals(const StorageAccessNotGranted()));
    });

    test('StorageAccessRevoked properties', () {
      const state = StorageAccessRevoked(
        reason: 'Permission was revoked by user',
      );
      expect(state.isRevoked, isTrue);
      expect(state.reason, equals('Permission was revoked by user'));
      expect(
        state,
        equals(
          const StorageAccessRevoked(reason: 'Permission was revoked by user'),
        ),
      );
    });

    test('StorageAccessInvalid properties', () {
      const state = StorageAccessInvalid(reason: 'Wrong folder selected');
      expect(state.isInvalid, isTrue);
      expect(state.reason, equals('Wrong folder selected'));
    });

    test('StorageAccessUnavailable properties', () {
      const state = StorageAccessUnavailable(reason: 'WhatsApp not installed');
      expect(state.isUnavailable, isTrue);
      expect(state.reason, equals('WhatsApp not installed'));
    });
  });
}
