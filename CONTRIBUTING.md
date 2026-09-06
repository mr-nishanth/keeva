# Contributing to Keeva

Thank you for your interest in contributing to Keeva! Keeva is a private, local-first Android application for viewing and saving WhatsApp status media, built with Flutter.

To ensure the codebase remains maintainable, secure, and performant across Android versions, please follow these guidelines.

---

## 1. Core Principles

- **Local-First & Private by Design**: Keeva executes strictly on-device. No telemetry, no analytics, no external network requests for media handling.
- **Architectural Separation**: Keep presentation widgets decoupled from platform storage, SAF URIs, and MediaStore logic. All media access flows through domain use cases and repositories.
- **Platform Awareness**: Android storage access behavior varies across versions (Android 10 to Android 16+). Native platform interactions must be isolated behind typed platform channels and Kotlin services.
- **Quality & Test Coverage**: Every feature or bugfix should include corresponding unit or widget tests.

---

## 2. Development Setup

### Prerequisites
- **Flutter SDK**: `^3.13.2` / Dart `^3.13.2` (or modern stable Flutter channel)
- **Android SDK**: API 35 (minSdk 26, targetSdk 35)
- **JDK**: Java 17

### Getting Started
```bash
# Clone the repository
git clone https://github.com/mr-nishanth/keeva.git
cd keeva

# Fetch dependencies
flutter pub get

# Verify local setup
flutter analyze
flutter test
```

---

## 3. Verification Standards

Before submitting a pull request, verify that all validation steps pass locally:

```bash
# 1. Code Formatting
dart format --output=none --set-exit-if-changed lib test integration_test tool

# 2. Static Analysis
flutter analyze

# 3. Unit and Widget Tests
flutter test

# 4. Debug Build
flutter build apk --debug

# 5. Profile Build (Performance verification)
flutter build apk --profile
```

---

## 4. Architecture Guidelines

Keeva follows a feature-oriented, layered architecture:

```text
lib/
├── app/              # App root, theme, tokens, routing
├── application/      # Riverpod state notifiers & view models
├── core/             # Errors, results, constants, utilities
├── data/             # DTOs, data sources, repository implementations
├── domain/           # Pure entities, repository interfaces, use cases
├── platform/         # MethodChannel constants and platform interfaces
└── presentation/     # Focused Flutter presentation widgets
```

### Rules:
- **No Direct Platform Access in UI**: Do not call `MethodChannel`, `MediaStore`, or filesystem APIs directly from widgets.
- **Immutable State**: State classes should be immutable data structures.
- **Opaque Identifiers**: Domain entities reference media via opaque string identifiers, preventing platform-specific URI leakage into UI layers.

---

## 5. Commit & Pull Request Conventions

Release versions are maintained by the automated release workflow. Contributors should not manually create release tags or GitHub Releases.

We follow Conventional Commits to automatically calculate semantic versions:
- `feat:` A new user-facing feature or enhancement (triggers MINOR release)
- `fix:` A bug fix (triggers PATCH release)
- `feat!:` or `BREAKING CHANGE:` Incompatible changes (triggers MAJOR release)
- `docs:` Documentation updates (no release)
- `test:` Adding or updating tests (no release)
- `refactor:` Code changes that neither fix a bug nor add a feature (no release)
- `chore:` Build scripts, dependencies, or toolchain updates (no release)

### Commit Message Examples:
```text
feat: add media sorting
fix: resolve video cache issue
docs: improve README
chore: update CI
feat!: redesign storage API
```

Please keep PRs focused, include descriptions of changes, and verify all automated checks pass before requesting review.

---

## 6. Licensing of Contributions

Keeva is licensed under the [Apache License, Version 2.0](LICENSE). By submitting a pull request or contributing to this repository, you agree that your contributions will be licensed under and governed by the Apache 2.0 license (in accordance with Section 5 of the Apache License, Version 2.0). Contributor agreements (CLA/DCO) are not required.
