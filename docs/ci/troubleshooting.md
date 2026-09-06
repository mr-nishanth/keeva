# Keeva CI Troubleshooting Guide

This guide outlines common CI failure modes, their root causes, and verified recovery procedures.

---

## 1. Flutter SDK Version Mismatches

### Symptoms
- `dart format` reports differences or unexpected syntax.
- `flutter analyze` flags warnings on standard library types.
- Pipeline fails at `subosito/flutter-action@v2`.

### Diagnosis & Fix
- Keeva is currently pinned to Flutter `3.47.2` (Dart `3.13.2`, channel `stable`).
- Verify that your local Flutter environment matches:
  ```bash
  flutter --version
  ```
- If an SDK upgrade is planned, update both `pubspec.yaml` (`environment.sdk`) and `.github/workflows/ci.yml` simultaneously after full regression testing.

---

## 2. Java & Gradle Incompatibilities

### Symptoms
- Build fails with `Unsupported class file major version` or Gradle daemon crashes.
- `./gradlew test` throws `Incompatible JVM` errors.

### Diagnosis & Fix
- Keeva uses Gradle `9.3.1` running on Java `21` (OpenJDK / Eclipse Temurin).
- Ensure Java 21 is selected in CI via `actions/setup-java@v4`.
- For local builds, verify active JDK:
  ```bash
  java -version
  cd android && ./gradlew --version
  ```
- Note: While Gradle runs on JVM 21, Kotlin compilation and Android byte-code target Java 17 compatibility (`JavaVersion.VERSION_17`). Do not lower the launcher JDK below Java 17.

---

## 3. Dependency Resolution Failures

### Symptoms
- `flutter pub get` fails with version solving errors.
- Transitive dependency version clashes.

### Diagnosis & Fix
- Keeva maintains a committed `pubspec.lock`. Do not run `flutter pub upgrade` arbitrarily.
- If dependencies must be updated:
  ```bash
  flutter pub outdated
  flutter pub get
  flutter analyze
  flutter test
  ```
- Check that all dependencies remain compatible with the Flutter `3.47.2` SDK constraint.

---

## 4. Android SDK & AAPT Tooling Issues

### Symptoms
- `aapt: command not found` during the `release-build` validation step.
- Android platform build-tools missing.

### Diagnosis & Fix
- In GitHub Actions `ubuntu-latest` runners, the Android SDK is located at `/usr/local/lib/android/sdk`.
- Build-tools reside under `$ANDROID_HOME/build-tools/<version>/`.
- The CI script dynamically discovers the latest installed `aapt` binary using:
  ```bash
  AAPT=$(find "${ANDROID_HOME:-/usr/local/lib/android/sdk}/build-tools" -name aapt -type f | sort -V | tail -n 1)
  ```
- If running in a custom runner environment, ensure the Android SDK Build-Tools package (API 34+) is installed and `ANDROID_HOME` is set.

---

## 5. Test Suite Failures

### 5.1 Flutter Tests (`flutter test`)
- Run the failing suite locally in verbose mode:
  ```bash
  flutter test test/path/to/failing_test.dart -v
  ```
- Ensure any mocked Storage Access Framework (SAF) URI structures comply with `SafStorageManager` expectations.

### 5.2 Android JVM Tests (`./gradlew test`)
- Run with info logging from the `android/` directory:
  ```bash
  cd android
  ./gradlew test --info
  ```
- Test reports are generated at `build/app/reports/tests/testDebugUnitTest/index.html`.

---

## 6. Release Build Failures

### Symptoms
- `flutter build apk --release` or `flutter build appbundle --release` fails.
- Keystore missing or signing failed.

### Diagnosis & Fix
- Keeva automatically falls back to debug signing when `android/key.properties` is absent.
- If a build fails with signing configuration errors, ensure `android/app/build.gradle.kts` has not been altered to require mandatory keystore properties without fallback.
- Verify that `isMinifyEnabled` has not been inadvertently turned on without ProGuard keep rules for Media3 and platform channels.
