import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/data/auth/local_credential_checker.dart';

void main() {
  const checker = LocalCredentialChecker();
  const password = 'mr-nishanth';

  group('LocalCredentialChecker', () {
    test('accepts the product username and password', () {
      expect(checker.matches(username: 'nishanth', password: password), isTrue);
    });

    test('password digest is SHA-256 of the app salt and password', () {
      final digest = sha256.convert(
        utf8.encode('${LocalCredentialChecker.passwordSalt}$password'),
      );

      expect(LocalCredentialChecker.passwordDigestHex, digest.toString());
      expect(
        LocalCredentialChecker.passwordDigestHex,
        isNot(contains(password)),
      );
    });

    test(
      'credentials version is a SHA-256 of salt, username, and password',
      () {
        final digest = sha256.convert(
          utf8.encode(
            '${LocalCredentialChecker.credentialsVersionSalt}'
            '\u0000${LocalCredentialChecker.accountUsername}'
            '\u0000$password',
          ),
        );

        expect(LocalCredentialChecker.credentialsVersionHex, digest.toString());
        expect(
          LocalCredentialChecker.credentialsVersionHex,
          isNot(contains(password)),
        );
        expect(
          checker.isCurrentCredentialsVersion(
            LocalCredentialChecker.credentialsVersionHex,
          ),
          isTrue,
        );
        expect(checker.isCurrentCredentialsVersion('other'), isFalse);
        expect(checker.isCurrentCredentialsVersion(null), isFalse);
      },
    );

    test('rejects a wrong password', () {
      expect(checker.matches(username: 'nishanth', password: 'wrong'), isFalse);
    });

    test('rejects a wrong username', () {
      expect(checker.matches(username: 'other', password: password), isFalse);
    });

    test('is case sensitive', () {
      expect(
        checker.matches(username: 'Nishanth', password: password),
        isFalse,
      );
      expect(
        checker.matches(username: 'nishanth', password: 'Mr-nishanth'),
        isFalse,
      );
    });

    test('does not treat surrounding password whitespace as the password', () {
      expect(
        checker.matches(username: 'nishanth', password: ' $password '),
        isFalse,
      );
    });
  });
}
