# Keeva Production Release Checklist

**Product:** Keeva
**Developer:** Nishvanta Labs
**Package:** `io.nishvanta.keeva`

---

This checklist must be executed sequentially before publishing or distributing any release of Keeva.

## 1. Pre-Release Verification

- [ ] **Working Tree Cleanliness:** No unintended modifications or debug test artifacts exist in the Git tree.
- [ ] **Secret Audit:** Verify that `android/key.properties`, `*.jks`, `*.keystore`, and `local.properties` are untracked and excluded by `.gitignore`.
- [ ] **License Check:** Confirm `LICENSE` contains the official Apache-2.0 license text and all documentation attribution remains intact.
- [ ] **Code Formatting:** Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- [ ] **Static Analysis:** Run `flutter analyze` and resolve all warnings or errors.
- [ ] **Automated Test Suite:**
  - Run Flutter unit and widget tests: `flutter test`
  - Run Android native JVM tests: `cd android && ./gradlew test`
- [ ] **Version Synchronization:**
  - Check `pubspec.yaml`: verify `version: MAJOR.MINOR.PATCH+BUILD`.
  - Confirm `versionCode` (BUILD) is strictly greater than the previously distributed build.
  - Confirm `versionName` conforms to SemVer.

---

## 2. Manifest & Privacy Safeguards

- [ ] **Permission Audit:**
  - Verify `android.permission.INTERNET` is **ABSENT** in release artifacts.
  - Verify `android.permission.MANAGE_EXTERNAL_STORAGE` is **ABSENT**.
  - Verify zero telemetry, tracking, or remote analytics SDKs are linked.
- [ ] **FileProvider Authority:** Confirm authority in release manifest matches `io.nishvanta.keeva.fileprovider`.
- [ ] **Launcher Identity:** Confirm launcher icon, adaptive icon, monochrome icon, and label (`Keeva`) display correctly.

---

## 3. Build & Signing

- [ ] **Upload Key Provisioning:** Ensure valid upload keystore is configured in untracked `android/key.properties`.
- [ ] **Build Android App Bundle:**
  ```bash
  flutter build appbundle --release
  ```
- [ ] **Build Release APK (for local / sideload QA):**
  ```bash
  flutter build apk --release
  ```
- [ ] **Artifact Checksum Recording:** Compute SHA-256 for all generated release bundles and APKs.

---

## 4. Hardware Quality Assurance

- [ ] **Clean Installation:** Sideload or internal-test install onto a physical Android device (API 26 to API 35+).
- [ ] **Core Flow Validation:**
  1. App launches with smooth VectorDrawable splash screen.
  2. Onboarding displays SAF guide.
  3. SAF folder selection via system document picker succeeds.
  4. Moments feed displays status photos and videos.
  5. Fullscreen photo viewer opens with zoom and pan.
  6. In-app video player plays video statuses with audio and progress slider.
  7. "Keep" action preserves media into on-device Kept Vault.
  8. Kept Vault loads and persists items across app termination and reboot.
  9. Native share sheet dispatches media cleanly via FileProvider.
  10. Settings screen displays folder status and system theme switching works.

---

## 5. Post-Release Maintainer Actions

- [ ] Tag git commit: `git tag -a vMAJOR.MINOR.PATCH -m "Release vMAJOR.MINOR.PATCH"`
- [ ] Upload `.aab` to Google Play Console (Internal / Closed Testing track first).
- [ ] Verify Google Play pre-launch report for crashes or ANRs.
