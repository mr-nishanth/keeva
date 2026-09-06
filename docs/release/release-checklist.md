# Keeva Dual-Platform Release Checklist

**Product:** Keeva
**Developer:** Nishvanta Labs
**Android Application ID:** `io.nishvanta.keeva`
**iOS Bundle Identifier:** `io.nishvanta.keeva`

---

This checklist must be executed sequentially before publishing or distributing any release of Keeva on Google Play or the Apple App Store.

---

## 1. Common Pre-Release Verification

- [ ] **Working Tree Cleanliness:** `git status` reports working tree clean.
- [ ] **Secret Leak Audit:** No private keys (`*.jks`, `*.keystore`, `*.p12`, `*.cer`, `*.p8`, `*.mobileprovision`, `key.properties`, `local.properties`) are tracked.
- [ ] **License Integrity:** `LICENSE` contains official Apache-2.0 text and attributions remain intact.
- [ ] **Code Formatting:** `dart format --output=none --set-exit-if-changed lib test integration_test` passes with 0 changes.
- [ ] **Static Analysis:** `flutter analyze` passes with 0 issues.
- [ ] **Automated Tests:**
  - `flutter test` (all unit & widget tests pass).
  - `cd android && ./gradlew test` (all native JVM tests pass).
- [ ] **Version Synchronization:**
  - `pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD`.
  - Android `versionName` = `MAJOR.MINOR.PATCH`, `versionCode` = `BUILD`.
  - iOS `CFBundleShortVersionString` = `MAJOR.MINOR.PATCH`, `CFBundleVersion` = `BUILD`.

---

## 2. Android Release Gate (Google Play Store)

- [ ] **Application ID Verified:** `io.nishvanta.keeva` declared in `android/app/build.gradle.kts` and verified via AAPT.
- [ ] **Version Code & Name Verified:** Monotonically increasing `versionCode` verified.
- [ ] **Manifest & Privacy Safeguards:**
  - `android.permission.INTERNET` is **ABSENT**.
  - `android.permission.MANAGE_EXTERNAL_STORAGE` is **ABSENT**.
  - FileProvider authority matches `io.nishvanta.keeva.fileprovider`.
  - App label displays as `Keeva`.
- [ ] **Upload Key Secured:** Upload keystore provisioned in untracked `android/key.properties` (or CI secret) with offline encrypted backup.
- [ ] **Release AAB Built:** `flutter build appbundle --release` produces valid non-empty `.aab`.
- [ ] **Release APK Verified on Hardware:** `flutter build apk --release` installed and verified on physical Android device (API 26–36).
- [ ] **Play App Signing Configured:** Play Console app registered with Google Play App Signing enabled.
- [ ] **Store Listing Prepared:** Title, Short Description, and Full Description finalized (`docs/release/store-metadata.md`).
- [ ] **Store Screenshots Ready:** 512x512 icon, 1024x500 feature graphic, and min 4 high-res phone screenshots (`docs/release/store-screenshots.md`).
- [ ] **Data Safety Form Reviewed:** Verified "No data collected / No data shared" in Play Console.
- [ ] **Privacy Policy Ready:** Published and accessible URL configured.
- [ ] **Internal Testing Gate:** Uploaded to Internal Testing track and validated by QA team.
- [ ] **Production Submission:** Phased rollout initiated (10% -> 25% -> 50% -> 100%).

---

## 3. iOS Release Gate (Apple App Store)

- [ ] **Bundle Identifier Verified:** `io.nishvanta.keeva` configured in Xcode build settings (`PRODUCT_BUNDLE_IDENTIFIER`).
- [ ] **Display Name Verified:** `CFBundleDisplayName` configured as `Keeva` in `ios/Runner/Info.plist`.
- [ ] **Marketing Version & Build Number:** Synced with `pubspec.yaml` (`1.0.0` build `1`).
- [ ] **App Store Connect Record Created:** App created under Nishvanta Labs organization in App Store Connect.
- [ ] **Signing Configured:** Apple Distribution Certificate and App Store Provisioning Profile provisioned.
- [ ] **Release Build Generated:** `flutter build ios --release` succeeds without compilation errors.
- [ ] **Release Archive Created:** Xcode Archive (`Runner.xcarchive`) generated successfully.
- [ ] **Archive Validated:** Xcode Organizer / `xcrun altool` validation passes with 0 errors or warnings.
- [ ] **TestFlight Upload:** Archive uploaded to App Store Connect and processed cleanly.
- [ ] **Internal Testing (TestFlight):** Tested by internal organization members.
- [ ] **Store Screenshots Ready:** 1024x1024 App Store icon, 6.9" and 6.5" iPhone screenshots verified (`docs/release/store-screenshots.md`).
- [ ] **App Privacy Nutrition Labels:** Verified "No data collected" declared in App Store Connect.
- [ ] **Age Rating Configured:** Completed age rating questionnaire (4+ rating).
- [ ] **App Review Notes Prepared:** Feature matrix and review demo instructions documented.
- [ ] **App Review Submission:** Submitted for App Review.
