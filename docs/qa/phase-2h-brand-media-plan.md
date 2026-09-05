# Keeva Phase 2H: Brand Identity, Launch Experience & Media UX Polish Plan

## 1. Executive Summary

Phase 2H transitions the Keeva application from a functionally proven prototype into a fully branded, production-grade Android application.

Key objectives:
1. **App Identity**: User-facing application label set to **Keeva** across all Android system surfaces (Launcher, Settings, Recent Apps, Install Dialog).
2. **Android Adaptive & Themed Icon**: Full Android 8.0+ adaptive icon and Android 13+ themed icon (monochrome silhouette) with Quiet Obsidian background and Aurora aperture ribbon.
3. **Android 12+ Splash Screen**: Android SplashScreen API integration with `#090B0E` Quiet Obsidian background and centered Keeva logo mark, ensuring zero startup flash or layout jump.
4. **Onboarding UX**: Refined first-launch onboarding with Keeva brand mark, calm messaging ("Welcome to Keeva", "Your private place for the moments you want to keep", "100% On-Device • Zero Network • Private by Design"), and step-by-step SAF guide.
5. **Kept Vault Persistence**: Validation on physical hardware (Xiaomi POCO X6 Pro 5G) that saved media persists across complete process termination (`am force-stop`).
6. **High-Resolution Image Viewer**: Immersive edge-to-edge photo canvas with 1440p resolution decoding, 1:1 drag-to-dismiss, spring physics, and tap-to-toggle chrome.
7. **Hardware-Accelerated Video Player UX**: Integration of `package:video_player` with cached local video streaming, custom Keeva-styled controls (play/pause, scrub slider, tabular time indicators, mute toggle, replay), single-tap chrome toggling, and leak-free lifecycle pause/dispose.
8. **Physical Hardware Verification**: Execution on Xiaomi POCO X6 Pro 5G (Android 16 / HyperOS 2.0) with captured screenshot evidence.

---

## 2. Architecture Preservation

The existing feature-oriented architecture remains 100% intact:

```text
Presentation (Widgets, Shell, Themes)
    ↓
Application (Riverpod Notifiers & States)
    ↓
Domain (Entities & Use Cases)
    ↓
Repositories (StatusRepository Contracts)
    ↓
Data / Platform (Platform Datasources, MethodChannel)
    ↓
Native Android (Kotlin: SafStorageManager, StatusDocumentReader, MediaStoreSaver, VideoCacheManager, ThumbnailManager)
```

No architectural boundaries are bypassed.

---

## 3. Implementation Breakdown

### 3.1 Android Branding & Icons
- `android:label="@string/app_name"` in `AndroidManifest.xml`
- `strings.xml` with `<string name="app_name">Keeva</string>`
- Adaptive icon drawables in `res/mipmap-anydpi-v26/` (`ic_launcher.xml`, `ic_launcher_round.xml`)
- Background, foreground, and monochrome drawables in `res/drawable/`
- Raster mipmap icons (mdpi to xxxhdpi) generated via `sips`

### 3.2 Android 12+ Splash Screen
- `res/values-v31/styles.xml` and `res/values-night-v31/styles.xml` with `android:windowSplashScreenBackground` and `android:windowSplashScreenAnimatedIcon`
- `res/drawable/splash_icon.xml` vector drawable
- Legacy `launch_background.xml` update to eliminate startup flash on older Android versions

### 3.3 First-Launch Onboarding
- Branded header with logo mark and Aurora glow
- Structured 3-step SAF guide
- Privacy & Local-first guarantee badge

### 3.4 Media Viewer & Video Player
- Full resolution image loading via `ThumbnailManager` (1440p)
- First-party `video_player: ^2.9.2` dependency
- `KeevaVideoPlayer` with custom controls and lifecycle awareness
- Disposed playback on viewer dismissal

### 3.5 Verification & Deliverables
- `dart format` & `flutter analyze`
- Unit and widget tests (`flutter test`)
- Physical device integration tests
- Debug and Profile APK builds
- Physical screenshots on POCO X6 Pro 5G
- Final reports: `phase-2h-brand-media-report.md`, `phase-2h-device-matrix.md`
