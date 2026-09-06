# Keeva Dual-Platform Release Strategy

**Product:** Keeva
**Developer:** Nishvanta Labs
**Android Application ID:** `io.nishvanta.keeva`
**iOS Bundle Identifier (Proposed):** `io.nishvanta.keeva`
**License:** Apache-2.0

---

## 1. Overview & Objectives

This document formalizes the production distribution and release strategy for Keeva across both primary mobile platforms: **Google Play Store (Android)** and **Apple App Store (iOS)**.

The strategy adheres to strict architectural, operational, and privacy standards:
1. **Zero Secret Persistence:** Cryptographic keystores, Apple certificates, provisioning profiles, API tokens, and passwords must never be committed to Git or stored in public repositories.
2. **Deterministic Versioning:** Continuous synchronization between `pubspec.yaml`, Android Gradle build numbers, and iOS Xcode project definitions.
3. **Decoupled Distribution Key Management:** Leveraging platform-managed app signing (Google Play App Signing) and Apple Developer distribution certificates.
4. **Gradual Staged Rollout:** Enforcing testing gates through internal tracks (Play Internal Testing, TestFlight) prior to general public release.

---

## 2. Android Release Strategy (Google Play)

### 2.1 Distribution Artifact: Android App Bundle (.aab)
- Keeva is packaged and published exclusively as an **Android App Bundle (`.aab`)**.
- Monolithic universal APKs are prohibited for Play Store distribution.
- Google Play's Dynamic Delivery system decomposes the AAB into device-tailored split APKs (optimizing native ABI binaries `arm64-v8a`, `armeabi-v7a`, `x86_64`, and screen density assets), reducing download size for end users.

### 2.2 Signing Architecture: Google Play App Signing
Keeva utilizes **Google Play App Signing**, which cleanly separates developer upload credentials from end-user delivery signatures:

```text
+-------------------------------------------------------------+
|                       Developer / CI                        |
|                                                             |
|   Upload Keystore (`upload-keystore.jks`)                   |
|   Stored off-repository in local HSM / secure secrets vault |
+-------------------------------------------------------------+
                              |
                              | Signs Release Bundle (.aab)
                              v
+-------------------------------------------------------------+
|                     Google Play Console                     |
|                                                             |
|   1. Verifies artifact signature using Upload Certificate    |
|   2. Strips upload key signature                            |
|   3. Re-signs optimized APK splits with App Signing Key     |
+-------------------------------------------------------------+
                              |
                              | Distributes Signed APKs
                              v
+-------------------------------------------------------------+
|                      End-User Device                        |
|                                                             |
|   Installs split APKs verified by Google Play signature     |
+-------------------------------------------------------------+
```

### 2.3 Upload Key Management & Rotation
- **Upload Keystore:** Generated locally with RSA 4096-bit (or EC P-256) and minimum 25-year validity.
- **Local Developer Configuration:** Loaded via uncommitted `android/key.properties`. If absent, Gradle safely falls back to local debug signing to allow CI validation and open-source testing without exposing credentials.
- **Key Rotation Protocol:** If an upload key is compromised or lost, the registered account owner contacts Google Play Support to register a replacement upload certificate. Because Google Play retains the master App Signing Key, existing user installations are never orphaned.
- **Console Ownership:** Maintained by the authorized Nishvanta Labs organization account.

### 2.4 Android Versioning Governance
- **`versionName`:** Matches semantic version in `pubspec.yaml` (e.g., `1.0.0`).
- **`versionCode`:** Strictly increasing integer derived from `pubspec.yaml` build number (e.g., `+1` -> `1`).
- Every upload to Google Play requires a unique, higher `versionCode`.

### 2.5 Release Tracks & Promotion Workflow
1. **Internal Testing Track:** Direct upload of release AAB for Nishvanta Labs QA team and verified testers.
2. **Closed Testing (Alpha):** Small-scale dogfooding group (minimum 20 testers for 14 days per Google Play policy).
3. **Open Testing (Beta):** Optional public opt-in testing.
4. **Production Release:** Phased rollout starting at 10% -> 25% -> 50% -> 100% over 7 days to monitor crash-free sessions.

---

## 3. iOS Release Strategy (Apple App Store)

### 3.1 Distribution Channel: App Store Connect
- Distribution is conducted exclusively through **App Store Connect** and the iOS App Store.
- Ad-hoc and enterprise distribution profiles are not used for production distribution.

### 3.2 Identity & Bundle Identifier
- **Proposed Bundle Identifier:** `io.nishvanta.keeva`
- **Application Display Name:** `Keeva`
- **RunnerTests Bundle Identifier:** `io.nishvanta.keeva.RunnerTests`
- The legacy template identifier (`com.example.whatsappStatusSaver`) is strictly prohibited for App Store submission as Apple rejects `com.example` prefixes.

### 3.3 iOS Versioning Alignment
- **`MARKETING_VERSION` (CFBundleShortVersionString):** Tied directly to Flutter build name (`1.0.0`).
- **`CURRENT_PROJECT_VERSION` (CFBundleVersion):** Tied to Flutter build number (`1`).
- Synced automatically through `flutter build ios` and Xcode build settings.

### 3.4 Code Signing Architecture
- **Distribution Certificate:** Apple Distribution Certificate managed by Nishvanta Labs in the Apple Developer Program.
- **Provisioning Profile:** App Store Distribution Provisioning Profile matching `io.nishvanta.keeva`.
- **Signing Execution:** Performed via manual signing in local Xcode release workflow or through automated Xcode Cloud / Fastlane pipelines using Apple App Store Connect API keys.
- **Off-Repository Storage:** Private `.p12` certificates, `.mobileprovision` profiles, and `.p8` API keys must never be stored in Git.

### 3.5 iOS Release & Review Workflow
1. **Xcode Archive:** Build an optimized release archive (`xcarchive`) with Bitcode disabled (deprecated by Apple) and stripped symbols.
2. **Validation:** Run Xcode Archive Validation (`xcrun altool` / `xcrun notarytool` / Xcode Organizer) against App Store submission rules.
3. **TestFlight Internal Testing:** Immediate availability for up to 100 internal organization members.
4. **TestFlight External Testing:** Beta testing for external users requiring standard Apple Beta App Review.
5. **App Store Review Submission:** Final submission accompanied by App Privacy Details, Data Safety declarations, and review demonstration credentials/instructions.
6. **Release Execution:** Phased release over 7 days once approved by App Review.

---

## 4. Credential & Operational Security Safeguards

1. **No Keystores or Certificates in Git:**
   Enforced by `.gitignore` rules targeting `*.jks`, `*.keystore`, `*.p12`, `*.cer`, `*.p8`, `*.mobileprovision`, `key.properties`, and `local.properties`.
2. **Zero Ingestion into Public CI:**
   Public CI workflows validate code, formatting, tests, and build generation using fallback/ephemeral keys. Production signing keys remain air-gapped from untrusted pull request environments.
3. **Offline Backup:**
   Production keystores and certificates must be stored in redundant, encrypted hardware or credential vault systems with multi-party recovery options.
