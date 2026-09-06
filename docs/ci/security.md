# Keeva CI Security Architecture

This document defines the security policies, permissions model, and secret-handling principles implemented in Keeva's CI/CD infrastructure.

---

## 1. Zero Production Secrets in CI

Keeva follows strict zero-trust credential hygiene:
- **No Production Keystores in CI:** The production Android signing keystore (`upload-keystore.jks`) is never checked into Git, encoded into environment variables, or stored in repository secrets during Phase 3B.
- **Graceful Fallback Signing:** Keeva's Gradle release build (`android/app/build.gradle.kts`) dynamically checks for `android/key.properties`. When absent, it safely falls back to standard debug signing. This allows CI, pull request contributors, and open-source auditors to build release APKs and AABs without access to proprietary private keys.
- **Automated Secret Leak Detection:** The `compliance` job inspects tracked files via `git ls-files` on every run to guarantee that no `.jks`, `.keystore`, `key.properties`, `local.properties`, `.pem`, or `.p12` files are ever committed.

---

## 2. Least Privilege Permission Model

GitHub Actions workflows are configured with minimal required permissions at the root workflow level:

```yaml
permissions:
  contents: read
```

The workflow explicitly denies write access to:
- `contents: write` (no git commits, branch updates, or release tags)
- `packages: write` (no container or package publishing)
- `id-token: write` (no cloud OIDC impersonation)
- `actions: write` (no workflow modification)

---

## 3. Third-Party Action Governance

To prevent supply chain attacks, only official and community-standard actions are permitted:

| Action | Publisher | Reason & Usage |
| :--- | :--- | :--- |
| `actions/checkout@v4` | GitHub Official | Checks out source tree using clean git clones with ephemeral credentials. |
| `subosito/flutter-action@v2` | Community standard (endorsed by Flutter) | Downloads official Flutter SDK distributions and provides cached pub environment. |
| `actions/setup-java@v4` | GitHub Official | Installs verified Eclipse Temurin OpenJDK 21 distributions. |
| `gradle/actions/setup-gradle@v4` | Gradle Official | Handles Gradle wrapper verification and build dependency caching. |
| `actions/upload-artifact@v4` | GitHub Official | Securely stages temporary build artifacts (APK/AAB) for inspection. |

---

## 4. Future Production Signing & Release Architecture

When production distribution begins in a future phase:
1. **GitHub Environment Protection:** Production signing credentials will be stored within a restricted GitHub Environment (e.g., `production`) requiring maintainer approval for execution.
2. **Environment Secrets:**
   - `KEYSTORE_BASE64`: Encoded upload keystore.
   - `KEY_ALIAS`: Alias of the signing key.
   - `KEYSTORE_PASSWORD`: Password for the keystore.
   - `KEY_PASSWORD`: Password for the private key.
3. **Ephemeral Staging:** Secrets will be decoded to a temporary runner directory and securely shredded immediately after signing.
4. **Google Play App Signing:** Keeva uses Google Play App Signing. The local key is only an upload key; Google manages the actual app-signing master key.

---

## 5. Intentional Exclusion of Automated Publishing

Automated Google Play publishing (`fastlane supply`, Google Play Developer API service accounts, etc.) is intentionally excluded from Phase 3B:
- **Human Gatekeeping:** Initial app verification, privacy declarations, Data Safety audits, and store asset submission require deliberate human review in the Google Play Console.
- **Credential Minimization:** Omits the need to create or store long-lived Google Cloud Service Account private keys in GitHub.
- **Zero Accidental Releases:** Ensures no release artifact reaches public distribution without explicit maintainer sign-off.
