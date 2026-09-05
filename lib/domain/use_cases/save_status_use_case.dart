import '../../core/result/result.dart';
import '../entities/saved_media.dart';
import '../repositories/status_repository.dart';

/// Saves a WhatsApp status item into the device's public media gallery.
final class SaveStatusUseCase {
  final StatusRepository _repository;

  const SaveStatusUseCase(this._repository);

  Future<Result<SavedMedia>> call({
    required String id,
    String? displayName,
    String? mimeType,
    bool? isVideo,
  }) {
    return _repository.saveStatus(
      id: id,
      displayName: displayName,
      mimeType: mimeType,
      isVideo: isVideo,
    );
  }
}
