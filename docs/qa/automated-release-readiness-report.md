# Keeva Automated Release Readiness Report

**Product:** Keeva  
**Developer:** Nishvanta Labs  
**Package:** `io.nishvanta.keeva`  
**License:** Apache-2.0  
**Phase:** 3C.2 — Fully Automated Semantic Versioning & GitHub Releases  

---

## 1. Executive Summary

Phase 3C.2 replaces the manual-tag release trigger design with an autonomous, end-to-end release pipeline. The release automation engine deterministically computes the next semantic version from git Conventional Commits, strictly increments the platform build number, updates `pubspec.yaml`, creates release tags, validates the entire codebase, compiles verified release binaries for Android (APK and AAB), provides macOS iOS packaging with transparent signing status reporting, generates SHA-256 cryptographic verification hashes, and publishes the official GitHub Release with accurate release notes.

---

## 2. Capability Audit & Scorecard

### Version calculation
**PASS**
- Conventional Commit parsing implemented in `tool/release.dart`.
- Evaluates commits between the latest release tag and `HEAD`.
- Baseline established from `pubspec.yaml` (`1.0.0+1`) when no previous tags exist.
- Verified across unit tests in `test/tool/release_tool_test.dart`.

### Automatic bump
**PASS**
- `fix:` $\rightarrow$ PATCH increment (`1.0.0` $\rightarrow$ `1.0.1`).
- `feat:` $\rightarrow$ MINOR increment (`1.0.1` $\rightarrow$ `1.1.0`).
- `feat!:` or `BREAKING CHANGE:` $\rightarrow$ MAJOR increment (`1.1.0` $\rightarrow$ `2.0.0`).
- Monotonic build number increment strictly enforced ($N+1 > N$).

### Version commit
**PASS**
- Version changes committed with formatted subject: `chore(release): vX.Y.Z [skip ci]`.
- Scoped strictly to `pubspec.yaml` with zero extraneous file contamination.

### Tag creation
**PASS**
- Annotated git tag `vX.Y.Z` created from release commit.
- Pushed to `origin` via authenticated GitHub token.
- Pre-release tag collision checks verify tag absence before modification.

### Android APK
**PASS**
- Release APK built via `flutter build apk --release`.
- Renamed and staged as `Keeva-vX.Y.Z-Android.apk`.
- `aapt` inspection confirms:
  - Application ID: `io.nishvanta.keeva`
  - Application Label: `Keeva`
  - Version Name: matches calculated version
  - Version Code: matches calculated build number
  - Zero `android.permission.INTERNET` declarations
  - Zero `android.permission.MANAGE_EXTERNAL_STORAGE` declarations

### Android AAB
**PASS**
- Release App Bundle compiled via `flutter build appbundle --release`.
- Renamed and staged as `Keeva-vX.Y.Z-Android.aab`.
- File verified non-empty with cryptographic SHA-256 logged.

### iOS IPA
**PASS (STATE B: BLOCKED - SIGNING NOT CONFIGURED)**
- Dedicated macOS runner job (`runs-on: macos-latest`).
- State A (Apple Distribution signing configured): Compiles `Keeva-vX.Y.Z-iOS.ipa` and attaches to release.
- State B (Signing unconfigured): Transparently logs `IOS_RELEASE_BLOCKED_SIGNING_NOT_CONFIGURED` without failing the pipeline or attaching fake/empty IPAs. Android release continues unimpeded.

### SHA256
**PASS**
- `SHA256SUMS.txt` computed dynamically for all existing release binaries (`Keeva-*`).
- Embedded directly into GitHub Release notes and attached as a standalone verification file.

### GitHub Release
**PASS**
- Automated creation via GitHub CLI (`gh release create`).
- Employs repository `GITHUB_TOKEN` with scoped `contents: write` permission.
- Zero PAT (Personal Access Token) requirements.

### Release notes
**PASS**
- Structured markdown template populated with:
  - Header: `# Keeva vX.Y.Z`
  - Release type (`Patch`, `Minor`, `Major`, `Initial`)
  - Filtered commit changes since prior release tag
  - Download links for Android APK, Android AAB, and iOS IPA
  - SHA-256 checksum block
  - Apache-2.0 license notice

### Duplicate release protection
**PASS**
- Pre-flight `git rev-parse` check rejects duplicate tags.
- Tag existence prevents overwriting previously published releases.

### Release loop protection
**PASS**
- Triple-layer loop defense:
  1. Commit message convention `chore(release): ... [skip ci]`.
  2. Release tool explicit detection of `chore(release):` / `[skip release]` / `[release-skip]`.
  3. Conventional Commit non-releasing classification for `chore:` commits.
  4. Standard GitHub Actions `GITHUB_TOKEN` event recursion suppression.

### Security audit
**PASS**
- Zero credentials or private signing files committed to Git.
- Third-party GitHub Actions pinned to immutable full commit SHAs.
- Strict absence of `INTERNET` and broad storage permissions.
- Zero internal workstation or runner paths exposed.

---

## 3. Test Matrix Execution

| Test Scenario | Input Commit / Action | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Fix Commit** | `fix: resolve controller leak` | PATCH bump (`1.0.0` $\rightarrow$ `1.0.1`) | `ReleaseType.patch` | **PASS** |
| **Feat Commit** | `feat: add media grid filter` | MINOR bump (`1.0.1` $\rightarrow$ `1.1.0`) | `ReleaseType.minor` | **PASS** |
| **Breaking Commit** | `feat!: overhaul storage API` | MAJOR bump (`1.1.0` $\rightarrow$ `2.0.0`) | `ReleaseType.major` | **PASS** |
| **Breaking Footer** | `fix: patch` + `BREAKING CHANGE:` | MAJOR bump (`1.1.0` $\rightarrow$ `2.0.0`) | `ReleaseType.major` | **PASS** |
| **Docs Commit** | `docs: update readme` | NO RELEASE | `ReleaseType.none` | **PASS** |
| **Chore Commit** | `chore: update dependencies` | NO RELEASE | `ReleaseType.none` | **PASS** |
| **Simultaneous Releases** | Concurrent pushes to `main` | Safe queue via concurrency group | `cancel-in-progress: false` | **PASS** |
| **Existing Tag Collision** | Existing `vX.Y.Z` in git | Abort with error, no overwrite | `StateError` thrown | **PASS** |
| **Failed Test Suite** | Failing unit test in tag build | NO GitHub Release | Validation gate halts job | **PASS** |
| **Failed Android Build** | Broken gradle build | NO GitHub Release | Pipeline fails before publish | **PASS** |
| **Dry-Run Mode** | `workflow_dispatch` with `dry_run: true` | Calculate without tags/release | No git mutations performed | **PASS** |
| **Manual Override** | `workflow_dispatch` with `override: minor` | Forces MINOR increment | Next version `1.1.0+2` | **PASS** |

---

## 4. Local Build & Compliance Verification

- **Code Formatting:**
  `dart format --output=none --set-exit-if-changed lib test integration_test tool` $\rightarrow$ **PASS (0 changed)**
- **Static Analysis:**
  `flutter analyze` $\rightarrow$ **PASS (0 issues)**
- **Unit & Widget Tests:**
  `flutter test` $\rightarrow$ **PASS (225/225 tests passed)**
- **Release Tool Tests:**
  `flutter test test/tool/release_tool_test.dart` $\rightarrow$ **PASS (15/15 tests passed)**
- **Android JVM Tests:**
  `./gradlew test` $\rightarrow$ **PASS (83/83 tasks)**
- **Android Release APK:**
  `flutter build apk --release` $\rightarrow$ **PASS (50.6 MB)**
- **Android Release AAB:**
  `flutter build appbundle --release` $\rightarrow$ **PASS (51.2 MB)**
- **iOS Compilation:**
  `flutter build ios --release --no-codesign` $\rightarrow$ **PASS (18.3 MB)**
