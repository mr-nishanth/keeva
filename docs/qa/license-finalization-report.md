# Keeva License Finalization Report

## Project

Keeva

## Developer

Nishvanta Labs

## Repository

mr-nishanth/keeva

## Selected License

Apache-2.0

The project maintainer has explicitly selected the **Apache License, Version 2.0 (Apache-2.0)**.

---

## LICENSE File

CREATED

- **Path:** `LICENSE` (repository root)
- **License Title:** Apache License, Version 2.0 (January 2004)
- **Copyright Holder:** Nishvanta Labs
- **Copyright Year:** 2026
- **Appendix Boilerplate:** Complete with project copyright attribution to Nishvanta Labs.
- **Customizations:** None. Official unmodified Apache-2.0 license text applied.

---

## README Alignment

PASS

- **Badge:** Added GitHub-compatible license badge (`https://img.shields.io/badge/License-Apache_2.0-blue.svg`) linked directly to `LICENSE`.
- **License Section:** Updated to explicitly state:
  ```markdown
  - **License:** [Apache-2.0](LICENSE) — see the [LICENSE](LICENSE) file for complete terms and conditions.
  ```
- **Contradiction Audit:** Ran search across `README.md` for `license`, `licensed`, `pending maintainer`, and `not selected`. Zero stale or conflicting statements remain.

---

## CONTRIBUTING Alignment

PASS

- **Contribution Terms:** Section 6 updated to state that all contributions are submitted under and governed by the Apache 2.0 license in accordance with Section 5 of the Apache License, Version 2.0.
- **Obligations:** Removed temporary "pending maintainer decision" wording.
- **No Extra Obligations:** No CLA, DCO, or extraneous contributor agreements were created or imposed.

---

## SECURITY Alignment

PASS

- **Supported Versions:** Explicitly lists supported versions (`1.0.x`, `main`).
- **Reporting Procedure:** Directs vulnerability disclosures privately to GitHub Security Advisories or maintainer contact without public issue disclosure.
- **Architecture Integrity:** Explains local-first design, no internet permission (`android.permission.INTERNET` absent), no telemetry SDKs, and SAF scoped directory access.
- **Warranties:** Contains zero unsupported claims (`100% secure`, `unhackable`, `zero vulnerabilities`).

---

## Dependency License Audit

PASS

- **Direct Dart Dependencies (7 packages):**
  - `cupertino_icons` (1.0.9): MIT
  - `flutter` (SDK 3.24+): BSD-3-Clause
  - `flutter_riverpod` (3.4.3): MIT
  - `video_player` (2.14.0): BSD-3-Clause
  - `flutter_lints` (6.0.0): BSD-3-Clause
  - `flutter_test` (SDK): BSD-3-Clause
  - `integration_test` (SDK): BSD-3-Clause
- **Transitive Dart Dependencies (46 packages):** 100% verified under permissive terms (MIT, BSD-3-Clause, Apache-2.0).
- **Native Android Dependencies:** AGP (Apache-2.0), Kotlin standard libraries (Apache-2.0), JUnit 4.13.2 (`testImplementation` only, EPL-1.0).
- **Native iOS Dependencies:** Swift Package Manager integration with Flutter framework (BSD-3-Clause). CocoaPods is absent.
- **Licensing Distinction:** Explicitly documented the boundary between the project license (Apache-2.0), third-party dependency licenses (MIT/BSD-3/Apache-2.0), and asset licenses (OFL-1.1).

---

## Third-Party Asset Audit

PASS

- **Font Asset:** `assets/fonts/PlusJakartaSans-Variable.ttf` is licensed under the SIL Open Font License 1.1 (OFL-1.1), authored by Gumpita Rahayu / Tokotype. Permitted for bundling with software under any license.
- **Brand & Graphics:** 100% of remaining image and vector assets (`assets/brand/`, `assets/icon/`, `docs/assets/`) are original creations of Nishvanta Labs for Keeva. Zero unverified third-party media exists in the repository.

---

## Trademark / WhatsApp Disclaimer

PASS

- **Brand Protection:** Under Apache-2.0 Section 6, trademark rights for "Keeva" and "Nishvanta Labs" are explicitly withheld from licensees, protecting the brand from unauthorized downstream commercial exploitation.
- **No Unsupported Symbols:** No unverified `™` or `®` symbols have been introduced.
- **WhatsApp Disclaimer:** Consistently preserved across `README.md`, `lib/presentation/settings/settings_screen.dart`, and legal documentation:
  > *"WhatsApp is a trademark of its respective owner. Keeva is an independent project and is not affiliated with or endorsed by WhatsApp or Meta."*

---

## Secrets Audit

PASS

- Automated checks executed:
  - `git grep -inE 'password|secret|api[-*]?key|private[-*]?key|access[_-]?token'`
  - `git ls-files | grep -iE '\.keystore|\.jks|key\.properties|local\.properties|\.p12|\.pem|\.mobileprovision'`
- Result: Zero passwords, API keys, private tokens, signing certificates, or keystores are tracked in Git.

---

## Path Leak Audit

PASS

- Automated checks executed:
  - `git grep -nE '/Users/|/home/|file:///|antigravity|gemini|brain/'`
  - `git grep -in "nishanth"`
- Result:
  - The only `.antigravity/` mention is an exclusion pattern in `.gitignore`.
  - Maintainer handle `nishanth` appears only in canonical public GitHub repository URLs (`https://github.com/mr-nishanth/keeva.git`).
  - Zero local workstation paths (`/Users/`, `/home/`) exist in tracked repository files.

---

## Build Verification

PASS

- `flutter build apk --debug`: **PASS** (Built `build/app/outputs/flutter-apk/app-debug.apk` in 1,829ms).
- `flutter build apk --profile`: **PASS** (Built `build/app/outputs/flutter-apk/app-profile.apk` in 1,119ms).

---

## Test Verification

PASS

- `dart format --output=none --set-exit-if-changed lib test integration_test`: **PASS** (97 files formatted, 0 changed).
- `flutter analyze`: **PASS** (No issues found).
- `flutter test`: **PASS** (210/210 unit and widget tests passed).
- `git diff --check`: **PASS** (Clean, 0 whitespace or formatting errors).

---

## GitHub Readiness

PASS / REVIEW REQUIRED

### Maintainer Security Checklist

| Feature | Recommended? | Availability | Action for Maintainer |
| :--- | :--- | :--- | :--- |
| **Dependabot Alerts** | **Yes** | Free for public repositories. | Enable in GitHub Settings (*Code security and analysis*). |
| **Dependabot Security Updates** | **Yes** | Free for public repositories. | Enable in GitHub Settings (*Code security and analysis*). |
| **Dependabot Version Updates** | **Recommended** | Free for public repositories. | Commit `.github/dependabot.yml` when automated dependency updates are desired. |
| **Secret Scanning** | **Yes** | Free for public repositories. | Enable in GitHub Settings (*Code security and analysis*). |
| **Push Protection** | **Yes** | Free for public repositories. | Enable in GitHub Settings (*Code security and analysis*). |
| **Private Vulnerability Reporting** | **Yes** | Free for public repositories. | Enable in GitHub Settings (*Code security and analysis*). |
| **Code Scanning / CI Workflow** | **Recommended** | Free for public repositories. | Set up GitHub Actions for automated pull request validation. |

### Repository Governance Decisions

- **`.github/CODEOWNERS`:** Configuration prepared for maintainer `@mr-nishanth`. Not created automatically; maintainer decision required.
- **`CODE_OF_CONDUCT.md`:** Recommended to adopt Contributor Covenant v2.1 upon public contribution opening. Not created automatically; maintainer decision required.
- **`CITATION.cff`:** **DEFERRED** (Keeva is a mobile utility application, not an academic research artifact).

---

## Application ID

`com.example.whatsapp_status_saver`

---

## Application ID Migration

NOT STARTED

*(Per project instructions, application ID, namespace, MainActivity package, and Gradle package structure remain untouched in this task).*

---

## Phase 3

NOT STARTED

*(Release engineering, production signing, Play Store configuration, and keystore generation remain deferred to Phase 3).*

---

## Phase 2I

NOT STARTED
