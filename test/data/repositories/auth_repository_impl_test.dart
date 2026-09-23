import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/core/errors/app_failure.dart';
import 'package:whatsapp_status_saver/data/auth/local_credential_checker.dart';
import 'package:whatsapp_status_saver/data/repositories/auth_repository_impl.dart';
import 'package:whatsapp_status_saver/domain/entities/auth_session.dart';

import '../../support/fake_session_store.dart';

void main() {
  late FakeSessionStore store;
  late AuthRepositoryImpl repository;

  setUp(() {
    store = FakeSessionStore();
    repository = AuthRepositoryImpl(store);
  });

  group('AuthRepositoryImpl', () {
    test('signIn persists a session marker and not the password', () async {
      final result = await repository.signIn(
        username: 'nishanth',
        password: 'mr-nishanth',
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.dataOrNull,
        const AuthSession(username: LocalCredentialChecker.accountUsername),
      );
      expect(store.values, contains(AuthRepositoryImpl.sessionMarkerKey));
      expect(
        store.values.values.any((value) => value.contains('mr-nishanth')),
        isFalse,
      );
      expect(
        store.values.values.any((value) => value.contains('nishanth')),
        isFalse,
      );
    });

    test('signIn accepts surrounding whitespace', () async {
      final result = await repository.signIn(
        username: '  nishanth  ',
        password: ' mr-nishanth ',
      );

      expect(result.isSuccess, isTrue);
      final restored = await repository.readSession();
      expect(restored.dataOrNull?.username, 'nishanth');
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
        await repository.signIn(username: 'nishanth', password: 'mr-nishanth');

        final result = await repository.readSession();

        expect(result.dataOrNull, const AuthSession(username: 'nishanth'));
      },
    );

    test('readSession drops a marker that no longer matches', () async {
      store.values[AuthRepositoryImpl.sessionMarkerKey] = 'stale-marker';

      final result = await repository.readSession();

      expect(result.dataOrNull, isNull);
      expect(store.values, isEmpty);
    });

    test('signIn stays signed out when the store cannot persist', () async {
      store.failWrites = true;

      final result = await repository.signIn(
        username: 'nishanth',
        password: 'mr-nishanth',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthPersistenceFailure>());
      expect(store.values, isEmpty);
    });

    test('readSession reports a storage failure', () async {
      store.failReads = true;

      final result = await repository.readSession();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthPersistenceFailure>());
    });
  });
}
