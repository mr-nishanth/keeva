# Keeva Platform Feature Matrix (Android vs iOS)

**Document Version:** 1.0.0
**Date:** September 2026
**Product:** Keeva
**Status:** Audit & Parity Evaluation

---

## 1. Executive Summary

Keeva was originally architected as an Android-first media utility leveraging the Android Storage Access Framework (SAF) to inspect and manage ephemeral WhatsApp status media.

Because Apple iOS strictly isolates application data via sandbox containers and does not expose a shared filesystem directory where third-party apps store status files, status discovery and direct external media directory scanning are architecturally restricted on iOS.

This matrix documents the verified functional capabilities across Android and iOS platforms.

---

## 2. Feature Comparison Matrix

| Feature | Android | iOS | Notes |
|---|---|---|---|
| **Local Offline Execution** | **PASS** | **PASS** | Pure on-device processing; zero network dependencies or remote API requirements on both platforms. |
| **Design System & Typography** | **PASS** | **PASS** | Plus Jakarta Sans variable font, custom tokenized color palette, responsive layout builder render identically across platforms. |
| **Theme Switching (Light/Dark/System)** | **PASS** | **PASS** | Managed via pure Riverpod application state; respects platform brightness and persists preferences locally. |
| **Onboarding Experience** | **PASS** | **PASS** | Educational slides and brand value presentation render cleanly on both mobile platforms. |
| **Full-Screen Image Viewer** | **PASS** | **PASS** | Native image rendering, pan/zoom interactive viewer, and overlay UI function across Android and iOS. |
| **Full-Screen Video Playback** | **PASS** | **PASS** | Uses `video_player` with native ExoPlayer backend on Android and native AVPlayer backend (`video_player_avfoundation`) on iOS. |
| **Media Sharing** | **PASS** | **PASS** | Intent-based sharing on Android via `ACTION_SEND`; system sheet sharing on iOS via `UIActivityViewController`. |
| **Kept Vault (Local Persistence)** | **PASS** | **PASS** | Local SQLite database via Drift and file persistence in application documents sandbox directory function on both platforms. |
| **WhatsApp Status Discovery** | **PASS** | **BLOCKED** | Android uses Storage Access Framework (`.Statuses` tree URI). iOS app sandbox prevents any third-party app from reading WhatsApp's private data container. |
| **WhatsApp Media Directory Access** | **PASS** | **BLOCKED** | iOS has no shared `/Android/media/` directory structure; WhatsApp on iOS does not expose status files to external apps. |
| **SAF Folder Selection** | **PASS** | **NOT IMPLEMENTED** | Storage Access Framework (`OPEN_DOCUMENT_TREE`) is an Android-specific OS API. iOS Document Picker (`UIDocumentPickerViewController`) cannot target private app folders. |
| **Background Status Scanning** | **PASS** | **NOT IMPLEMENTED** | Native Kotlin scanner plugin (`MethodChannelStatusScanner`) executes only on Android; no equivalent iOS native channel implementation exists. |
| **Persistent Tree URI Permissions** | **PASS** | **NOT IMPLEMENTED** | `takePersistableUriPermission` is an Android-exclusive ContentResolver mechanism. |
| **Export to Device Gallery / Photos** | **PASS** | **PARTIAL** | Android saves directly to SAF MediaStore/Pictures. iOS requires `NSPhotoLibraryAddUsageDescription` permission configuration to write to Camera Roll. |
| **Legal, Privacy & About Pages** | **PASS** | **PASS** | Static informational views, open-source license attestations, and privacy policy screens operate identically. |

---

## 3. Platform Architecture Implications

### 3.1 Android Strengths
- Full compliance with Android 11+ (API 30–36) Scoped Storage guidelines via user-granted SAF tree URIs.
- Complete background caching, thumbnail downscaling, and zero-permission media saving to public device storage.

### 3.2 iOS Technical Constraints & Product Strategy
- **Sandboxing Barrier:** iOS does not provide public filesystem access to WhatsApp's temporary cache. As a result, automated or SAF-style status discovery is fundamentally unavailable on iOS.
- **Future iOS Direction:** For iOS, Keeva can serve as a private media vault and organizer where users manually import media from Camera Roll or Files, rather than claiming automated WhatsApp status interception.
- **Store Review Safeguard:** Attempting to imply automated WhatsApp status scraping on iOS would result in App Store Review rejection under Apple App Store Review Guideline 2.1 (Performance / Completeness) and Guideline 2.5 (Software Requirements).
