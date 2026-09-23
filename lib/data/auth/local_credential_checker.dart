/// Checks the single on-device account accepted by Keeva.
///
/// The password is compared in memory and is never written to storage.
/// [sessionMarker] changes when the accepted credentials change, so a
/// previously saved session stops unlocking the app.
final class LocalCredentialChecker {
  const LocalCredentialChecker();

  static const String accountUsername = 'nishanth';
  static const String accountPassword = 'mr-nishanth';

  /// Opaque marker stored after a successful sign-in.
  ///
  /// This is a fingerprint of the accepted credentials, not the password.
  String get sessionMarker =>
      _fingerprint('$accountUsername\u0000$accountPassword');

  bool matches({required String username, required String password}) {
    final usernameMatches = _fixedTimeEquals(username, accountUsername);
    final passwordMatches = _fixedTimeEquals(password, accountPassword);
    return usernameMatches && passwordMatches;
  }

  bool isCurrentSessionMarker(String? marker) {
    if (marker == null) return false;
    return _fixedTimeEquals(marker, sessionMarker);
  }

  static bool _fixedTimeEquals(String left, String right) {
    final leftUnits = left.codeUnits;
    final rightUnits = right.codeUnits;
    var difference = leftUnits.length ^ rightUnits.length;
    final length = leftUnits.length > rightUnits.length
        ? leftUnits.length
        : rightUnits.length;
    for (var index = 0; index < length; index++) {
      final leftUnit = index < leftUnits.length ? leftUnits[index] : 0;
      final rightUnit = index < rightUnits.length ? rightUnits[index] : 0;
      difference |= leftUnit ^ rightUnit;
    }
    return difference == 0;
  }

  static String _fingerprint(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return 'fnv1a32:${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
