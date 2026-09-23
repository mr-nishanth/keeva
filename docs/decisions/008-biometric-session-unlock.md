# ADR 008: Biometric session unlock

## Context

ADR 007 gates Keeva on a local username and password. A successful sign-in stores a random session token and a credentials version in `flutter_secure_storage`. Later launches restore that token and skip the login screen.

Issue #2 asks for biometric unlock after that first password sign-in. The password must remain the fallback. The password must not be stored. Keeva must not implement its own fingerprint or face matching.

## Decision

Biometric unlock is a gate in front of the existing session token. It is not a second credential.

1. The first successful password sign-in may offer biometric unlock, and only when the platform reports enrolled biometrics. Declining the offer is remembered. Settings can turn it on later.
2. Enabling it requires a successful platform biometric prompt, then writes two values to the same hardened secure store used for the session:
   - `keeva.auth.biometric.enabled` = `1`
   - an optional opaque enrollment binding
   The password, password digest, and biometric samples are not written.
3. On a later launch, a valid session token restores the app directly only when biometric unlock is off. When it is on, the app stays locked until `local_auth` reports success (`biometricOnly: true`). Success reads the existing session token. Cancel, failure, and lockout show the username and password form and leave the token in place for the next attempt.
4. If biometrics are missing or not enrolled, the enable control is disabled and the password gate behaves as in ADR 007. A launch that finds biometric unlock armed but unusable does not restore the session; it asks for the password.
5. Enrollment changes invalidate biometric unlock where the platform can observe them:
   - Android stores an Android Keystore AES key created with `setInvalidatedByBiometricEnrollment(true)` and `setUserAuthenticationRequired(true)`. `Cipher.init` returning `KeyPermanentlyInvalidatedException` means enrollment changed. The key is not a custom matcher and is not passed biometric images. Class-2-only face unlock can still be prompted by `local_auth`, but the Keystore cannot bind that enrollment; that limitation is treated as "unsupported" rather than as success.
   - iOS stores `LAContext.evaluatedPolicyDomainState` from the enrollment-guard channel and compares it on the next launch.
   - Other platforms that do not implement the guard report `unsupported`. Biometric unlock can still prompt through `local_auth`, and an enrollment change is not silently treated as a match.
   When a change is detected, Keeva deletes the session token and the biometric preference. The next launch requires the password.
6. Sign-out deletes the session token, credentials version, biometric flag, enrollment binding, and the declined-offer marker, and clears the Android Keystore key. The next launch requires the password, then the offer can appear again.
7. Prompts go through `local_auth` 3.x, which calls Android `BiometricPrompt` (weak and strong biometrics, not device PIN, because `biometricOnly` is true) and Apple LocalAuthentication (Face ID / Touch ID). `MainActivity` is a `FlutterFragmentActivity` so `BiometricPrompt` has a fragment host. iOS declares `NSFaceIDUsageDescription`. `USE_BIOMETRIC` is requested, and fingerprint hardware is optional so devices without a sensor still install.

## Status

Accepted.

## Consequences

- **Positive:** Moments, Kept, and Settings stay behind the same session. Biometrics never replace the password check that created the token. Tests fake the authenticator and enrollment guard, so they do not prompt a real sensor. A credential change still invalidates the session through the credentials version from ADR 007.
- **Negative:** This remains a client-side gate. Someone who can patch the app can remove it. Android enrollment binding requires a class-3 biometric; class-2-only devices are documented as unable to invalidate on enrollment change. Desktop targets that lack the guard cannot observe enrollment changes. Device PIN is intentionally not accepted as biometric success; the Keeva password is the fallback.
