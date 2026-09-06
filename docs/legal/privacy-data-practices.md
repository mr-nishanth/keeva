# Keeva Privacy & Data Practices Audit

**Product:** Keeva
**Developer:** Nishvanta Labs
**Document Version:** 1.0.0
**Effective Date:** September 2026

---

## 1. Overview & Architectural Commitment

Keeva is an offline-first, local-only personal media utility. The application is built upon a fundamental architectural commitment: **your private files and media belong solely to you, on your device, and are never harvested, monitored, or transmitted.**

This document describes the exact technical behavior of Keeva concerning user data, permissions, hardware capabilities, and operating system boundaries.

---

## 2. Technical Data Practices Audit

### 2.1 Network Connectivity & Remote Transmission
- **Network Permissions:** The Android application source manifest (`android/app/src/main/AndroidManifest.xml`) explicitly **does not request** `android.permission.INTERNET` or `android.permission.ACCESS_NETWORK_STATE`.
- **Remote Communications:** Keeva contains zero HTTP/HTTPS network client code, WebSocket clients, or background sync daemons.
- **Data Transmission:** **Zero bytes** of data, metadata, or media are transmitted off the device.

### 2.2 Telemetry, Analytics & Advertising
- **Tracking SDKs:** Keeva bundles **no advertising SDKs, tracking libraries, or user behavioral analytics** (such as Firebase Analytics, Google Analytics, Adjust, AppsFlyer, or Facebook SDK).
- **Crash Reporting:** Keeva does not integrate automated crash beacon services (such as Firebase Crashlytics or Sentry). Crash events are logged locally by the operating system (logcat / Console).
- **Diagnostics:** No identifiers (IDFA, AAID, IMEI, Android ID) are inspected or collected.

### 2.3 Storage & File Access Model
- **Android Storage Access Framework (SAF):** Keeva does not request invasive permissions like `android.permission.MANAGE_EXTERNAL_STORAGE` or legacy `READ_EXTERNAL_STORAGE`.
- **User-Controlled Scoping:** The user explicitly selects a directory via the system file picker (`OPEN_DOCUMENT_TREE`). Keeva receives a scoped tree URI allowing access only to that specific folder.
- **Persistable Permissions:** If granted, the tree URI permission is persisted locally via `ContentResolver.takePersistableUriPermission` so that re-prompting is minimized. The user can revoke this access at any time through the in-app Settings or Android App Info screen.

### 2.4 Media Handling & Kept Vault
- **Temporary Cache:** Thumbnails and video previews generated for the Moments feed are stored in the application's temporary cache directory (`Context.cacheDir`). These can be cleared at any time via the Keeva Storage Settings screen.
- **Kept Vault:** When a user chooses to "Keep" a media file, Keeva copies the file into the application's local documents directory or writes it to the public device Pictures folder via MediaStore.
- **Metadata Database:** Keeva maintains a local SQLite database (via Drift) to track favorite items, saved dates, and user-assigned tags. This database resides entirely within the app's private sandbox and is never synchronized with external servers.

### 2.5 Third-Party Dependencies
All third-party Flutter packages utilized by Keeva have been audited for privacy compliance:
- `flutter_riverpod`: Pure Dart state management (100% offline).
- `video_player` / `video_player_avfoundation`: Hardware-accelerated local video playback via system decoders.
- `cupertino_icons`: Static vector font.
- `drift` / `sqlite3`: Local on-device relational database.

---

## 3. Play Store & App Store Declarations

### 3.1 Google Play Data Safety
- **Does your app collect or share any user data?** No.
- **Is all user data encrypted in transit?** Not applicable (no data collected or transmitted).
- **Does your app provide a way for users to request data deletion?** Since zero data is stored remotely, users can delete all local data by clearing the app cache/storage or uninstalling the app.

### 3.2 Apple App Store App Privacy
- **Data Used to Track You:** None.
- **Data Linked to You:** None.
- **Data Not Linked to You:** None.
