import '../../core/constants/app_constants.dart';
import '../../core/result/result.dart';
import '../repositories/status_repository.dart';

/// Generates or retrieves a cached native thumbnail path for a status item.
final class GetThumbnailUseCase {
  final StatusRepository _repository;

  const GetThumbnailUseCase(this._repository);

  Future<Result<String>> call({
    required String id,
    bool isVideo = false,
    int width = AppConstants.defaultThumbnailDimension,
    int height = AppConstants.defaultThumbnailDimension,
  }) {
    return _repository.getThumbnail(
      id: id,
      isVideo: isVideo,
      width: width,
      height: height,
    );
  }
}
