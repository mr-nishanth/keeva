# Application ID Migration Audit & Inventory

**Date:** 2026-09-06
**Subject:** Application ID Migration (`com.example.whatsapp_status_saver` → `io.nishvanta.keeva`)
**Scope:** Android application identity, Gradle namespace/applicationId, Kotlin package structure, platform channels, manifests, and documentation.

---

## 1. Executive Summary

This audit catalogs every occurrence of the historical identifier `com.example.whatsapp_status_saver` across the Keeva repository. Each occurrence is classified with clear architectural rationale to prevent unintentional regression of internal platform contracts, storage sandboxes, or test fixtures.

### Canonical Target Identity
- **Application ID:** `io.nishvanta.keeva`
- **Gradle Namespace:** `io.nishvanta.keeva`
- **Android Launcher Label:** `Keeva`
- **Developer / Studio:** `Nishvanta Labs`
- **Tagline:** `Technology You Can Trust.`
- **GitHub:** `https://github.com/mr-nishanth/keeva`

---

## 2. Occurrence Inventory & Classification

| File Location | Line(s) | Context / Snippet | Classification | Rationale & Action |
| :--- | :--- | :--- | :--- | :--- |
| `android/app/build.gradle.kts` | 8 | `namespace = "com.example.whatsapp_status_saver"` | **MUST CHANGE** | Android Gradle Plugin (AGP) namespace defining R class and build target. Migrate to `"io.nishvanta.keeva"`. |
| `android/app/build.gradle.kts` | 19 | `applicationId = "com.example.whatsapp_status_saver"` | **MUST CHANGE** | Public Android OS package identifier and sandbox identity. Migrate to `"io.nishvanta.keeva"`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/MainActivity.kt` | 1 | `package com.example.whatsapp_status_saver` | **MUST CHANGE** | Root Android host activity package declaration. Migrate package to `io.nishvanta.keeva` and move file to `io/nishvanta/keeva/MainActivity.kt`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/MainActivity.kt` | 4 | `import com.example.whatsapp_status_saver.status.AndroidStatusScanner` | **MUST CHANGE** | Import of native status scanner facade. Migrate import to `io.nishvanta.keeva.status.AndroidStatusScanner`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/AndroidStatusScanner.kt` | 1 | `package com.example.whatsapp_status_saver.status` | **MUST CHANGE** | Native facade package declaration. Migrate to `io.nishvanta.keeva.status` and move directory to `io/nishvanta/keeva/status/`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/AndroidStatusScanner.kt` | 33 | `const val CHANNEL_NAME = "com.example.whatsapp_status_saver/scanner"` | **MUST NOT CHANGE** | **Logical Platform Channel ID:** Internal IPC bridge between Flutter Dart and Android Kotlin. Keeping this unchanged preserves backward compatibility and isolates platform-channel messaging from Android package namespace refactoring. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/MediaStoreSaver.kt` | 1 | `package com.example.whatsapp_status_saver.status` | **MUST CHANGE** | Native MediaStore service package declaration. Migrate to `io.nishvanta.keeva.status`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/SafStorageManager.kt` | 1 | `package com.example.whatsapp_status_saver.status` | **MUST CHANGE** | Native SAF manager package declaration. Migrate to `io.nishvanta.keeva.status`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/StatusDocumentReader.kt` | 1 | `package com.example.whatsapp_status_saver.status` | **MUST CHANGE** | Native SAF document query service package declaration. Migrate to `io.nishvanta.keeva.status`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/ThumbnailManager.kt` | 1 | `package com.example.whatsapp_status_saver.status` | **MUST CHANGE** | Native thumbnail caching service package declaration. Migrate to `io.nishvanta.keeva.status`. |
| `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/VideoCacheManager.kt` | 1 | `package com.example.whatsapp_status_saver.status` | **MUST CHANGE** | Native video streaming cache service package declaration. Migrate to `io.nishvanta.keeva.status`. |
| `android/app/src/test/kotlin/com/example/whatsapp_status_saver/NativeStorageUnitTest.kt` | 1 | `package com.example.whatsapp_status_saver` | **MUST CHANGE** | JVM unit test package declaration. Migrate to `io.nishvanta.keeva` and move file to `android/app/src/test/kotlin/io/nishvanta/keeva/`. |
| `android/app/src/test/kotlin/com/example/whatsapp_status_saver/NativeStorageUnitTest.kt` | 3–5 | `import com.example.whatsapp_status_saver.status.*` | **MUST CHANGE** | Imports of native services under test. Migrate to `io.nishvanta.keeva.status.*`. |
| `lib/core/constants/app_constants.dart` | 11 | `'com.example.whatsapp_status_saver/scanner';` | **MUST NOT CHANGE** | Logical platform channel name matching Kotlin `CHANNEL_NAME`. Preserved for compatibility. |
| `lib/main.dart` | 39 | `'com.example.whatsapp_status_saver/scanner'` | **MUST NOT CHANGE** | Method channel declaration matching Kotlin `CHANNEL_NAME`. Preserved for compatibility. |
| `lib/platform/channel_constants.dart` | 4 | `'com.example.whatsapp_status_saver/scanner'` | **MUST NOT CHANGE** | Platform interface channel constant. Preserved for compatibility. |
| `README.md` | 69 | `android/app/src/main/kotlin/com/example/whatsapp_status_saver/` | **MUST CHANGE** | Documentation of Android Kotlin source tree. Update to `android/app/src/main/kotlin/io/nishvanta/keeva/`. |
| `README.md` | 72 | `The underlying Android package name and namespace remain com.example.whatsapp_status_saver...` | **MUST CHANGE** | Public documentation stating historical ID. Update to state canonical ID `io.nishvanta.keeva` and studio identity. |
| `docs/android/storage-access.md` | 389 | ``com.example.whatsapp_status_saver/scanner`` | **MUST NOT CHANGE** | Documentation of the internal platform channel identifier. |
| `docs/architecture/implementation-plan.md` | 46–53 | Reference to original file locations in historical plan | **MUST NOT CHANGE** | Historical design artifact representing initial Phase 2 scaffolding. |
| `docs/architecture/production-architecture.md` | 310, 745 | Channel identifier reference | **MUST NOT CHANGE** | Reference to the internal MethodChannel string. |
| `docs/architecture/production-architecture.md` | 410, 413 | Directory layout description | **DOCUMENTATION ONLY** | Architecture documentation detailing native file locations; updated to reflect modern structure. |
| `docs/qa/phase-2f-report.md` | 154 | `adb shell dumpsys meminfo com.example.whatsapp_status_saver` | **MUST NOT CHANGE** | Historical QA verification report from Phase 2F testing. |
| `docs/qa/phase-2g-functional-report.md` | 15, 179, 193 | Target application ID and `am force-stop` in Phase 2G testing | **MUST NOT CHANGE** | Historical QA verification report from Phase 2G testing. |
| `linux/CMakeLists.txt` | 10 | `set(APPLICATION_ID "com.example.whatsapp_status_saver")` | **REVIEW REQUIRED** | Linux desktop build config. Keeva is an Android-first project with iOS secondary; desktop builds are outside active scope. Left as-is or aligned to `io.nishvanta.keeva` if desirable. |

---

## 3. Subsystem Audit Findings

### 3.1 AndroidManifest.xml & Component Declarations
- **File:** `android/app/src/main/AndroidManifest.xml`
  - Activity: `<activity android:name=".MainActivity"` uses relative naming resolved via `namespace` (`io.nishvanta.keeva.MainActivity`).
  - FileProvider: `<provider android:authorities="${applicationId}.fileprovider"` dynamically binds to `io.nishvanta.keeva.fileprovider`.
  - Kotlin dispatch: `AndroidStatusScanner.kt` invokes `${activity.packageName}.fileprovider`, matching dynamically.
  - No hardcoded `com.example.whatsapp_status_saver` strings exist in any `AndroidManifest.xml` (main, debug, profile).
  - Privacy guarantees preserved: `INTERNET` and `MANAGE_EXTERNAL_STORAGE` remain strictly absent from release manifest.

### 3.2 FileProvider & Sharing
- FileProvider authority is fully dynamic (`${applicationId}.fileprovider`).
- Evaluates to `io.nishvanta.keeva.fileprovider`.
- No hardcoded authority in Dart.

### 3.3 Firebase & Google Services
- Audit command: `find . -iname '*google-services*' -o -iname '*firebase*'` returned 0 results.
- **Firebase integration: NOT PRESENT.**
- Zero telemetry, zero Google Services configuration files exist.

### 3.4 Deep Links & App Links
- Audit command: `git grep -niE 'intent-filter|android:scheme|android:host|app.?link|deep.?link'` in `android/` revealed only standard `MAIN`/`LAUNCHER` and text processing intents.
- **Deep links: NOT PRESENT.**

### 3.5 Storage & SharedPreferences
- SharedPreferences storage name: `"keeva_saved_status"`.
- Not prefixed with old application ID.
- Clean install behavior: Fresh OS sandbox created at `/data/user/0/io.nishvanta.keeva/`.
- Development upgrade behavior: Since `applicationId` changes, Android treats `io.nishvanta.keeva` as a new application distinct from `com.example.whatsapp_status_saver`. Stale development APK should be uninstalled cleanly.

### 3.6 Storage Access Framework (SAF)
- Persisted URI logic in `SafStorageManager.kt` operates on standard Android DocumentsContract URIs.
- URI persistence format, SAF tree selection, permission flags, and folder scanning remain completely untouched.
- **SAF logic unchanged.**

---

## 4. Execution Strategy

1. **Gradle Update:**
   - Modify `android/app/build.gradle.kts`:
     - `namespace = "io.nishvanta.keeva"`
     - `applicationId = "io.nishvanta.keeva"`
2. **Kotlin Package Relocation:**
   - Move `android/app/src/main/kotlin/com/example/whatsapp_status_saver/MainActivity.kt` → `android/app/src/main/kotlin/io/nishvanta/keeva/MainActivity.kt`
   - Move `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/*` → `android/app/src/main/kotlin/io/nishvanta/keeva/status/*`
   - Move `android/app/src/test/kotlin/com/example/whatsapp_status_saver/NativeStorageUnitTest.kt` → `android/app/src/test/kotlin/io/nishvanta/keeva/NativeStorageUnitTest.kt`
   - Remove empty directories under `android/app/src/main/kotlin/com/` and `android/app/src/test/kotlin/com/`.
3. **Update Package Declarations & Imports:**
   - Update `package io.nishvanta.keeva` and `package io.nishvanta.keeva.status`.
   - Update imports in `MainActivity.kt` and `NativeStorageUnitTest.kt`.
4. **Documentation Updates:**
   - Update `README.md` to reference `io.nishvanta.keeva` and `android/app/src/main/kotlin/io/nishvanta/keeva/`.
5. **Clean Verification & Build:**
   - `flutter clean`
   - `flutter pub get`
   - `dart format --output=none --set-exit-if-changed lib test integration_test`
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --debug`
   - `flutter build apk --profile`
6. **Hardware Verification:**
   - Uninstall old dev package `com.example.whatsapp_status_saver`.
   - Install new debug APK `io.nishvanta.keeva`.
   - Verify package name via ADB, test all flows on physical hardware.
