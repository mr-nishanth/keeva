import '../../core/result/result.dart';
import '../repositories/status_repository.dart';

/// Prepares a video status item for hardware-accelerated playback with seek support.
final class PrepareVideoPlaybackUseCase {
  final StatusRepository _repository;

  const PrepareVideoPlaybackUseCase(this._repository);

  Future<Result<String>> call({required String id, int sizeBytes = 0}) {
    return _repository.prepareVideo(id: id, sizeBytes: sizeBytes);
  }
}
