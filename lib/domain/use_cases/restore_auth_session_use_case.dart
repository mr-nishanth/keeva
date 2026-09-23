import '../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Loads the previously saved on-device sign-in session, if one is still valid.
final class RestoreAuthSessionUseCase {
  final AuthRepository _repository;

  const RestoreAuthSessionUseCase(this._repository);

  Future<Result<AuthSession?>> call() {
    return _repository.readSession();
  }
}
