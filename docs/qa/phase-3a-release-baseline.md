# Phase 3A Release Baseline Audit

**Date:** 2026-09-06
**Product:** Keeva
**Developer:** Nishvanta Labs
**Phase:** Phase 3A — Release Engineering Foundation

---

## 1. Executive Summary

This baseline audit captures the technical and architectural state of Keeva before applying release engineering configuration changes. The application identity migration (`io.nishvanta.keeva`) and open-source license finalization (`Apache-2.0`) have been completed and verified on physical hardware.

---

## 2. Identity Verification

| Property | Declared Value | Status | Verification Source |
| :--- | :--- | :--- | :--- |
| **Product Name** | Keeva | Verified | `android/app/src/main/res/values/strings.xml`, `README.md` |
| **Developer** | Nishvanta Labs | Verified | `README.md`, `LICENSE`, `docs/legal/` |
| **Application ID** | `io.nishvanta.keeva` | Verified | `android/app/build.gradle.kts` (`defaultConfig.applicationId`) |
| **Namespace** | `io.nishvanta.keeva` | Verified | `android/app/build.gradle.kts` (`android.namespace`) |
| **Package Structure** | `io/nishvanta/keeva` | Verified | `android/app/src/main/kotlin/io/nishvanta/keeva/` |
| **FileProvider Authority** | `io.nishvanta.keeva.fileprovider` | Verified | `android/app/src/main/AndroidManifest.xml` (`${applicationId}.fileprovider`) |
| **Launcher Label** | Keeva | Verified | `android:label="@string/app_name"` |
| **License** | Apache-2.0 | Verified | `LICENSE`, `README.md`, `docs/legal/license-options.md` |

---

## 3. Manifest & Permissions Audit

### 3.1 Main Manifest (`android/app/src/main/AndroidManifest.xml`)
- `<uses-permission>` tags: **Zero**
- `android.permission.INTERNET`: **ABSENT**
- `android.permission.MANAGE_EXTERNAL_STORAGE`: **ABSENT**
- `android.permission.READ_EXTERNAL_STORAGE`: **ABSENT**
- `android.permission.WRITE_EXTERNAL_STORAGE`: **ABSENT**
- FileProvider: Defined as `androidx.core.content.FileProvider` with authority `${applicationId}.fileprovider` and `exported="false"`, `grantUriPermissions="true"`.
- Launcher Activity: `.MainActivity` exported with `MAIN` / `LAUNCHER` intent filter and `@style/LaunchTheme`.

### 3.2 Debug / Profile Manifests
- `android/app/src/debug/AndroidManifest.xml`: Declares `android.permission.INTERNET` solely for Flutter tooling (VM service, hot reload, debugging).
- `android/app/src/profile/AndroidManifest.xml`: Declares `android.permission.INTERNET` solely for Flutter profiling tools.
- Release merged manifest expectation: `android.permission.INTERNET` is completely absent in release outputs.

---

## 4. Privacy & Telemetry Audit

- **Firebase SDKs:** 0 dependencies found in `pubspec.yaml`, `pubspec.lock`, and Gradle build files.
- **Analytics / Telemetry:** 0 third-party trackers (no Google Analytics, no Adjust, no AppsFlyer, no Facebook SDK).
- **Crash Reporting:** 0 remote crash reporting libraries (no Firebase Crashlytics, no Sentry, no Bugsnag).
- **Remote Network Dependencies:** Zero. All media operations execute strictly on-device via Storage Access Framework (SAF) and Android MediaStore APIs.

---

## 5. Gradle Build Configuration Baseline

### 5.1 `android/app/build.gradle.kts`
- Android Gradle Plugin: `com.android.application` (AGP 9.1.0)
- Kotlin: 2.4.0 (JVM 17 target)
- `compileSdk`: `flutter.compileSdkVersion`
- `minSdk`: `flutter.minSdkVersion` (26 / Android 8.0)
- `targetSdk`: `flutter.targetSdkVersion` (35 / Android 15)
- `versionCode`: `flutter.versionCode` (from `pubspec.yaml`: `1`)
- `versionName`: `flutter.versionName` (from `pubspec.yaml`: `1.0.0`)
- Current `buildTypes.release`:
  ```kotlin
  buildTypes {
      release {
          // Signing with debug keys for now
          signingConfig = signingConfigs.getByName("debug")
      }
  }
  ```
- Minification / R8 Shrinking: `isMinifyEnabled` not set (defaults to `false`).
- Resource Shrinking: `isShrinkResources` not set.
- ProGuard Rules: None configured (`proguard-rules.pro` absent).

### 5.2 Secret Tracking & Git Ignore
- `android/key.properties`: Not tracked in git; matched by both root `.gitignore` and `android/.gitignore`.
- Keystores (`*.jks`, `*.keystore`): Not tracked in git; matched by `.gitignore`.
- No sensitive keystore or credential files exist in repository history or working tree.

---

## 6. Hardware Test Environment Baseline

- **Connected Device:** Redmi K70E / POCO X6 Pro (`duchamp_in` / `2311DRK48I`)
- **OS:** Xiaomi HyperOS 1.0 (Android 14 / API 34)
- **Transport:** Wireless ADB (`adb-ONBAXO797LBE7TTC-9XuiKn._adb-tls-connect._tcp`)
- **Verification Status:** Prior identity migration (`io.nishvanta.keeva`) validated on hardware.

---

## 7. Next Actions in Phase 3A

1. Establish versioning policy in `docs/release/versioning-policy.md`.
2. Design secure signing architecture in `docs/release/signing.md`.
3. Configure Gradle release signing structure supporting local untracked `key.properties` with fallback, maintaining repository buildability without exposing credentials.
4. Audit R8/shrinking and ProGuard configuration.
5. Audit merged release AndroidManifest.
6. Verify release builds (`flutter build apk --release`, `flutter build appbundle --release`).
7. Run regression test suite (Dart analysis, unit/widget tests, Kotlin JVM tests).
8. Verify on physical hardware.
