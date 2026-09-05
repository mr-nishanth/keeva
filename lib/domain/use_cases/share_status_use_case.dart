import '../../core/result/result.dart';
import '../repositories/status_repository.dart';

/// Shares a WhatsApp status item via the native platform share sheet.
final class ShareStatusUseCase {
  final StatusRepository _repository;

  const ShareStatusUseCase(this._repository);

  Future<Result<bool>> call({
    required String id,
    String? displayName,
    String? mimeType,
    bool isVideo = false,
  }) {
    return _repository.shareStatus(
      id: id,
      displayName: displayName,
      mimeType: mimeType,
      isVideo: isVideo,
    );
  }
}
