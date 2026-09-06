# Keeva Release Engineering

**Product:** Keeva
**Application ID:** `io.nishvanta.keeva`
**Namespace:** `io.nishvanta.keeva`
**Developer:** Nishvanta Labs (*Technology You Can Trust.*)
**License:** Apache-2.0

---

## 1. Overview

This directory documents the release engineering foundation, versioning semantics, signing architecture, distribution readiness, and production verification procedures for Keeva.

Keeva is engineered as an Android-first, local-first Flutter application designed for private WhatsApp status media browsing and preservation.

---

## 2. Release Engineering Specifications

| Document | Description |
| :--- | :--- |
| [versioning-policy.md](versioning-policy.md) | Canonical rules governing `versionName` (SemVer) and `versionCode` (monotonic sequence). |
| [signing.md](signing.md) | Secure signing architecture, Google Play App Signing, and zero-secret repository security. |
| [release-checklist.md](release-checklist.md) | Comprehensive step-by-step checklist required before cutting any production distribution. |
| [android-developer-verification.md](android-developer-verification.md) | Maintainer guidelines for Google Play Developer verification and package-name ownership. |

---

## 3. Core Principles

1. **Zero Secret Persistence:** Private keys, keystores, and passwords must never be committed to Git. Local builds utilize untracked properties (`android/key.properties`) with automatic fallback to debug signing for open-source contributors and local tests.
2. **Deterministic & Reproducible Builds:** Release artifacts are produced using standardized Flutter and Gradle toolchains with verified dependencies.
3. **No Unnecessary Permissions:** The release manifest declares strictly zero unnecessary permissions (`INTERNET` and `MANAGE_EXTERNAL_STORAGE` are absent in production builds).
4. **Platform Compliance:** Full compliance with Android Scoped Storage, Storage Access Framework (SAF), and Android 12+ VectorDrawable splash specifications.
