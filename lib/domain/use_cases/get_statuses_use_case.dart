import '../../core/constants/app_constants.dart';
import '../../core/result/result.dart';
import '../entities/status_item.dart';
import '../repositories/status_repository.dart';

/// Discovers and returns all available WhatsApp status items.
final class GetStatusesUseCase {
  final StatusRepository _repository;

  const GetStatusesUseCase(this._repository);

  Future<Result<List<StatusItem>>> call({
    String targetPackage = AppConstants.whatsappStandardPackage,
  }) {
    return _repository.getStatuses(targetPackage: targetPackage);
  }
}
