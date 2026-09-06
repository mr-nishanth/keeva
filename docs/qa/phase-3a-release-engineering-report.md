# Keeva Phase 3A Release Engineering Report

## Application Identity

```text
io.nishvanta.keeva
```

## Version

```text
versionName: 1.0.0
versionCode: 1
```

## License

```text
Apache-2.0
```

## Signing Architecture

PASS

- **Configuration:** Gradle release signing configuration in `android/app/build.gradle.kts` implements dynamic properties loading from untracked `android/key.properties`.
- **Security:** In the absence of `android/key.properties`, the release build safely falls back to debug signing for local releases, validation, and open-source contributors without throwing build errors.
- **Git Hygiene:** Keystore files (`*.jks`, `*.keystore`) and `key.properties` are explicitly ignored in `.gitignore` and confirmed 100% absent from Git tracking.
- **Architecture Model:** Documented Google Play App Signing upload-key workflow where Google manages the app signing key in the cloud and the maintainer only retains the local upload key.

## Release Build

PASS

- Command: `flutter build apk --release`
- Output: `build/app/outputs/flutter-apk/app-release.apk`
- Status: Build succeeded cleanly without warnings or errors.
- Size: 50,576,331 bytes (48.23 MB).

## AAB Build

PASS

- Command: `flutter build appbundle --release`
- Output: `build/app/outputs/bundle/release/app-release.aab`
- Status: Production Android App Bundle built cleanly.
- Size: 51,173,211 bytes (48.80 MB).

## R8 / Shrinking

NOT ENABLED

- Per project development policy ("Do not change rules speculatively"), R8 / ProGuard code shrinking (`isMinifyEnabled`) is preserved as `false`.
- Prevents speculative reflection and runtime failures in `androidx.media3`, `video_player_android`, AndroidX `FileProvider`, and custom JNI/Platform Channel bindings.
- Baseline release APK size is 48.23 MB and AAB size is 48.80 MB.

## Release Manifest

PASS

- **Package:** `io.nishvanta.keeva`
- **Application Label:** `Keeva`
- **Launcher Activity:** `io.nishvanta.keeva.MainActivity` (`android.intent.action.MAIN` / `android.intent.category.LAUNCHER`)
- **FileProvider Authority:** `io.nishvanta.keeva.fileprovider`
- **Permissions Audit:**
  - `android.permission.INTERNET`: **ABSENT**
  - `android.permission.MANAGE_EXTERNAL_STORAGE`: **ABSENT**
  - Included permissions: Only `ACCESS_NETWORK_STATE` and `WAKE_LOCK` (transitive from ExoPlayer/Media3 for video playback wake locks).

## Privacy Audit

PASS

- Verified 100% on-device media processing.
- Zero network transmission capabilities.
- Zero analytics, telemetry, crashlytics, or third-party tracking SDKs present in code or dependencies.
- Verified in-app Privacy Guarantee: "100% On-Device • Zero Network • No Telemetry".

## Secret Audit

PASS

- Ran `git ls-files | grep -iE '\.jks|\.keystore|key\.properties|local\.properties|\.pem|\.p12'` -> 0 matches.
- Ran `git grep -nE '/Users/|/home/|file:///|antigravity|gemini|brain/'` -> 0 leaked workstation paths.
- Ran `git grep -inE 'password|secret|api[-_]?key|private[-_]?key|access[_-]?token'` -> 0 hardcoded credentials.

## Physical Device

PASS

- **Hardware:** POCO X6 Pro 5G (`2311DRK48I` / `duchamp_in`) running Xiaomi HyperOS 1.0 (Android 14 / API 34).
- **Validation Checklist:**
  1. Clean APK uninstallation and fresh installation of `app-release.apk`: PASS
  2. Cold launch into Onboarding: PASS
  3. Launcher icon and label display "Keeva" in HyperOS app drawer: PASS
  4. VectorDrawable splash render: PASS
  5. SAF folder selection (`WhatsApp/Media` tree URI): PASS
  6. Moments feed discovery and thumbnail grid render: PASS
  7. Fullscreen Photo Viewer: PASS
  8. Keep action with instant "Saved to Pictures/SavedStatus" toast & "Kept ✓" state: PASS
  9. Kept Vault screen rendering preserved status: PASS
  10. Settings screen showing folder connection and "About Keeva" 1.0.0 metadata: PASS
  11. Force-stop and relaunch persistence without re-prompting onboarding: PASS
- **Evidence:** 14 high-resolution screenshots archived in `docs/qa/evidence/phase-3a/`.

## Release Regression

PASS

- `dart format --output=none --set-exit-if-changed lib test integration_test`: Formatted 97 files (0 changed)
- `flutter analyze`: No issues found! (ran in 2.5s)
- `flutter test`: 210/210 passed (0 failures)
- `./gradlew test`: 7/7 JVM unit tests passed (0 failures)

## Artifact Checksums

| Artifact | File Size | SHA-256 Checksum |
| :--- | :--- | :--- |
| `app-debug.apk` | 159,034,522 bytes | `167f8b76d931afa2f541458e35d9c980ef1770efe62db711f28346d18e00935d` |
| `app-profile.apk` | 70,429,515 bytes | `8968ff34c38aa369075701f69c663a9f255f4b7dea062a38b40d4facbf5fc41c` |
| `app-release.apk` | 50,576,331 bytes | `49887ed33391c0f038bc2f9e1ba6fb0980d3dd91a679319dc03df44e9b652423` |
| `app-release.aab` | 51,173,211 bytes | `dc70ab27e276e08eb87debc55624ee73e6d7c683c2830e969b56bd566dbed766` |

## Known Limitations

1. Production upload keystore is intentionally uncommitted; builds currently use fallback debug signing until maintainer provisions `android/key.properties`.
2. R8 / ProGuard code minification is currently disabled to prevent speculative breakage with native video playback and SAF document querying.

## Maintainer Actions Required

1. **Upload Keystore Provisioning:** Generate an upload key (`keytool -genkey -v -keystore upload-keystore.jks ...`) and configure untracked `android/key.properties` prior to production Play Store submission.
2. **Google Play Console Registration:** Complete developer organization verification and claim package name `io.nishvanta.keeva`.
3. **Play App Signing Enrollment:** Opt in to Google Play App Signing during the initial internal testing release track upload.

## Overall Status

```text
READY FOR PHASE 3B
```
