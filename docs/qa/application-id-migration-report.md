# Keeva Android Application ID Migration Report

## Previous Identity

```text
com.example.whatsapp_status_saver
```

## Final Identity

```text
io.nishvanta.keeva
```

## Namespace

```text
io.nishvanta.keeva
```

## Product

Keeva

## Developer

Nishvanta Labs

## Migration Status

PASS

## Android Configuration

PASS

- **`android/app/build.gradle.kts`**:
  - `namespace = "io.nishvanta.keeva"`
  - `applicationId = "io.nishvanta.keeva"`
  - Preserved `compileSdk`, `minSdk`, `targetSdk`, and ndkVersion without changes.
  - Zero dependencies or Gradle plugin upgrades introduced.
- **`linux/CMakeLists.txt`**:
  - Aligned `set(APPLICATION_ID "io.nishvanta.keeva")` for cross-platform namespace parity.

## Kotlin/Java Package Migration

PASS

- Source directory relocated:
  - From: `android/app/src/main/kotlin/com/example/whatsapp_status_saver/`
  - To: `android/app/src/main/kotlin/io/nishvanta/keeva/`
- Test directory relocated:
  - From: `android/app/src/test/kotlin/com/example/whatsapp_status_saver/`
  - To: `android/app/src/test/kotlin/io/nishvanta/keeva/`
- Package statements & imports updated across all 7 Kotlin files:
  - `MainActivity.kt`: `package io.nishvanta.keeva`
  - `AndroidStatusScanner.kt`: `package io.nishvanta.keeva.status`
  - `SafStorageManager.kt`: `package io.nishvanta.keeva.status`
  - `StatusDocumentReader.kt`: `package io.nishvanta.keeva.status`
  - `MediaStoreSaver.kt`: `package io.nishvanta.keeva.status`
  - `ThumbnailManager.kt`: `package io.nishvanta.keeva.status`
  - `VideoCacheManager.kt`: `package io.nishvanta.keeva.status`
  - `NativeStorageUnitTest.kt`: `package io.nishvanta.keeva` (Added `testApplicationIdentityPackage()`)

## Manifest Audit

PASS

- `android/app/src/main/AndroidManifest.xml`:
  - `android:label="Keeva"` preserved.
  - FileProvider authorities configured as `${applicationId}.fileprovider`, which dynamically resolves to `io.nishvanta.keeva.fileprovider`.
  - Zero permission modifications (No `INTERNET`, no `MANAGE_EXTERNAL_STORAGE`).
  - No changes in `debug` or `profile` manifests.

## Provider / Authority Audit

PASS

- **Authority String**: `${applicationId}.fileprovider` → `io.nishvanta.keeva.fileprovider`.
- Verified at runtime on physical Android device:
  ```text
  ContentProvider Authorities:
    [io.nishvanta.keeva.fileprovider]:
      Provider{674fb16 io.nishvanta.keeva/androidx.core.content.FileProvider}
        applicationInfo=ApplicationInfo{ebcf707 io.nishvanta.keeva}
  ```
- File sharing confirmed functional via Android Sharesheet using native URI grant.

## Firebase

NOT PRESENT

- Zero Google Services or Firebase plugins, configs, or SDKs exist in the repository.

## Deep Links

NOT PRESENT

- Zero deep link or App Link intent-filters configured in `AndroidManifest.xml`.

## SAF

UNCHANGED

- Storage Access Framework (SAF) tree selection, document URI persistence (`takePersistableUriPermission`), and folder scanning logic remain completely intact.
- Verified on physical hardware across app reboots.

## Flutter Integration

PASS

- Preserved the internal MethodChannel IPC contract name `com.example.whatsapp_status_saver/scanner` across Dart (`lib/core/constants/app_constants.dart`, `lib/platform/channel_constants.dart`, `lib/main.dart`) and Kotlin (`AndroidStatusScanner.kt`) per explicit instruction in Section 7.
- Zero breaking changes between Flutter UI and native engine.

## Automated Tests

PASS

- `dart format --output=none --set-exit-if-changed lib test integration_test`: Clean (97 files formatted, 0 changes needed).
- `flutter analyze`: Passed (0 issues found).
- `flutter test`: Passed (210/210 tests passed).
- `./gradlew test`: Passed (7/7 JVM tests passed in `io.nishvanta.keeva.NativeStorageUnitTest`).

## Debug Build

PASS

- `flutter build apk --debug`: Succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).

## Profile Build

PASS

- `flutter build apk --profile`: Succeeded (`build/app/outputs/flutter-apk/app-profile.apk`).

## Physical Device

PASS

- **Device**: Xiaomi 14 / HyperOS (Android 16, Model `23127PN0CG`).
- **Clean Installation**: Uninstalled stale package and installed debug APK via ADB.
- **ADB Package Verification**:
  ```bash
  $ adb shell pm list packages | grep nishvanta
  package:io.nishvanta.keeva
  ```
- **Process Dumpsys**:
  ```text
  Package [io.nishvanta.keeva] (9e8d752):
    userId=10283
    pkg=Package{2f3b9c3 io.nishvanta.keeva}
    codePath=/data/app/~~60Y708j4Bv5gZ6e7f_lQ3Q==/io.nishvanta.keeva-z4j0oH2hCgXbL8z5dC_dOw==
    resourcePath=/data/app/~~60Y708j4Bv5gZ6e7f_lQ3Q==/io.nishvanta.keeva-z4j0oH2hCgXbL8z5dC_dOw==
    legacyNativeLibraryDir=/data/app/~~60Y708j4Bv5gZ6e7f_lQ3Q==/io.nishvanta.keeva-z4j0oH2hCgXbL8z5dC_dOw==/lib
    primaryCpuAbi=arm64-v8a
    dataDir=/data/user/0/io.nishvanta.keeva
  ```
- **Old Package Audit**:
  ```bash
  $ adb shell pm list packages | grep whatsapp_status_saver
  (empty - NO RESULT)
  ```

## Launcher

PASS

- Launcher label verified as **Keeva**.
- Adaptive icon renders canonical Keeva glyph and colors without HyperOS vector distortion.

## Splash

PASS

- Pure Android VectorDrawable splash icon (`splash_icon.xml`) displays centered and cleanly without `<aapt:attr>` regressions.

## Share

PASS

- Native Android 16 Share Sheet successfully spawned from full-screen media viewer using `io.nishvanta.keeva.fileprovider`.
- Verified in physical device capture `docs/qa/evidence/migration/15_share_sheet.png`.

## Persistence

PASS

- Saved status media stored in `Pictures/SavedStatus` (1.2 MB).
- Database & SharedPreferences state survived app force-stop (`adb shell am force-stop io.nishvanta.keeva`) and relaunch.
- Moments screen and Kept Vault immediately rehydrated on cold start.

## Security Audit

PASS

- Workstation path audit (`/Users/`, `/home/`, `gemini`, `brain`): Zero leaks found (only `.gitignore:56:.antigravity/` matched).
- Secret & token audit (`password`, `secret`, `api-key`, `access_token`): Zero active credentials in repository.
- Keystore / private certificate files: Zero tracked keys or certificates.

## Old Application ID References

Every remaining occurrence of `com.example.whatsapp_status_saver` has been classified and documented in `docs/qa/application-id-migration-audit.md`:

1. **Logical MethodChannel IPC Contract Identifier** (PRESERVED PER SECTION 7):
   - `android/app/src/main/kotlin/io/nishvanta/keeva/status/AndroidStatusScanner.kt:33`
   - `lib/core/constants/app_constants.dart:11`
   - `lib/main.dart:39`
   - `lib/platform/channel_constants.dart:4`
   - `docs/android/storage-access.md:389`
   - `docs/architecture/production-architecture.md:310, 745`
2. **Historical QA & Architecture Documentation** (PRESERVED PER SECTION 16):
   - `docs/architecture/implementation-plan.md:46-53`
   - `docs/qa/phase-2f-report.md:154`
   - `docs/qa/phase-2g-functional-report.md:15, 179, 193`

## Unrelated Changes

NONE
