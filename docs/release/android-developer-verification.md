# Android Developer Verification & Distribution Readiness

**Package:** `io.nishvanta.keeva`
**Developer:** Nishvanta Labs
**Target Channel:** Google Play / F-Droid / GitHub Releases

---

## 1. Overview

Android app distribution requirements and Google Play policies require comprehensive developer identity verification, organization validation, and package ownership safeguards.

This document outlines the developer verification considerations and prerequisites that the maintainer must complete before public distribution.

---

## 2. Package Identity Verification

### 2.1 Package Name Ownership
- **Application ID:** `io.nishvanta.keeva`
- **Domain Association:** `keeva.nishvanta.io` / `nishvanta.io`
- For Google Play distribution, the package name `io.nishvanta.keeva` must be registered under the official **Nishvanta Labs** Google Play Developer Console account.
- Maintainers must ensure that no third-party entity claims or squatted the package name in targeted distribution stores prior to initial release.

### 2.2 Developer Identity Verification (Google Play Policies)
Under Google Play's developer identity requirements:
1. **Organization Verification:** The developer organization (Nishvanta Labs) must provide official registration documents, D-U-N-S (Data Universal Numbering System) number, verified business address, and contact information.
2. **Payment & Tax Verification:** Maintainer must complete merchant/tax verification profiles if applicable.
3. **Contact Email & Phone:** Publicly visible developer support email and phone numbers must be validated through two-factor authentication.
4. **App Privacy Declarations:**
   - Target audience declarations (age groups).
   - Data Safety Section: Keeva declares **Zero Data Collected** and **Zero Data Shared with Third Parties**.
   - Permissions declaration: No dangerous permissions (`MANAGE_EXTERNAL_STORAGE`, `READ_MEDIA_*`, or `INTERNET` are declared).

---

## 3. Alternative Distribution Channels

### 3.1 F-Droid / Open Source Catalog
- Because Keeva is licensed under the **Apache-2.0** license with zero proprietary dependencies and zero telemetry, it is fully eligible for inclusion in F-Droid.
- Build recipes can build Keeva directly from the upstream Git repository.
- Reproducible builds must match the official release tags.

### 3.2 Direct APK / GitHub Releases
- Maintainers can publish signed release APKs directly on GitHub Releases.
- Standalone release APKs should be accompanied by SHA-256 checksums and PGP signatures.

---

## 4. Operational Boundaries

- Automated tooling, AI agents, and CI pipelines **must never** attempt to perform account registration automatically.
- No personal identity documents or corporate registration certificates may be committed to this repository.
- Account operations remain the exclusive responsibility of human maintainers.
