import '../../core/constants/app_constants.dart';
import '../../core/result/result.dart';
import '../entities/storage_access_state.dart';
import '../repositories/status_repository.dart';

/// Checks whether storage access to the target WhatsApp status directory is granted.
final class CheckStorageAccessUseCase {
  final StatusRepository _repository;

  const CheckStorageAccessUseCase(this._repository);

  Future<Result<StorageAccessState>> call({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _repository.checkAccess(targetPackage: targetPackage);
  }
}
