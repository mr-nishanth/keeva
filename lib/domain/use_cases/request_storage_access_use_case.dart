import '../../core/constants/app_constants.dart';
import '../../core/result/result.dart';
import '../entities/storage_access_state.dart';
import '../repositories/status_repository.dart';

/// Prompts the user via the system SAF picker to grant access to the target WhatsApp status folder.
final class RequestStorageAccessUseCase {
  final StatusRepository _repository;

  const RequestStorageAccessUseCase(this._repository);

  Future<Result<StorageAccessState>> call({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _repository.requestAccess(targetPackage: targetPackage);
  }
}
