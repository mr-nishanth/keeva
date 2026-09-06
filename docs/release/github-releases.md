# Keeva Automated GitHub Releases

**Product:** Keeva  
**Developer:** Nishvanta Labs  
**Repository:** `mr-nishanth/keeva`  
**License:** Apache-2.0  

---

## 1. Overview

Keeva uses a fully automated release pipeline powered by GitHub Actions. Releases are triggered deterministically upon merging qualifying Conventional Commits to the `main` branch.

Maintainers and contributors **do not** manually create Git release tags or publish GitHub Releases. The entire pipeline executes autonomously in the following 8-step order:

1. **Merge a qualifying change to `main`:** Pull requests or commits containing `fix:`, `feat:`, or breaking changes land on `main`.
2. **GitHub Actions determines the release type:** The release engine analyzes commits since the last tag using Conventional Commit rules (Patch, Minor, or Major).
3. **Version is automatically incremented:** The semantic version and strictly monotonic build number are computed and updated in `pubspec.yaml`.
4. **Git tag is automatically created:** A release commit (`chore(release): vX.Y.Z [skip ci]`) and an annotated tag (`vX.Y.Z`) are committed and pushed to `origin`.
5. **Android binaries are built:** Release APK (`Keeva-vX.Y.Z-Android.apk`) and Release AAB (`Keeva-vX.Y.Z-Android.aab`) are compiled, followed by `aapt` inspection to verify identity (`io.nishvanta.keeva`), application label (`Keeva`), versioning, and zero sensitive permissions.
6. **iOS binary is built when signing is configured:** On macOS runners, if Apple distribution credentials are configured in repository secrets, a signed iOS IPA (`Keeva-vX.Y.Z-iOS.ipa`) is packaged. If signing credentials are not configured, the workflow safely logs `IOS_RELEASE_BLOCKED_SIGNING_NOT_CONFIGURED` without failing the Android release.
7. **Checksums are generated:** Cryptographic SHA-256 hashes are computed for all generated release binaries and compiled into `SHA256SUMS.txt`.
8. **GitHub Release is published automatically:** The release is created on GitHub via `gh release create` with canonical release notes, changelog, and attached release assets.

---

## 2. Release Assets

Every production GitHub Release includes:

| Asset Name | Format | Platform | Description |
| :--- | :--- | :--- | :--- |
| `Keeva-vX.Y.Z-Android.apk` | APK | Android | Direct installable Android package for sideloading and testing. |
| `Keeva-vX.Y.Z-Android.aab` | AAB | Android | Google Play Store publication bundle with Dynamic Delivery support. |
| `Keeva-vX.Y.Z-iOS.ipa` | IPA | iOS | Production iOS application archive (attached when Apple signing is provisioned). |
| `SHA256SUMS.txt` | TXT | All | Cryptographic SHA-256 verification hashes for all published binaries. |

---

## 3. Dry-Run & Manual Override

The workflow supports manual dispatch via the GitHub Actions interface (`workflow_dispatch`) for testing or exceptional releases:

### 3.1 Dry-Run Mode
Setting `dry_run: true` instructs the release engine to:
- Evaluate git commit history
- Calculate the next version and monotonic build number
- Verify all validation checks
- Output the decision report **without** committing to git, creating tags, or publishing releases.

### 3.2 Manual Version Override
Maintainers can select an explicit override mode (`patch`, `minor`, `major`) in `workflow_dispatch`. The release engine enforces the selected increment, updates `pubspec.yaml`, increments the build number, runs full validation, and publishes the release. Arbitrary version strings are prohibited.

---

## 4. Release Safety & Loop Prevention

- **Infinite Loop Prevention:** Release commits use the subject `chore(release): vX.Y.Z [skip ci]`. The release engine explicitly detects and ignores release commits, preventing recursive release triggering.
- **Duplicate Tag Protection:** If a calculated tag already exists on the remote repository, the workflow safely halts before any release assets are generated or published.
- **Concurrency Locking:** The workflow enforces `concurrency: group: release-${{ github.ref }}, cancel-in-progress: false`, ensuring concurrent pushes queue safely without race conditions.
- **Validation Gate:** If tests, static analysis, formatting, or binary inspection fails, the release job is cancelled immediately with zero GitHub Releases published.
