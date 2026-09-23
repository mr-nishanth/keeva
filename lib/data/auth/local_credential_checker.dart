import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Checks the single on-device account accepted by Keeva.
///
/// The password is not stored. Sign-in compares SHA-256(salt + password)
/// with [passwordDigestHex] using a constant-time byte compare.
/// [credentialsVersionHex] is SHA-256 of [credentialsVersionSalt], the
/// username, and the password, separated by NUL bytes. Replace both digests
/// together when the accepted account changes so saved sessions stop matching.
final class LocalCredentialChecker {
  const LocalCredentialChecker();

  static const String accountUsername = 'nishanth';

  /// App-specific salt mixed into the password digest.
  static const String passwordSalt = 'keeva.local-auth.password.v1';

  /// SHA-256 of [passwordSalt] followed by the accepted password.
  static const String passwordDigestHex =
      '3e3700b589e85d991cbc83b00f6c086f940b84d78647705e448f1d18227542f7';

  /// App-specific salt mixed into the credentials-version digest.
  static const String credentialsVersionSalt =
      'keeva.local-auth.credentials.v1';

  /// SHA-256 of [credentialsVersionSalt], the username, and the password.
  static const String credentialsVersionHex =
      '7c2d2aa2be720c9cbccb18efd37dba339ce214e1c9d4cc6af81ee18e97a5daf0';

  static final Uint8List _passwordDigest = _hexToBytes(passwordDigestHex);

  bool matches({required String username, required String password}) {
    final usernameMatches = _fixedTimeEquals(username, accountUsername);
    final actual = sha256.convert(utf8.encode('$passwordSalt$password')).bytes;
    final passwordMatches = _fixedTimeBytesEquals(actual, _passwordDigest);
    return usernameMatches && passwordMatches;
  }

  bool isCurrentCredentialsVersion(String? stored) {
    if (stored == null) return false;
    return _fixedTimeEquals(stored, credentialsVersionHex);
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

  static bool _fixedTimeBytesEquals(List<int> left, List<int> right) {
    var difference = left.length ^ right.length;
    final length = left.length > right.length ? left.length : right.length;
    for (var index = 0; index < length; index++) {
      final leftByte = index < left.length ? left[index] : 0;
      final rightByte = index < right.length ? right[index] : 0;
      difference |= leftByte ^ rightByte;
    }
    return difference == 0;
  }

  static Uint8List _hexToBytes(String hex) {
    final bytes = Uint8List(hex.length ~/ 2);
    for (var index = 0; index < bytes.length; index++) {
      final start = index * 2;
      bytes[index] = int.parse(hex.substring(start, start + 2), radix: 16);
    }
    return bytes;
  }
}
