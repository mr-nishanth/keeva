import '../../core/result/result.dart';
import '../entities/saved_media.dart';

/// Domain contract for managing saved media records.
///
/// Kept minimal for Phase 2C. Persistent implementation (via Drift/SQLite)
/// will be implemented in Phase 2I.
abstract interface class SavedMediaRepository {
  /// Retrieves all previously saved media records.
  Future<Result<List<SavedMedia>>> getSavedMedia();

  /// Records a newly saved media item.
  Future<Result<void>> recordSavedMedia(SavedMedia media);

  /// Checks if a status with the given opaque [id] has already been saved.
  Future<Result<bool>> isStatusSaved(String id);
}
