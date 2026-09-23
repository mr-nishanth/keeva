import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_status_saver/application/auth/auth_state.dart';
import 'package:whatsapp_status_saver/application/providers.dart';
import 'package:whatsapp_status_saver/domain/entities/auth_session.dart';

import '../../support/fake_session_store.dart';

void main() {
  late FakeSessionStore store;
  late ProviderContainer container;

  setUp(() {
    store = FakeSessionStore();
    container = ProviderContainer(
      overrides: [sessionStoreProvider.overrideWithValue(store)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test(
      'starts restoring and becomes signed out when no session exists',
      () async {
        expect(container.read(authNotifierProvider), isA<AuthRestoring>());

        await container.read(authNotifierProvider.notifier).restore();

        expect(
          container.read(authNotifierProvider),
          isA<AuthUnauthenticated>(),
        );
        expect(container.read(authNotifierProvider).errorMessage, isNull);
      },
    );

    test('incorrect credentials stay signed out with an error', () async {
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signIn(username: 'nishanth', password: 'wrong');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthUnauthenticated>());
      expect(state.errorMessage, 'That username or password is incorrect.');
      expect(store.values, isEmpty);
    });

    test(
      'correct credentials sign in and a new container restores them',
      () async {
        await container
            .read(authNotifierProvider.notifier)
            .signIn(username: 'nishanth', password: 'mr-nishanth');

        expect(
          container.read(authNotifierProvider),
          const AuthAuthenticated(AuthSession(username: 'nishanth')),
        );

        final relaunched = ProviderContainer(
          overrides: [sessionStoreProvider.overrideWith((ref) => store)],
        );
        addTearDown(relaunched.dispose);

        expect(relaunched.read(authNotifierProvider), isA<AuthRestoring>());
        await relaunched.read(authNotifierProvider.notifier).restore();
        expect(
          relaunched.read(authNotifierProvider),
          const AuthAuthenticated(AuthSession(username: 'nishanth')),
        );
      },
    );

    test('a failed write does not authenticate', () async {
      store.failWrites = true;

      await container
          .read(authNotifierProvider.notifier)
          .signIn(username: 'nishanth', password: 'mr-nishanth');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthUnauthenticated>());
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, contains('Could not save'));
    });

    test('restore surfaces a storage failure without signing in', () async {
      store.failReads = true;

      await container.read(authNotifierProvider.notifier).restore();

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthUnauthenticated>());
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, contains('Could not read'));
    });

    test('clearError removes the visible message', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.signIn(username: 'nishanth', password: 'wrong');
      expect(container.read(authNotifierProvider).errorMessage, isNotNull);

      notifier.clearError();

      expect(container.read(authNotifierProvider).errorMessage, isNull);
    });
  });
}
