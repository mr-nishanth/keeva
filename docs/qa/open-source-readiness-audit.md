# Keeva Open-Source Readiness Audit

**Repository:** Keeva
**Developer:** Nishvanta Labs
**Repository Path:** mr-nishanth/keeva
**Audit Date:** 2026-09-06
**Auditor:** Automated Open-Source & Legal Readiness Suite

---

## 1. Executive Status & Dashboard

| Dimension | Status | Summary |
| :--- | :--- | :--- |
| **Project License** | **Apache-2.0** | Formally selected by maintainer on 2026-09-06. |
| **`LICENSE` / `LICENSE.md` File** | **CREATED** | Official Apache-2.0 license file created at repository root. |
| **Copyright / Ownership** | **PASS** | Original code and brand assets cleanly attributed to Nishvanta Labs. Boilerplate Flutter notices preserved. |
| **Dart/Flutter Dependencies** | **PASS** | 53 total packages (7 direct, 46 transitive). 100% permissive licenses (MIT, BSD-3-Clause, Apache-2.0). |
| **Android Dependencies** | **PASS** | Gradle plugins and AndroidX components verified Apache-2.0 / BSD-3-Clause. JUnit 4.13.2 EPL-1.0 test-only. |
| **iOS Dependencies** | **PASS** | CocoaPods absent. Swift Package Manager integration uses official Flutter SDK / plugins (BSD-3-Clause). |
| **Third-Party Assets** | **PASS** | Only one third-party asset (*Plus Jakarta Sans* font under SIL OFL-1.1). Zero unverified third-party media. |
| **Trademark / Branding** | **PASS** | Brand identity established as Nishvanta Labs. No unverified legal incorporation or registered trademark claims. |
| **WhatsApp / Meta Disclaimer** | **PASS** | Factual, unambiguous disclaimer present in README, Settings UI, and documentation. No affiliation claims. |
| **Privacy Claims** | **PASS** | No internet permission in AndroidManifest. No telemetry SDKs. Absolute "100%" claims refined to supportable language. |
| **Secrets & Leaks Audit** | **PASS** | Zero API keys, private tokens, passwords, keystores, or personal filesystem paths in tracked repository files. |
| **Verification Builds** | **PASS** | Analysis, tests, debug APK, and profile APK builds verified clean. |

---

## 2. Content Provenance & Classification

Every file in the repository was classified into the following 10 categories to verify licensing provenance:

| Category | Description / Included Files | Origin / Provenance Classification |
| :--- | :--- | :--- |
| **A. Original Source Code** | `lib/**/*.dart`, `android/app/src/main/kotlin/**/*.kt` | **Original** (Authored by Nishvanta Labs / project contributors). |
| **B. Original Brand Assets** | `assets/brand/keeva/*.svg`, `assets/brand/nishvanta/*.svg` | **Original** (Canonical vector marks created by Nishvanta Labs). |
| **C. Third-Party Dependencies** | Direct & transitive Dart packages, Gradle plugins, AndroidX libraries | **Third-party** (100% permissive: MIT, BSD-3-Clause, Apache-2.0, EPL-1.0 test). |
| **D. Third-Party Fonts** | `assets/fonts/PlusJakartaSans-Variable.ttf` | **Third-party** (Gumpita Rahayu / Tokotype, SIL Open Font License 1.1). |
| **E. Third-Party Images** | None present in repository | **None** (Zero stock photos, uncredited web icons, or external media). |
| **F. Generated Assets** | `assets/icon/*.png`, `ios/.../AppIcon.appiconset/*.png`, `docs/assets/branding/*.png`, WebP fallbacks | **Generated from Original Source** (Rendered deterministically from canonical SVGs). |
| **G. Platform Resources** | Android launch drawables, iOS storyboards, manifest XMLs | **Original & Flutter Boilerplate** (Custom VectorDrawables + standard Flutter templates). |
| **H. Documentation** | `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `docs/**/*.md` | **Original** (Authored for Keeva project). |
| **I. Test Fixtures** | `test/**/*.dart`, `integration_test/**/*.dart` | **Original** (Pure Dart test mocks and in-memory domain models). |
| **J. Sample / Test Media** | None present in repository | **None** (Tests use in-memory mock metadata; zero bundled media files). |

---

## 3. Detailed Audit Findings

### 3.1. Copyright & Ownership Audit
- Searched repository for all instances of `Copyright`, `©`, `Author`, `License`, `Licensed`, `Attribution`.
- Preserved legitimate copyright notices in Flutter-generated platform wrappers (`macos/Runner/Configs/AppInfo.xcconfig`, `windows/runner/Runner.rc`).
- Retained original author credits in `assets/fonts/PlusJakartaSans-Variable.ttf` (Tokotype / Gumpita Rahayu).
- Verified that Keeva and Nishvanta Labs are attributed as developer identity without making unsupported incorporation or registered trademark claims.

### 3.2. Dependency License Audit
- Full audit recorded in [`docs/legal/dependency-licenses.md`](../legal/dependency-licenses.md).
- **Direct dependencies**:
  - `cupertino_icons` (1.0.9): MIT
  - `flutter` (SDK): BSD-3-Clause
  - `flutter_riverpod` (3.4.3): MIT
  - `video_player` (2.14.0): BSD-3-Clause
  - `flutter_lints` (6.0.0): BSD-3-Clause
  - `flutter_test` (SDK): BSD-3-Clause
  - `integration_test` (SDK): BSD-3-Clause
- **Transitive dependencies**: All 46 packages verified under BSD-3-Clause, MIT, or Apache-2.0.
- **Android Gradle**: AGP (Apache-2.0), Kotlin (Apache-2.0), JUnit 4.13.2 (`testImplementation` only, EPL-1.0).
- **iOS SPM**: Swift Package Manager integration using `FlutterFramework` and `video_player_avfoundation` (BSD-3-Clause). CocoaPods is not used.
- **Compatibility**: The dependency set is 100% compatible with MIT, Apache-2.0, or GPL-3.0 candidate project licenses.

### 3.3. Embedded Font License Audit
- Inspected OpenType `name` table of `assets/fonts/PlusJakartaSans-Variable.ttf`:
  - NameID 0: `Copyright 2020 The Plus Jakarta Sans Project Authors (https://github.com/tokotype/PlusJakartaSans)`
  - NameID 8: `Tokotype`
  - NameID 9: `Gumpita Rahayu`
  - NameID 13: `This Font Software is licensed under the SIL Open Font License, Version 1.1.`
- SIL OFL-1.1 permits bundling with open-source software under any license, provided the font software itself is not sold by itself.

### 3.4. Trademark & WhatsApp / Meta Disclaimer Audit
- Searched all occurrences of `whatsapp`, `meta`, and `facebook`.
- Verified that Keeva is described strictly as an independent project.
- The standard disclaimer is applied consistently:
  > *"WhatsApp is a trademark of its respective owner. Keeva is an independent project and is not affiliated with or endorsed by WhatsApp or Meta."*
- Prohibited phrases ("Official WhatsApp app", "WhatsApp-approved", "Partnered with WhatsApp") are completely absent.

### 3.5. Privacy & Architecture Claims Classification

| Claim in Repository | Classification | Verification Detail |
| :--- | :--- | :--- |
| **No Internet Permission / Zero Network Requests** | **SUPPORTED** | `android.permission.INTERNET` is not declared in `AndroidManifest.xml`. No networking libraries are included in `pubspec.yaml`. |
| **No Intentional Telemetry / Zero Trackers** | **SUPPORTED** | Zero analytics SDKs, advertising libraries, or crash beacons are bundled in dependencies. |
| **Local-First On-Device Media Processing** | **SUPPORTED** | Media discovery, preview generation, and saving execute strictly on-device via local SAF ContentResolver. |
| **Scoped Directory Access (SAF)** | **SUPPORTED** | Access requires explicit user authorization via `ACTION_OPEN_DOCUMENT_TREE`. App does not declare or request `MANAGE_EXTERNAL_STORAGE`. |
| **100% On-Device / Guarantee Wording** | **PARTIALLY SUPPORTED** | Architecturally verified, but absolute legal terms ("100%", "guarantee") have been softened in documentation to technically precise phrasing. |
| **100% Secure / Impossible to Hack** | **UNSUPPORTED** | Verified absent. No absolute security warranties exist in the codebase or documentation. |

### 3.6. Secrets, Credentials & Leak Audit
- Audited using regex patterns:
  - `/Users/`, `/home/`, `file:///`, `antigravity`, `gemini`, `brain/`
  - Maintainer username `nishanth`
  - `password`, `secret`, `api[-]?key`, `private[-]?key`, `access[_-]?token`
- Results:
  - **Tracked Code & Docs**: Zero private keys, API keys, passwords, personal paths, or tokens discovered.
  - **Ignored Patterns**: Verified that `.gitignore` ignores `key.properties`, `*.keystore`, `*.jks`, `local.properties`, `.antigravity/`, `.claude-flow/`.
  - **Git History**: Verified clean; no history rewriting tools were run.

---

## 4. Documentation Alignment Summary

- **`README.md`**:
  - Clone URL updated to `https://github.com/mr-nishanth/keeva.git`.
  - Privacy claims aligned to supportable "Local-First On-Device" phrasing.
  - License badge added and License section updated to reflect Apache-2.0.
  - Standard factual WhatsApp disclaimer verified.
- **`SECURITY.md`**:
  - Refined architecture section to technically supportable language (no internet permission, no telemetry, SAF scoped access).
- **`CONTRIBUTING.md`**:
  - Clone URL updated to `https://github.com/mr-nishanth/keeva.git`.
  - Contribution licensing section updated to Apache-2.0 without imposing an unauthorized CLA or DCO.

---

## 5. GitHub Security Recommendations

Prior to public release, the maintainer should configure the following GitHub features:

1. **Dependabot Alerts & Security Updates**: Enable in repository settings to receive automated notifications and PRs for vulnerable dependencies.
2. **Secret Scanning & Push Protection**: Enable in repository security settings to prevent accidental credential pushes.
3. **Private Vulnerability Reporting**: Enable to provide a secure channel for security researchers.
4. **Automated CI Validation**: Implement a GitHub Actions workflow running formatting, static analysis, and test suites.

Full details are documented in [`docs/legal/github-repository-readiness.md`](../legal/github-repository-readiness.md).

---

## 6. Maintainer Decisions Required

Before publishing the repository publicly, the maintainer must make the following explicit decisions:

1. **Select Project License**:
   - **COMPLETED**: Maintainer selected **Apache-2.0** on 2026-09-06. Official `LICENSE` file created and verified.
2. **Decide on `.github/CODEOWNERS`**:
   - Approve or defer the proposed `.github/CODEOWNERS` configuration for `@mr-nishanth`.
3. **Decide on `CODE_OF_CONDUCT.md`**:
   - Approve or defer adopting Contributor Covenant v2.1.
4. **Decide on `CITATION.cff`**:
   - Confirm omission (recommended) or specify citation metadata.
5. **Enable GitHub Security Features**:
   - Enable Dependabot, Secret Scanning, Push Protection, and Private Vulnerability Reporting in GitHub repository settings.
