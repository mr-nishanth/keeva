# Keeva Release Signing Architecture

**Product:** Keeva
**Developer:** Nishvanta Labs
**Package:** `io.nishvanta.keeva`

---

## 1. Executive Summary

This document establishes the release signing architecture, credential management protocols, and operational security guidelines for Keeva.

Keeva strictly enforces zero-secret persistence in version control. Private keystore files, passwords, and signing credentials must never be committed to Git or stored in public repositories.

---

## 2. Recommended Signing Architecture: Google Play App Signing

Modern Android distribution leverages **Google Play App Signing**, which decouples the developer's upload credentials from the end-user delivery certificate.

```text
+-------------------------------------------------------------+
|                       Developer / CI                        |
|                                                             |
|   Upload Key (upload-keystore.jks)                          |
|   Stored securely off-repository in local key storage       |
+-------------------------------------------------------------+
                              |
                              | Signs Release Artifact (.aab)
                              v
+-------------------------------------------------------------+
|                     Google Play Console                     |
|                                                             |
|   1. Verifies artifact signature using Upload Certificate    |
|   2. Strips upload signature                                |
|   3. Signs optimized split APKs with App Signing Key        |
+-------------------------------------------------------------+
                              |
                              | Delivers Signed APKs
                              v
+-------------------------------------------------------------+
|                      End-User Device                        |
|                                                             |
|   Installs APK verified by Google Play App Signing Key      |
+-------------------------------------------------------------+
```

### 2.1 Benefits of Play App Signing
1. **Security Isolation:** The master app signing key remains encrypted in Google's secure key management infrastructure (KMS); developer workstation compromise cannot expose the master key.
2. **Key Rotation & Recovery:** If an upload key is lost or compromised, the developer can register a new upload key with Google Play without orphaning existing users.
3. **App Bundle Optimization:** Google Play generates device-targeted APKs (ABI, screen density, language) signed with the canonical app signing key.

---

## 3. Local Key Storage & Configuration

### 3.1 Upload Key Specifications
When creating the upload keystore:
- **Algorithm:** RSA 4096-bit (or EC with curve P-256)
- **Validity:** Minimum 25 years (10,000 days)
- **Alias:** `upload`
- **Distinguished Name (DName):** `CN=Nishvanta Labs, O=Nishvanta Labs, C=IN`

### 3.2 Configuration File (`android/key.properties`)
Local developer environments supply signing credentials via an untracked properties file located at `android/key.properties`:

```properties
# android/key.properties (UNTRACKED - NEVER COMMIT TO GIT)
keyAlias=upload
keyPassword=YOUR_SECURE_KEY_PASSWORD
storePassword=YOUR_SECURE_STORE_PASSWORD
storeFile=/absolute/path/to/upload-keystore.jks
```

### 3.3 Gradle Build Integration
`android/app/build.gradle.kts` dynamically reads `android/key.properties`:
1. If `key.properties` is present with valid entries, Gradle configures the `release` signing config with the upload key.
2. If `key.properties` is absent (such as in open-source clone environments, pull-request verification, or automated unit tests), Gradle gracefully falls back to debug signing so that standard local builds and CI validation remain fully functional without leaking credentials.

---

## 4. Secret Prevention & `.gitignore` Safeguards

Repository hygiene is protected by strict `.gitignore` rules at both repository root and `android/` level:

```gitignore
# Keystore & Private Signing Credentials
*.keystore
*.jks
key.properties
android/key.properties
android/app/*.jks
android/app/*.keystore
local.properties
android/local.properties
```

### Mandatory Rules:
- Never commit `key.properties` or keystore binaries.
- Never hardcode passwords or aliases in `build.gradle.kts`, `gradle.properties`, or source code.
- Always run `git status` and `git diff` before staging changes.

---

## 5. Keystore Backup & Recovery Requirements

1. **Cold Off-Site Backup:** Store an encrypted copy of `upload-keystore.jks` and credentials in an offline, password-manager encrypted vault or hardware security module (HSM).
2. **Never Rely on a Single Workstation:** A laptop failure must not result in permanent loss of deployment ability.
3. **Lost-Key Recovery Protocol:**
   - Because Keeva uses Google Play App Signing, a lost upload key does not permanently destroy update capability.
   - The repository maintainer contacts Google Play Developer Support through the Play Console to request an upload key reset.
   - The maintainer generates a new upload key, extracts the public PEM certificate, and provides it to Google Play Support.
   - Once verified, the new upload key becomes active within 48 hours.

---

## 6. Future CI/CD Strategy (Phase 3B / 3C)

When automated release builds are introduced:
- Keystores will be encoded as Base64 strings in encrypted repository secrets (e.g., GitHub Secrets).
- Workflows will dynamically decode the keystore into a temporary runner directory and construct `key.properties` ephemeral to the build job.
- Release artifacts (`.aab`) will be built, verified, and published via signed API tokens without committing secrets.
- Manual verification and maintainer sign-off gates will guard any production deployment.
