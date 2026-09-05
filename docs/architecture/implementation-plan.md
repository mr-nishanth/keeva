# Implementation Plan: WhatsApp Status Saver

**Document Status:** Implementation Roadmap  
**Target Platform:** Android (API 29 – 36), Primary Physical Target: Xiaomi 2311DRK48I (Android 16 / HyperOS 3.0)  
**Authors:** Senior Mobile & Platform Architecture Team  
**Date:** September 2026  

---

## 1. Overview & Staged Roadmap

The production implementation is broken into small, testable, and verifiable phases in strict accordance with `AGENTS.md` and the approved architecture in `docs/architecture/production-architecture.md`.

Each phase defines:
- **Goal**
- **Files Changed**
- **Deliverables**
- **Verification Commands**
- **Git Commit Target**

---

## 2. Implementation Phases

### Phase 2A: Architecture Specification & Contracts (CURRENT)
- **Goal:** Complete the production architecture specification, platform channel contracts, domain models, and implementation roadmap.
- **Files Created/Modified:**
  - `docs/architecture/production-architecture.md`
  - `docs/architecture/implementation-plan.md`
- **Verification:**
  - Review documentation against `AGENTS.md`, `CLAUDE.md`, and `docs/android/storage-access.md`.
- **Git Commit:** `docs: add production architecture and implementation plan`

---

### Phase 2B: Production Native Storage Layer (Android/Kotlin)
- **Goal:** Extract POC logic from `MainActivity.kt` into modular native components under `android/.../status/` with background Coroutine execution and atomic MediaStore saving.
- **Files to Create/Modify:**
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/MainActivity.kt` (Refactor to slim launcher)
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/SafStorageManager.kt`
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/StatusDocumentReader.kt`
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/MediaStoreSaver.kt`
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/ThumbnailManager.kt`
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/VideoCacheManager.kt`
  - `android/app/src/main/kotlin/com/example/whatsapp_status_saver/status/AndroidStatusScanner.kt`
- **Verification:**
  - `flutter build apk --debug`
  - Unit tests for native string/URI utilities.
- **Git Commit:** `feat(android): implement modular status storage and media saving layer`

---

### Phase 2C: Flutter Platform, Core & Domain Layers
- **Goal:** Build the typed platform channel boundary, domain entities, repository interfaces, use cases, DTOs, and error mapping in pure Dart.
- **Files to Create:**
  - `lib/core/errors/app_failure.dart`
  - `lib/core/result/result.dart`
  - `lib/core/constants/app_constants.dart`
  - `lib/domain/entities/status_item.dart`
  - `lib/domain/entities/saved_media.dart`
  - `lib/domain/entities/storage_access_state.dart`
  - `lib/domain/repositories/status_repository.dart`
  - `lib/domain/repositories/saved_media_repository.dart`
  - `lib/domain/use_cases/check_storage_access_use_case.dart`
  - `lib/domain/use_cases/request_storage_access_use_case.dart`
  - `lib/domain/use_cases/get_statuses_use_case.dart`
  - `lib/domain/use_cases/get_thumbnail_use_case.dart`
  - `lib/domain/use_cases/save_status_use_case.dart`
  - `lib/domain/use_cases/prepare_video_playback_use_case.dart`
  - `lib/data/models/status_dto.dart`
  - `lib/data/models/saved_media_dto.dart`
  - `lib/data/datasources/status_platform_datasource.dart`
  - `lib/data/repositories/status_repository_impl.dart`
  - `lib/platform/status_scanner_platform_interface.dart`
  - `lib/platform/method_channel_status_scanner.dart`
  - `lib/platform/channel_constants.dart`
- **Verification:**
  - `flutter analyze`
  - `flutter test` (Unit tests for DTO parsing, entity immutability, repository mapping)
- **Git Commit:** `feat: implement domain models, repository contracts, and platform boundary`

---

### Phase 2D: State Management & Application Layer
- **Goal:** Integrate `flutter_riverpod` and implement state notifiers with sealed states for access, status discovery, and saving.
- **Dependencies Added:**
  - `flutter_riverpod`
- **Files to Create:**
  - `lib/application/access/access_state.dart`
  - `lib/application/access/access_notifier.dart`
  - `lib/application/statuses/status_list_state.dart`
  - `lib/application/statuses/status_list_notifier.dart`
  - `lib/application/saver/save_state.dart`
  - `lib/application/saver/save_notifier.dart`
  - `lib/application/providers.dart`
- **Verification:**
  - Unit tests covering state transitions (`access_notifier_test.dart`, `status_list_notifier_test.dart`).
- **Git Commit:** `feat(application): implement riverpod state notifiers and sealed states`

---

### Phase 2E: Design System & Status Discovery UI
- **Goal:** Implement the app theme tokens, onboarding permission sheet, status grid, card widgets, and empty/error states.
- **Files to Create:**
  - `lib/app/theme/app_theme.dart`
  - `lib/app/theme/app_colors.dart`
  - `lib/app/theme/app_typography.dart`
  - `lib/app/theme/app_spacing.dart`
  - `lib/presentation/common/loading_indicator.dart`
  - `lib/presentation/common/empty_state_view.dart`
  - `lib/presentation/common/error_state_view.dart`
  - `lib/presentation/onboarding/permission_guide_sheet.dart`
  - `lib/presentation/statuses/status_screen.dart`
  - `lib/presentation/statuses/widgets/status_grid.dart`
  - `lib/presentation/statuses/widgets/status_card.dart`
  - `lib/presentation/statuses/widgets/thumbnail_image.dart`
  - `lib/main.dart` (Bootstrapped with `ProviderScope` and production theme)
- **Verification:**
  - `flutter analyze`
  - `flutter test` (Widget tests for status screen rendering in loading, empty, error, and populated states)
- **Git Commit:** `feat(ui): implement design system, onboarding sheet, and status grid`

---

### Phase 2F: Native Thumbnail Pipeline Verification
- **Goal:** Connect native thumbnail generator with Flutter `thumbnail_image.dart` widget with disk caching and smooth scrolling.
- **Verification:**
  - Test on Xiaomi 2311DRK48I: verify thumbnail generation latency < 50ms per item and zero memory leaks.
- **Git Commit:** `feat(thumbnail): integrate background thumbnail decoding and disk cache`

---

### Phase 2G: Full Media Viewer (Image & Video)
- **Goal:** Build full-screen interactive image viewer (with pan/zoom) and video player (with hardware acceleration and custom playback controls).
- **Dependencies Added:**
  - `video_player`
- **Files to Create:**
  - `lib/presentation/viewer/media_viewer_screen.dart`
  - `lib/presentation/viewer/widgets/image_viewer.dart`
  - `lib/presentation/viewer/widgets/video_viewer.dart`
  - `lib/presentation/viewer/widgets/viewer_controls.dart`
- **Verification:**
  - Test image zooming and video playback on physical device.
- **Git Commit:** `feat(viewer): implement media viewer with zoomable image and video player`

---

### Phase 2H: Production MediaStore Saving Flow
- **Goal:** Connect UI "Save" actions to the native `MediaStoreSaver` for both photos and videos with success feedback and atomic rollback.
- **Verification:**
  - Save an image status and a video status; verify entries appear in device Gallery under `Pictures/SavedStatus` and `Movies/SavedStatus`.
- **Git Commit:** `feat(save): implement production media saving to gallery via MediaStore`

---

### Phase 2I: Saved Media Tab & Local Persistence
- **Goal:** Track saved status IDs, display a dedicated "Saved" tab, and support re-sharing or opening saved media.
- **Dependencies Added:**
  - `shared_preferences`
- **Files to Create:**
  - `lib/presentation/saved/saved_screen.dart`
  - `lib/presentation/saved/widgets/saved_grid.dart`
  - `lib/data/datasources/saved_local_datasource.dart`
- **Verification:**
  - Unit tests for saved item tracking and widget tests for saved screen.
- **Git Commit:** `feat(saved): add saved media library and local persistence`

---

### Phase 2J: Physical Device QA & Verification
- **Goal:** Complete exhaustive end-to-end regression testing on the physical **Xiaomi 2311DRK48I (Android 16 / HyperOS 3.0)**.
- **Verification Checklist:**
  - Clean install from scratch.
  - Onboarding permission guide and SAF picker launch.
  - Media discovery and thumbnail grid loading.
  - Image view and zoom.
  - Video play, scrub, pause, resume.
  - MediaStore export of image and video.
  - App kill (`am force-stop`) and relaunch (`am start`) with persisted access.
- **Deliverables:**
  - Updated `walkthrough.md` with physical screenshots and execution log.
- **Git Commit:** `test(qa): physical device verification on Xiaomi Android 16`

---

### Phase 2K: Edge Cases, Error Recovery & Hardening
- **Goal:** Handle edge cases: permission revocation, WhatsApp folder deletion/renaming, corrupt media files, memory pressure.
- **Verification:**
  - Revoke tree permission from Android App Settings, reopen app, verify recovery UI prompts user to re-grant access.
- **Git Commit:** `fix(recovery): enhance error recovery and edge case handling`

---

### Phase 2L: Release Preparation
- **Goal:** Verify release APK compilation, ProGuard rules, edge-to-edge compliance, and documentation synchronization.
- **Verification Commands:**
  - `flutter analyze`
  - `flutter test`
  - `flutter build apk --release`
- **Git Commit:** `chore(release): verify production release build and update documentation`

---

## 3. Definition of Done per Phase

A phase is only complete when:
1. Implementation matches the specification in `docs/architecture/production-architecture.md`.
2. Architecture boundaries remain intact.
3. No extraneous dependencies were introduced.
4. Code formatted with `dart format .`.
5. `flutter analyze` passes with 0 issues.
6. Relevant unit/widget tests pass via `flutter test`.
7. `flutter build apk --debug` builds cleanly.
8. Git diff is clean and scoped strictly to the phase deliverables.
