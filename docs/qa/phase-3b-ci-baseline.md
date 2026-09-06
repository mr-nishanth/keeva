# Phase 3B CI Baseline Audit

**Date:** 2026-09-06
**Product:** Keeva
**Developer:** Nishvanta Labs
**Application ID:** `io.nishvanta.keeva`
**Phase:** Phase 3B — CI/CD & Automated Pre-Release Validation

---

## 1. Executive Summary

This baseline document records the authoritative toolchain and platform versions discovered in the Keeva repository. These versions serve as the foundation for the GitHub Actions continuous integration pipeline (`.github/workflows/ci.yml`).

---

## 2. Toolchain Baseline

| Component | Discovered Version | Configuration Source | CI Pinning Strategy |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.47.2` (channel `stable`) | Local Flutter engine & framework | Pinned to `3.47.2` via `subosito/flutter-action@v2` |
| **Dart SDK** | `3.13.2` | `pubspec.yaml` (`sdk: ^3.13.2`), `flutter --version` | Bundled with Flutter 3.47.2 |
| **Java / JDK** | OpenJDK `21.0.11` (Homebrew) | `java -version`, `gradlew --version` | Pinned to Java `21` (`temurin`) via `actions/setup-java@v4` |
| **Gradle** | `9.3.1` | `android/gradle/wrapper/gradle-wrapper.properties` | Bundled Gradle Wrapper (Gradle 9.3.1) with verification via `gradle/actions/setup-gradle@v4` |
| **Android Gradle Plugin (AGP)** | `9.1.0` | `android/settings.gradle.kts` (`id("com.android.application") version "9.1.0"`) | Managed by Gradle project build |
| **Kotlin** | `2.4.0` (target JVM 17) | `android/settings.gradle.kts` (`id("org.jetbrains.kotlin.android") version "2.4.0"`) | Managed by Gradle project build |
| **Default Git Branch** | `main` | `git branch --show-current` | Targeted by push & pull_request triggers |

---

## 3. Android Platform Configuration

| Property | Value | Source |
| :--- | :--- | :--- |
| **Application ID** | `io.nishvanta.keeva` | `android/app/build.gradle.kts` (`defaultConfig.applicationId`) |
| **Namespace** | `io.nishvanta.keeva` | `android/app/build.gradle.kts` (`android.namespace`) |
| **Package Structure** | `io/nishvanta/keeva` | `android/app/src/main/kotlin/io/nishvanta/keeva/` |
| **Compile SDK** | `flutter.compileSdkVersion` (API 36) | `android/app/build.gradle.kts` |
| **Min SDK** | `flutter.minSdkVersion` (API 24 / Android 7.0+) | `android/app/build.gradle.kts` |
| **Target SDK** | `flutter.targetSdkVersion` (API 36 / Android 16) | `android/app/build.gradle.kts` |
| **Version Name** | `1.0.0` | `pubspec.yaml` (`version: 1.0.0+1`), `android/local.properties` |
| **Version Code** | `1` | `pubspec.yaml` (`version: 1.0.0+1`), `android/local.properties` |
| **Java Compatibility** | Java 17 | `compileOptions.sourceCompatibility = JavaVersion.VERSION_17` |
| **Kotlin JVM Target** | JVM 17 | `kotlin.compilerOptions.jvmTarget = JvmTarget.JVM_17` |

---

## 4. Release Configuration & Signing Architecture

- **Release Signing:** Dynamic configuration in `android/app/build.gradle.kts` loading credentials from `android/key.properties` when available.
- **Fallback Behavior:** Falls back gracefully to `debug` signing when `key.properties` is absent, allowing local release builds, contributor validation, and CI artifact builds without requiring production secrets.
- **Git Hygiene:** No signing keys or keystores are tracked in git (`*.jks`, `*.keystore`, `key.properties`, `local.properties` all ignored).
- **Code Minification (R8):** Disabled (`isMinifyEnabled = false`) to prevent speculative runtime issues with native SAF document query and video playback surfaces.

---

## 5. Test Suite Baseline

- **Flutter Unit & Widget Tests:** 210 tests passing across 10 test suites (`flutter test`).
- **Android JVM Unit Tests:** 7 tests passing in `NativeStorageUnitTest` (`./gradlew test`).
- **Total Automated Test Count:** 217 automated tests passing.
