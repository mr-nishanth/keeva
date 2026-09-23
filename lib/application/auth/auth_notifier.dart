import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../providers.dart';
import 'auth_state.dart';

/// Restores and creates the local sign-in session.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthRestoring();

  /// Reads the saved session and moves to signed-in or signed-out.
  Future<void> restore() async {
    if (state is AuthSubmitting || state.isAuthenticated) {
      return;
    }

    state = const AuthRestoring();
    final result = await ref.read(restoreAuthSessionUseCaseProvider)();
    if (!ref.mounted) return;

    state = switch (result) {
      Success(:final data) when data != null => AuthAuthenticated(data),
      Success() => const AuthUnauthenticated(),
      Failure(:final failure) => AuthUnauthenticated(
        errorMessage: failure.message,
      ),
    };
  }

  /// Attempts sign-in. A mismatch stays on the login screen with [AuthUnauthenticated.errorMessage].
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    if (state is AuthSubmitting || state.isAuthenticated) {
      return;
    }

    state = const AuthSubmitting();
    final result = await ref.read(signInUseCaseProvider)(
      username: username,
      password: password,
    );
    if (!ref.mounted) return;

    state = switch (result) {
      Success(:final data) => AuthAuthenticated(data),
      Failure(:final failure) => AuthUnauthenticated(
        errorMessage: failure.message,
      ),
    };
  }

  /// Clears a visible sign-in error after the user edits a field.
  void clearError() {
    final current = state;
    if (current is AuthUnauthenticated && current.errorMessage != null) {
      state = const AuthUnauthenticated();
    }
  }
}
