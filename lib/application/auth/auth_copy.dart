/// User-facing copy for the local sign-in and biometric unlock gate.
abstract final class AuthCopy {
  static const unlockReason = 'Unlock Keeva with your fingerprint or face.';

  static const enableReason =
      'Confirm your fingerprint or face to turn on biometric unlock.';

  static const cancelled =
      'Biometric unlock was cancelled. Sign in with your password.';

  static const failed =
      'Biometric unlock did not succeed. Sign in with your password.';

  static const unavailable =
      'Biometric unlock is unavailable. Sign in with your password.';

  static const enrollmentChanged =
      'Biometrics on this device changed. Sign in with your password.';

  static const lockout =
      'Biometric unlock is temporarily locked. Sign in with your password.';

  static const enableFailed = 'Biometric unlock was not turned on.';

  static const signOutFailed = 'Could not sign out on this device. Try again.';
}
