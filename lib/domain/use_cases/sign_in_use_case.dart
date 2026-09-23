import '../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Signs in with the local account and persists the session on success.
final class SignInUseCase {
  final AuthRepository _repository;

  const SignInUseCase(this._repository);

  Future<Result<AuthSession>> call({
    required String username,
    required String password,
  }) {
    return _repository.signIn(username: username, password: password);
  }
}
