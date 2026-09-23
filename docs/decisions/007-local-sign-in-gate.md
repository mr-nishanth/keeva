# ADR 007: Local sign-in gate

## Context
Keeva is local-first. Moments, Kept, and Settings were reachable as soon as the process started, with storage onboarding as the only gate. The product now requires a sign-in before any of that flow.

The accepted account is a single on-device username and password. There is no remote account service, and the Android manifest does not request network access.

## Decision
Gate `KeevaApp` on a local session:

1. The accepted password is not embedded as a string. Sign-in hashes the entered password with a fixed app salt and compares the SHA-256 digest to a precomputed digest, in constant time.
2. Cold start reads two values from the platform secure store:
   - a 32-byte random session token created at sign-in
   - a credentials-version digest
3. The session is valid only when the token is well-formed and the stored credentials version still matches the current digest. Changing the accepted account changes that digest, so older sessions stop unlocking the app.
4. Otherwise the login screen stays up. A mismatch shows a generic error and does not navigate.
5. The password is never written to storage. Only the username is trimmed; the password is hashed exactly as entered.

Secure storage is `flutter_secure_storage` 11.2.0, configured explicitly:

- Android: Keystore RSA-OAEP key wrapping and AES-GCM value encryption (`AndroidOptions`, not plain SharedPreferences). Version 11 removed `encryptedSharedPreferences`; those cipher options are the supported replacement.
- iOS and macOS: Keychain accessibility `first_unlock_this_device`, with iCloud sync disabled, so the item stays on this device and is unavailable until the first unlock after boot.

Plain SharedPreferences is not used for the session. Media metadata storage remains as decided in ADR 003.

## Status
Accepted.

## Consequences
- **Positive:** The rest of the app is unreachable until sign-in. The session survives process restart without leaving the device. A credential change invalidates saved sessions. Tests override `sessionStoreProvider` and never touch the platform store.
- **Negative:** This is still a client-side check. Someone who can patch the APK can remove the gate. The digest and salt are in the binary; secure storage protects the session token on the device, not the check itself. No network auth is added.
