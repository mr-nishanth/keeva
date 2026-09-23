import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/data/auth/local_credential_checker.dart';

void main() {
  const checker = LocalCredentialChecker();

  group('LocalCredentialChecker', () {
    test('accepts the product username and password', () {
      expect(
        checker.matches(username: 'nishanth', password: 'mr-nishanth'),
        isTrue,
      );
    });

    test('rejects a wrong password', () {
      expect(checker.matches(username: 'nishanth', password: 'wrong'), isFalse);
    });

    test('rejects a wrong username', () {
      expect(
        checker.matches(username: 'other', password: 'mr-nishanth'),
        isFalse,
      );
    });

    test('is case sensitive', () {
      expect(
        checker.matches(username: 'Nishanth', password: 'mr-nishanth'),
        isFalse,
      );
      expect(
        checker.matches(username: 'nishanth', password: 'Mr-nishanth'),
        isFalse,
      );
    });

    test('session marker does not contain the password', () {
      expect(checker.sessionMarker, isNot(contains('mr-nishanth')));
      expect(checker.sessionMarker, isNot(contains('nishanth')));
      expect(checker.isCurrentSessionMarker(checker.sessionMarker), isTrue);
      expect(checker.isCurrentSessionMarker('other'), isFalse);
      expect(checker.isCurrentSessionMarker(null), isFalse);
    });
  });
}
