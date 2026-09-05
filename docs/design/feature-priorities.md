# Feature Priority Matrix & Implementation Roadmap

**Product:** Keeva (WhatsApp Status Saver → New Product Identity)  
**Document Status:** Approved Feature Priorities & Non-Functional Specifications  
**Design Phase:** Phase 2E-A (Product Brand & UI/UX Design System)  
**Authors:** Senior Technical Product Manager & Mobile Engineering Lead  
**Date:** September 2026  

---

## 1. MoSCoW Feature Prioritization

To ensure disciplined execution and protect the core user experience, all candidate capabilities are categorized under the MoSCoW framework.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             MoSCoW FRAMEWORK                                │
├──────────────────────────────┬──────────────────────────────────────────────┤
│ MUST HAVE (P0 - Launch)      │ SHOULD HAVE (P1 - V1 Polish)                 │
│ • SAF 3-step onboarding guide│ • Smart Inbox Freshness Filters (Photos/Vid) │
│ • Native background scanner  │ • Original Quality Integrity Display         │
│ • Obsidian + Aurora UI theme │ • Multi-select batch Keep with duplicate sum │
│ • 9:16 media-first grid      │ • Storage footprint & cache cleanup in prefs │
│ • Signature Keep action      │ • Custom animated checkmark & haptic pulses  │
│ • Duplicate Shield           │ • Adaptive navigation rail on tablet/land.   │
│ • Immersive photo & video view                                              │
│ • Zero-permission MediaStore │                                              │
├──────────────────────────────┼──────────────────────────────────────────────┤
│ COULD HAVE (P2 - V1.1/V1.2)  │ WON'T HAVE (Strictly Excluded)               │
│ • Moment Replay story view   │ ✕ Cloud sync or remote account backup        │
│ • WhatsApp Business dual-tab │ ✕ Advertising networks / tracking SDKs      │
│ • 4-hour Expiring Soon radar │ ✕ Direct chat tools / spam utility bundles   │
│ • Custom keepsake album tags │ ✕ Modded WhatsApp / GB integration           │
│ • Automatic scheduled cleanup│ ✕ Video trimming / meme editing tools        │
└──────────────────────────────┴──────────────────────────────────────────────┘
```

---

## 2. Feature-to-Phase Implementation Mapping

This table connects every approved product capability directly to the staged phases defined in `docs/architecture/implementation-plan.md`.

| Phase | Phase Name | Primary Feature Deliverables | Verification Target |
| :--- | :--- | :--- | :--- |
| **Phase 2E-A** | Brand & Design System *(CURRENT)* | Product identity, naming, design tokens, UI/UX specs, asset inventory, SVGs, app icon. | Design review approval; zero code regressions. |
| **Phase 2B** | Production Native Storage Layer | Refactor `MainActivity.kt` into `SafStorageManager`, `StatusDocumentReader`, `MediaStoreSaver`, `ThumbnailManager`. | `flutter build apk --debug`; native Coroutines verified. |
| **Phase 2C** | Platform & Domain Layer | Pure Dart domain models (`StatusItem`, `SavedMedia`), use cases, typed `MethodChannel` boundary. | `flutter analyze`; unit tests for repository contracts. |
| **Phase 2D** | State Management Layer | `flutter_riverpod` state notifiers, sealed state machines (`AccessState`, `StatusListState`, `SaveState`). | Unit tests covering state transitions. |
| **Phase 2E** | Status Discovery UI | Theme tokens (`AppTheme`, `AppColors`), 3-step onboarding guide, Moments grid, status cards. | Widget tests for loading, empty, and populated states. |
| **Phase 2F** | Native Thumbnail Pipeline | Connect `ThumbnailManager` (sub-50ms bitmap decode) to Flutter grid with smooth 120Hz scrolling. | Verified on Xiaomi 2311DRK48I (zero frame drops). |
| **Phase 2G** | Full Media Viewer | Immersive edge-to-edge photo viewer (zoom/pan) and video player (stream cache + controls). | Video scrub and photo zoom verified on physical device. |
| **Phase 2H** | MediaStore Saving Flow | Connect Signature Keep action to native `MediaStoreSaver` with Duplicate Shield verification. | Photo and video appear in device gallery without permissions. |
| **Phase 2I** | Kept Library & Persistence | Chronological "Kept" tab, local saved ledger, storage footprint calculation. | Unit & widget tests for saved library. |
| **Phase 2J** | Physical Device QA | Full end-to-end regression audit on Xiaomi 2311DRK48I (Android 16 / HyperOS 3.0). | Clean install to save cycle verified in `walkthrough.md`. |
| **Phase 2K** | Error Recovery Hardening | Handle folder renames, SAF tree permission revocation, memory pressure under 100+ videos. | Recovery UI tested via manual revocation. |
| **Phase 2L** | Release Preparation | ProGuard rules, 16 KB page size verification, final release APK compilation. | `flutter build apk --release` clean pass. |

---

## 3. Non-Functional Requirements & Performance Budgets

To achieve the "calm, fast, trustworthy" brand promise, Keeva enforces strict technical performance thresholds:

### 3.1 Frame Budgets & Rendering
- **Scroll Rate:** Continuous 60fps on 60Hz displays and 120fps on 120Hz AMOLED displays (Xiaomi 2311DRK48I).
- **Frame Budget:** Maximum 8.3ms per frame during active fling gestures.
- **Isolate Offloading:** Zero synchronous disk I/O or image decoding on the main Flutter UI isolate. All thumbnail generation occurs on native background worker threads (`Dispatchers.IO`).

### 3.2 Memory & Storage Footprint
- **Thumbnail Memory Cap:** Maximum 35 MB RAM allocated to thumbnail memory cache in Flutter `ImageCache`; entries evicted via LRU policy when threshold is reached.
- **Thumbnail Disk Cache Cap:** Maximum 100 MB disk space allocated to downsampled WebP thumbnails in internal cache (`context.cacheDir/thumbnails/`), managed via LRU eviction (80 MB target).
- **Video Playback Cache Cap:** Maximum 100 MB disk space allocated to temporary playback stream buffers in internal cache (`context.cacheDir/videos/`), managed via bounded LRU eviction (75 MB target).
- **One-Tap Flush:** Temporary caches can be fully purged by the user in Settings without touching saved gallery media.

### 3.3 Zero-Network Security Guarantee
- **Manifest Restrictions:** The production `AndroidManifest.xml` must **never** declare `android.permission.INTERNET` or `android.permission.ACCESS_NETWORK_STATE`.
- **Zero Third-Party Trackers:** No Firebase Analytics, no Facebook SDK, no AdMob, no telemetry libraries. All crash reports remain strictly local.

### 3.4 Accessibility (WCAG 2.2 AA)
- **Minimum Tap Targets:** All touch targets must be at least 48×48dp.
- **Contrast Ratios:** Minimum 4.5:1 for body copy and 3.0:1 for graphical elements and large headers.
- **Dynamic Text Support:** UI must scale gracefully up to 200% system font size without truncation of primary actions or critical metadata.
