import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/data/auth/local_credential_checker.dart';
import 'package:whatsapp_status_saver/data/auth/session_store.dart';
import 'package:whatsapp_status_saver/data/repositories/auth_repository_impl.dart';
import 'package:whatsapp_status_saver/domain/entities/auth_session.dart';

import '../../support/fake_session_store.dart';

void main() {
  const password = 'mr-nishanth';
  late FakeSessionStore store;
  late AuthRepositoryImpl repository;

  setUp(() {
    store = FakeSessionStore();
    repository = AuthRepositoryImpl(store, random: Random(7));
  });

  group('AuthRepositoryImpl', () {
    test('signIn persists a random token and credentials version', () async {
      final result = await repository.signIn(
        username: 'nishanth',
        password: password,
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.dataOrNull,
        const AuthSession(username: LocalCredentialChecker.accountUsername),
      );
      expect(store.values, contains(AuthRepositoryImpl.sessionTokenKey));
      expect(store.values, contains(AuthRepositoryImpl.credentialsVersionKey));
      expect(
        store.values[AuthRepositoryImpl.credentialsVersionKey],
        LocalCredentialChecker.credentialsVersionHex,
      );
      expect(store.values[AuthRepositoryImpl.sessionTokenKey], hasLength(64));
      expect(
        store.values.values.any((value) => value.contains(password)),
        isFalse,
      );

      final firstToken = store.values[AuthRepositoryImpl.sessionTokenKey];
      final again = AuthRepositoryImpl(store, random: Random(8));
      await again.signIn(username: 'nishanth', password: password);
      expect(
        store.values[AuthRepositoryImpl.sessionTokenKey],
        isNot(firstToken),
      );
    });

    test('signIn trims the username and not the password', () async {
      final trimmedUser = await repository.signIn(
        username: '  nishanth  ',
        password: password,
      );
      expect(trimmedUser.isSuccess, isTrue);

      store.values.clear();
      final paddedPassword = await repository.signIn(
        username: 'nishanth',
        password: ' $password ',
      );
      expect(paddedPassword.isFailure, isTrue);
      expect(paddedPassword.failureOrNull, isA<InvalidCredentialsFailure>());
      expect(store.values, isEmpty);
    });

    test('signIn rejects incorrect credentials without writing', () async {
      final result = await repository.signIn(
        username: 'nishanth',
        password: 'not-the-password',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidCredentialsFailure>());
      expect(
        result.failureOrNull?.message,
        'That username or password is incorrect.',
      );
      expect(store.values, isEmpty);
    });

    test('signIn rejects empty fields without writing', () async {
      final result = await repository.signIn(username: '   ', password: '');

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.message,
        'Enter your username and password.',
      );
      expect(store.values, isEmpty);
    });

    test('readSession returns null when nothing is stored', () async {
      final result = await repository.readSession();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test(
      'readSession returns the session after a successful sign-in',
      () async {
        await repository.signIn(username: 'nishanth', password: password);

        final result = await repository.readSession();

        expect(result.dataOrNull, const AuthSession(username: 'nishanth'));
      },
    );

    test(
      'readSession drops a credentials version that no longer matches',
      () async {
        store.values[AuthRepositoryImpl.sessionTokenKey] = 'ab' * 32;
        store.values[AuthRepositoryImpl.credentialsVersionKey] = 'stale-marker';

        final result = await repository.readSession();

        expect(result.dataOrNull, isNull);
        expect(store.values, isEmpty);
      },
    );

    test(
      'readSession drops a session whose token is not high entropy',
      () async {
        store.values[AuthRepositoryImpl.sessionTokenKey] = 'short';
        store.values[AuthRepositoryImpl.credentialsVersionKey] =
            LocalCredentialChecker.credentialsVersionHex;

        final result = await repository.readSession();

        expect(result.dataOrNull, isNull);
        expect(store.values, isEmpty);
      },
    );

    test('signIn stays signed out when the store cannot persist', () async {
      store.failWrites = true;

      final result = await repository.signIn(
        username: 'nishanth',
        password: password,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthPersistenceFailure>());
      expect(store.values, isEmpty);
    });

    test('a failed second write does not leave a partial session', () async {
      final partial = _FailSecondWriteStore();
      final signingIn = AuthRepositoryImpl(partial, random: Random(1));

      final result = await signingIn.signIn(
        username: 'nishanth',
        password: password,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthPersistenceFailure>());
      expect(partial.values, isEmpty);
    });

    test('readSession reports a storage failure', () async {
      store.failReads = true;

      final result = await repository.readSession();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthPersistenceFailure>());
    });
  });
}

class _FailSecondWriteStore implements SessionStore {
  final Map<String, String> values = {};
  int _writes = 0;

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _writes++;
    if (_writes > 1) {
      throw StateError('second write failed');
    }
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}
