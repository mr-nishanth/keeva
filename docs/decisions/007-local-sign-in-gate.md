# ADR 007: Local sign-in gate

## Context
Keeva is local-first. Moments, Kept, and Settings were reachable as soon as the process started, with storage onboarding as the only gate. The product now requires a sign-in before any of that flow.

The accepted account is a single on-device username and password. There is no remote account service, and the Android manifest does not request network access.

## Decision
Gate `KeevaApp` on a local session:

1. Cold start reads a session marker from the platform secure store (`flutter_secure_storage`: Android Keystore-backed cipher, iOS Keychain).
2. If the marker matches the current credentials, onboarding and the main shell proceed as before.
3. Otherwise the login screen stays up. A mismatch shows an error and does not navigate.
4. A successful sign-in writes only a credential fingerprint, never the password.
5. Changing the accepted credentials changes the fingerprint, so an older saved session no longer unlocks the app.

Plain SharedPreferences is not used for this value. Media metadata storage remains as decided in ADR 003; this session is a secret and stays in the secure store.

## Status
Accepted.

## Consequences
- **Positive:** The rest of the app is unreachable until sign-in. The session survives process restart without leaving the device. Tests override `sessionStoreProvider` and never touch the platform store.
- **Negative:** The accepted password lives in the app binary, which matches the requested local account. Secure storage protects the session marker, not the constant itself.
