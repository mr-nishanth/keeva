# Keeva CI Architecture & iOS Automation Strategy Decision

**Product:** Keeva
**Developer:** Nishvanta Labs
**Date:** September 2026
**Status:** Approved Architectural Decision

---

## 1. CI Scope & Pipeline Boundaries

### Current Pipeline Scope: Continuous Verification Only
The Keeva GitHub Actions CI pipeline is strictly scoped to:
1. **Compliance & Safety:** Secret scanning, absence of sensitive permissions (`INTERNET`, `MANAGE_EXTERNAL_STORAGE`), package namespace verification, license validation.
2. **Quality & Formatting:** `dart format` and `flutter analyze` lint checks.
3. **Automated Testing:** Flutter unit and widget tests, Android native JVM tests.
4. **Release Build Validation:** Building release APK and AAB with fallback signing to verify packaging, size, and badging integrity.
5. **Artifact Retention:** Ephemeral build artifact storage (3-day retention).

### Explicit Non-Goals for Current Pipeline
- **No Automated Publishing:** The CI pipeline must **not** upload to Google Play Console or Apple App Store Connect.
- **No Production Credentials in CI:** Production keystores, signing certificates, and App Store Connect API keys remain air-gapped outside version control and pull request environments.

---

## 2. iOS CI/CD Architecture Evaluation

Automating iOS builds and distribution presents distinct architectural trade-offs compared to Android. Below is an evaluation of the three primary paths:

### Option A: Local Xcode Release Workflow (Recommended for Initial Release)
- **Mechanism:** Builds and archives are generated locally on an authorized macOS development workstation using Xcode Organizer.
- **Cost:** $0 additional infrastructure cost (uses developer workstation).
- **Complexity:** Low. No external secret management or remote macOS runners required.
- **Secrets Management:** Highest security. Apple Distribution Certificates and Private Keys remain in the local macOS Keychain / Secure Enclave; zero secrets exposed to cloud CI.
- **Reliability:** High. Immediate feedback during Xcode archive validation.
- **Maintenance:** Minimal. No GitHub Actions macOS runner configuration to maintain.
- **TestFlight Automation:** Semi-automated (manual upload via Xcode Organizer or `xcrun altool`).

### Option B: GitHub Actions macOS Runner with Fastlane / Match
- **Mechanism:** Executes `macos-latest` runners on GitHub Actions, decrypting certificates via Fastlane Match or encrypted base64 secrets.
- **Cost:** High (macOS runners on GitHub Actions are billed at 10x standard Linux minute rates; $0.08/min).
- **Complexity:** High. Requires provisioning profile sync, Keychain unlocking scripts, and App Store Connect API key provisioning.
- **Secrets Management:** Moderate risk. Requires uploading Apple Distribution Certificate (`.p12`) and App Store Connect API private keys (`.p8`) into GitHub Secrets.
- **Reliability:** Moderate. Prone to macOS runner image version discrepancies and CocoaPods cache flakiness.
- **Maintenance:** Moderate to high. Ongoing Xcode version pinning and certificate renewal maintenance.
- **TestFlight Automation:** Fully automated upon merging to `main` or triggering release tags.

### Option C: Xcode Cloud
- **Mechanism:** Apple's native continuous integration and delivery service integrated directly with App Store Connect and Xcode.
- **Cost:** Free tier includes 25 compute hours/month with Apple Developer Program membership.
- **Complexity:** Low to moderate. Configured directly in Xcode with native Apple ID integration.
- **Secrets Management:** Highest security for cloud builds. Certificates and provisioning profiles are managed natively by Apple within App Store Connect; zero external certificate handling.
- **Reliability:** High for pure Apple ecosystem builds.
- **Maintenance:** Low. Managed directly by Apple.
- **TestFlight Automation:** Fully automated direct deployment to TestFlight groups upon Git commit or tag.

---

## 3. Recommendation & Roadmap

### Initial Public Release (Phase 3C / 4A): **Option A (Local Xcode Release Workflow)**
For the initial release of Keeva, Nishvanta Labs will use **Option A**.
- Rationale: Air-gaps all Apple signing certificates, incurs zero CI cost, and provides maximum developer control during the initial App Review validation cycle.

### Future Automation (Phase 4B+): **Option C (Xcode Cloud) or Option B**
Once the initial App Store release is approved and operational cadences require automated nightly or weekly TestFlight distribution:
- **Xcode Cloud (Option C)** is the preferred future automation path because it avoids managing macOS runners and storing private distribution certificates in GitHub.
