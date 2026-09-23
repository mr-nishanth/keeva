import 'package:whatsapp_status_saver/data/auth/session_store.dart';

/// In-memory [SessionStore] for auth tests.
class FakeSessionStore implements SessionStore {
  final Map<String, String> values = {};

  bool failReads = false;
  bool failWrites = false;

  @override
  Future<String?> read({required String key}) async {
    if (failReads) {
      throw StateError('read failed');
    }
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    if (failWrites) {
      throw StateError('write failed');
    }
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}
