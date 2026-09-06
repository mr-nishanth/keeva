# Production Architecture: WhatsApp Status Saver

**Document Status:** Approved Architecture Specification
**Target Platform:** Android (API 29 – 36 / Android 10 – 16), iOS (secondary)
**Primary Test Target:** Xiaomi 2311DRK48I (`duchamp_in`) | Android 16 (API 36) | HyperOS 3.0
**Authors:** Senior Mobile & Platform Architecture Team
**Date:** September 2026

---

## 1. Executive Overview

This document specifies the production architecture for the **WhatsApp Status Saver** Flutter application.

The platform feasibility was empirically validated during Phase 1 on a physical **Xiaomi 2311DRK48I** running **Android 16 (API 36 / HyperOS 3.0)** via Storage Access Framework (SAF) and MediaStore (`docs/android/storage-access.md`).

This architecture transitions the codebase from the initial Proof of Concept (POC) into a production-grade, modular, testable, and secure mobile application.

---

## 2. Architectural Principles

1. **Strict Platform Boundary:** The Flutter UI layer must **never** know about:
   - Android Storage Access Framework (SAF)
   - `DocumentsContract`
   - `ContentResolver`
   - `content://` URIs
   - `MediaStore`
   - Android document IDs
   - Android-specific storage paths
   - Persisted URI permission details
2. **Domain-Centric Design:** Flutter operates on pure, platform-independent domain models (`StatusItem`, `SavedMedia`, `StorageAccessState`).
3. **Unidirectional Data Flow:** State flows downward to the UI; user events flow upward to controllers/use cases.
4. **Resilient Native Integration:** Platform interactions are mediated through a typed platform interface and executed on native background threads.
5. **Zero-Permission Media Saving:** Status media is exported directly to standard public media collections (`Pictures/` and `Movies/`) via `MediaStore` on Android 10+ without runtime permissions.
6. **Privacy & Security First:** 100% on-device processing. No network permissions. No media byte logging.

---

## 3. System Architecture & Dependency Graph

```
+-------------------------------------------------------------------------+
|                           PRESENTATION LAYER                            |
|        Screens, Widgets, Media Viewers, Modal Sheets, Animations        |
+-------------------------------------------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                           APPLICATION LAYER                             |
|          State Notifiers (Riverpod), View Models, Sealed States         |
+-------------------------------------------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                             DOMAIN LAYER                                |
|         Entities, Value Objects, Use Cases, Repository Contracts        |
+-------------------------------------------------------------------------+
                                     ^
                                     | implements
+-------------------------------------------------------------------------+
|                              DATA LAYER                                 |
|       Repository Implementations, DTOs, Mappers, Local Data Sources     |
+-------------------------------------------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                            PLATFORM LAYER                               |
|        Platform Interface, MethodChannel Implementation (Dart)          |
+-------------------------------------------------------------------------+
                                     |
                          MethodChannel Boundary
                                     |
+-------------------------------------------------------------------------+
|                       ANDROID NATIVE LAYER (KOTLIN)                     |
|  AndroidStatusScanner (Facade)                                          |
|    ├── SafStorageManager      (Folder Picker, URI Permissions)          |
|    ├── StatusDocumentReader   (ContentResolver Queries, Streams)        |
|    ├── MediaStoreSaver        (Images & Video Gallery Export)           |
|    ├── ThumbnailManager       (Background Bitmap Downsampling & Cache)  |
|    └── VideoCacheManager      (On-Demand Stream Caching for Seeking)    |
+-------------------------------------------------------------------------+
```

---

## 4. Layer Responsibilities

### 4.1 Presentation (`lib/presentation/`)
- Pure Flutter UI widgets.
- Renders domain models and reactive view states.
- Dispatches user intents to Application Layer notifiers.
- Displays deterministic loading, empty, and error views.
- Has zero knowledge of `MethodChannel` or native platform constructs.

### 4.2 Application (`lib/application/`)
- Manages feature state using `StateNotifier` / Riverpod providers.
- Employs explicit sealed states (`Initial`, `Loading`, `Success`, `Error`).
- Coordinates domain use cases.
- Handles user interactions (requesting access, refreshing status lists, saving media).

### 4.3 Domain (`lib/domain/`)
- Pure Dart business logic with zero Flutter or platform dependencies.
- Defines core entities (`StatusItem`, `SavedMedia`, `StorageAccessState`, `MediaType`).
- Defines repository contracts (`StatusRepository`, `SavedMediaRepository`).
- Houses reusable use cases (`GetStatusesUseCase`, `SaveStatusUseCase`, `CheckAccessUseCase`).

### 4.4 Data (`lib/data/`)
- Implements domain repository interfaces.
- Serializes and deserializes Data Transfer Objects (`StatusDto`, `SavedMediaDto`).
- Maps DTOs to immutable Domain Entities.
- Manages local persistence for user preferences and saved item records.

### 4.5 Platform (`lib/platform/`)
- Provides the Dart abstraction for native platform services.
- Implements `StatusScannerPlatformInterface` via `MethodChannelStatusScanner`.
- Encapsulates platform channel name, method names, and error code translation.

### 4.6 Android Infrastructure (`android/app/src/main/kotlin/.../status/`)
- **`SafStorageManager`**: Encapsulates `ACTION_OPEN_DOCUMENT_TREE`, `EXTRA_INITIAL_URI`, taking persistable URI read permissions, checking registered permissions, and verifying tree health.
- **`StatusDocumentReader`**: Queries child documents of `.Statuses` using `ContentResolver` with strict projections; provides input streams for reading media bytes.
- **`MediaStoreSaver`**: Writes image and video files into `MediaStore.Images` and `MediaStore.Video` using `RELATIVE_PATH` and `IS_PENDING` with rollback cleanup on error.
- **`ThumbnailManager`**: Decodes downsampled 256x256 thumbnails on background threads and caches them to disk (`context.cacheDir/thumbnails/`).
- **`VideoCacheManager`**: Streams video files to app cache on-demand for smooth, hardware-accelerated playback with seek support.
- **`AndroidStatusScanner`**: Facade coordinating native services, handling threading via Kotlin Coroutines (`Dispatchers.IO`), and returning responses to Flutter.
- **`MainActivity`**: Minimal FlutterActivity that delegates engine configuration and channel registration.

---

## 5. Folder Structure & Alignment with AGENTS.md

`AGENTS.md` (Section 6) recommends a feature-first approach, while keeping core utilities centralized. The production layout maps cleanly:

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_typography.dart
│       └── app_spacing.dart
├── core/
│   ├── errors/
│   │   ├── app_failure.dart
│   │   └── platform_exception_mapper.dart
│   ├── result/
│   │   └── result.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── file_size_formatter.dart
├── domain/
│   ├── entities/
│   │   ├── status_item.dart
│   │   ├── saved_media.dart
│   │   ├── storage_access_state.dart
│   │   └── media_type.dart
│   ├── repositories/
│   │   ├── status_repository.dart
│   │   └── saved_media_repository.dart
│   └── use_cases/
│       ├── check_storage_access_use_case.dart
│       ├── request_storage_access_use_case.dart
│       ├── get_statuses_use_case.dart
│       ├── get_thumbnail_use_case.dart
│       ├── save_status_use_case.dart
│       └── prepare_video_playback_use_case.dart
├── data/
│   ├── models/
│   │   ├── status_dto.dart
│   │   └── saved_media_dto.dart
│   ├── datasources/
│   │   ├── status_platform_datasource.dart
│   │   └── saved_local_datasource.dart
│   └── repositories/
│       ├── status_repository_impl.dart
│       └── saved_media_repository_impl.dart
├── platform/
│   ├── status_scanner_platform_interface.dart
│   ├── method_channel_status_scanner.dart
│   └── channel_constants.dart
├── application/
│   ├── access/
│   │   ├── access_notifier.dart
│   │   └── access_state.dart
│   ├── statuses/
│   │   ├── status_list_notifier.dart
│   │   └── status_list_state.dart
│   ├── viewer/
│   │   ├── viewer_notifier.dart
│   │   └── viewer_state.dart
│   └── saver/
│       ├── save_notifier.dart
│       └── save_state.dart
└── presentation/
    ├── common/
    │   ├── empty_state_view.dart
    │   ├── error_state_view.dart
    │   └── loading_indicator.dart
    ├── onboarding/
    │   └── permission_guide_sheet.dart
    ├── statuses/
    │   ├── status_screen.dart
    │   └── widgets/
    │       ├── status_grid.dart
    │       ├── status_card.dart
    │       └── thumbnail_image.dart
    ├── viewer/
    │   ├── media_viewer_screen.dart
    │   └── widgets/
    │       ├── image_viewer.dart
    │       └── video_viewer.dart
    └── saved/
        ├── saved_screen.dart
        └── widgets/
            └── saved_grid.dart
```

---

## 6. Domain Model

All domain entities are immutable and free of platform dependencies.

### 6.1 `StatusItem`
```dart
enum MediaType { image, video }

class StatusItem {
  final String id;              // Opaque, stable identifier across scans
  final String fileName;        // Display filename (e.g. 6e0d286c...jpg)
  final MediaType mediaType;    // Image or Video
  final String mimeType;        // e.g. "image/jpeg", "video/mp4"
  final int sizeBytes;          // File size in bytes
  final DateTime lastModified;  // Modification timestamp
  final bool isSaved;           // Derived/joined save status

  const StatusItem({
    required this.id,
    required this.fileName,
    required this.mediaType,
    required this.mimeType,
    required this.sizeBytes,
    required this.lastModified,
    this.isSaved = false,
  });
}
```

#### Why is `id` an opaque string?
- **Identity Stability:** An item's identity in the UI cannot be an array index because statuses change whenever WhatsApp adds or deletes media.
- **Encapsulation:** The underlying Android `documentId` (e.g., `primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses/<filename>`) is an Android SAF implementation detail. The domain layer treats `id` as an opaque token passed back to the repository for thumbnail, save, or video preparation requests.
- **Cross-Platform:** On iOS or fake test environments, `id` can represent a file path, UUID, or mock key without changing any domain/presentation logic.

### 6.2 `SavedMedia`
```dart
class SavedMedia {
  final String id;
  final String originalFileName;
  final String savedUriOrPath;
  final MediaType mediaType;
  final DateTime savedAt;
  final int sizeBytes;

  const SavedMedia({
    required this.id,
    required this.originalFileName,
    required this.savedUriOrPath,
    required this.mediaType,
    required this.savedAt,
    required this.sizeBytes,
  });
}
```

### 6.3 `StorageAccessState`
```dart
sealed class StorageAccessState {
  const StorageAccessState();
}

class StorageAccessInitial extends StorageAccessState {
  const StorageAccessInitial();
}

class StorageAccessNotGranted extends StorageAccessState {
  const StorageAccessNotGranted();
}

class StorageAccessGranted extends StorageAccessState {
  final String accountType; // e.g. "com.whatsapp"
  const StorageAccessGranted({this.accountType = 'com.whatsapp'});
}

class StorageAccessRevoked extends StorageAccessState {
  final String reason;
  const StorageAccessRevoked({required this.reason});
}
```

---

## 7. Platform Channel Specification

### 7.1 Channel Identification
- **Channel Name:** `com.example.whatsapp_status_saver/scanner`
- **Ownership:** Maintained by `MethodChannelStatusScanner` (Dart) and `AndroidStatusScanner` (Kotlin).

### 7.2 Method Contract Evaluation & Operations

We evaluated all 9 candidate channel operations from the design brief:

| Operation | Included? | Rationale |
|---|---|---|
| `checkFolderAccess` | **YES** | Essential on app launch to verify persisted tree access without showing picker. |
| `requestFolderAccess`| **YES** | Initiates SAF picker with pre-seeded URI and takes persistable read permission. |
| `scanStatuses` | **YES** | Enumerates `.Statuses` directory with indexed ContentResolver projection. |
| `readMedia` | **NO (Replaced)**| Raw byte reading across channel causes bridge congestion. Replaced by `getThumbnail` and `prepareVideo`. |
| `getThumbnail` | **YES** | Decodes downsampled 256x256 thumbnail natively; prevents Out-Of-Memory. |
| `prepareVideo` | **YES** | Caches video on-demand to enable instantaneous, hardware-accelerated seeking. |
| `saveStatus` | **YES** | Direct MediaStore export for both images and videos with atomic rollback on failure. |
| `deleteSavedStatus` | **NO (Deferred)**| Handled via standard media store or deferred to Phase 3; user can manage gallery directly. |
| `getSavedStatuses` | **NO (Client)** | Tracked in Flutter application layer via local persistence (`SavedMediaRepository`). |
| `revokeAccess` | **YES (Utility)**| Allows user or tests to reset folder permission for recovery flows. |

---

### 7.3 Detailed Specifications per Operation

#### 1. `checkFolderAccess`
- **Method Name:** `checkFolderAccess`
- **Arguments:** `Map<String, dynamic>`: `{"targetPackage": String?}` (default: `"com.whatsapp"`)
- **Return Type:** `Map<String, dynamic>`: `{"hasAccess": Boolean, "status": "granted" | "not_granted" | "revoked", "targetPackage": String}`
- **Error Behavior:** Returns `CHECK_FAILED` if `ContentResolver` throws `SecurityException`.
- **Threading:** Background worker (`Dispatchers.IO`), returns result on Android Main thread.
- **Ownership:** `SafStorageManager` validates the specific registered tree URI.
- **Lifecycle:** Invoked on app startup or when resuming from system settings.
- **Data Leak Analysis:** **No leak.** The internal `content://` tree URI is kept strictly inside Kotlin.

#### 2. `requestFolderAccess`
- **Method Name:** `requestFolderAccess`
- **Arguments:** `Map<String, dynamic>`: `{"targetPackage": String?}`
- **Return Type:** `Map<String, dynamic>`: `{"granted": Boolean, "persisted": Boolean, "error": String?}`
- **Error Behavior:** Returns `ALREADY_PENDING` if a picker is already open; `LAUNCH_FAILED` if `DocumentsUI` cannot be resolved.
- **Threading:** Main thread for Activity intent launch; `Dispatchers.IO` for taking persistable permissions.
- **Ownership:** `SafStorageManager` handles `onActivityResult`.
- **Lifecycle:** Single execution per user gesture.
- **Data Leak Analysis:** **No leak.** Flutter receives only boolean `granted` and `persisted` flags.

#### 3. `scanStatuses`
- **Method Name:** `scanStatuses`
- **Arguments:** `Map<String, dynamic>`: `{"targetPackage": String?}`
- **Return Type:** `List<Map<String, dynamic>>`: Array of status maps (id, fileName, mimeType, sizeBytes, lastModified, isVideo).
- **Error Behavior:** Throws `SCAN_FAILED` with classified failure code (`NO_TREE_URI`, `FOLDER_UNAVAILABLE`).
- **Threading:** `Dispatchers.IO`; executes direct `ContentResolver.query()` with column projection.
- **Ownership:** `StatusDocumentReader`.
- **Lifecycle:** Invoked on initial load and pull-to-refresh.
- **Data Leak Analysis:** **No leak.** `id` is an opaque token representing the document identity; raw tree URIs are not returned.

#### 4. `getThumbnail`
- **Method Name:** `getThumbnail`
- **Arguments:** `Map<String, dynamic>`: `{"id": String, "width": Int, "height": Int}`
- **Return Type:** `Map<String, dynamic>`: `{"filePath": String}`
- **Error Behavior:** Returns `THUMBNAIL_FAILED` if file descriptor cannot be opened or decode fails.
- **Threading:** `Dispatchers.IO` for background bitmap decoding and disk caching.
- **Ownership:** `ThumbnailManager`.
- **Lifecycle:** Invoked lazily as grid cells become visible.
- **Data Leak Analysis:** **No leak.** Returns standard app-internal cache file path (`cacheDir/thumbnails/...`).

#### 5. `prepareVideo`
- **Method Name:** `prepareVideo`
- **Arguments:** `Map<String, dynamic>`: `{"id": String}`
- **Return Type:** `Map<String, dynamic>`: `{"filePath": String}`
- **Error Behavior:** Returns `VIDEO_PREPARE_FAILED` if streaming fails.
- **Threading:** `Dispatchers.IO` stream copy.
- **Ownership:** `VideoCacheManager`.
- **Lifecycle:** Invoked on-demand when user opens a video status in the viewer.
- **Data Leak Analysis:** **No leak.** Returns local cache file path for `video_player`.

#### 6. `saveStatus`
- **Method Name:** `saveStatus`
- **Arguments:** `Map<String, dynamic>`: `{"id": String, "displayName": String?}`
- **Return Type:** `Map<String, dynamic>`: `{"success": Boolean, "mediaType": String, "displayName": String, "bytesSaved": Long, "publicCollection": String}`
- **Error Behavior:** Returns `SAVE_FAILED`. On error, automatically deletes the pending MediaStore row to prevent 0-byte orphan files.
- **Threading:** `Dispatchers.IO` stream transfer.
- **Ownership:** `MediaStoreSaver`.
- **Lifecycle:** Invoked on user "Save" tap.
- **Data Leak Analysis:** **No leak.** Returns display name and public collection name (`Pictures/SavedStatus` or `Movies/SavedStatus`).

#### 7. `revokeAccess`
- **Method Name:** `revokeAccess`
- **Arguments:** `Map<String, dynamic>`: `{"targetPackage": String?}`
- **Return Type:** `Map<String, dynamic>`: `{"revoked": Boolean}`
- **Error Behavior:** Returns `REVOKE_FAILED`.
- **Threading:** `Dispatchers.IO`.
- **Ownership:** `SafStorageManager`.
- **Lifecycle:** Settings reset or debug reset.
- **Data Leak Analysis:** **No leak.**


---

## 8. Android Native Architecture

### 8.1 Modular Kotlin Architecture
In the POC, all native code lived inside `MainActivity.kt` (440 lines). Production separates these concerns into dedicated classes in `io.nishvanta.keeva.status`:

```
android/app/src/main/kotlin/io/nishvanta/keeva/
├── MainActivity.kt                      (Slim launcher & engine hook)
└── status/
    ├── AndroidStatusScanner.kt          (MethodCallHandler & Coroutine orchestrator)
    ├── SafStorageManager.kt             (SAF Picker & Persisted Permission Manager)
    ├── StatusDocumentReader.kt          (ContentResolver document queries & streams)
    ├── MediaStoreSaver.kt               (MediaStore Image & Video export with rollback)
    ├── ThumbnailManager.kt              (Bitmap downsampling & disk cache)
    └── VideoCacheManager.kt             (Video stream cache for seek-capable playback)
```

### 8.2 Component Responsibilities

#### 1. `SafStorageManager`
- **Advisory Initial URI Navigation Strategy:**
  - Guides DocumentsUI toward the WhatsApp Media folder without assuming compliance.
  - In Android documentation, `DocumentsContract.EXTRA_INITIAL_URI` accepts:
    - A document URI: `DocumentsContract.buildDocumentUri("com.android.externalstorage.documents", "$volumeId:Android/media/com.whatsapp/WhatsApp/Media")`
    - A tree URI: `DocumentsContract.buildTreeDocumentUri("com.android.externalstorage.documents", "$volumeId:Android/media/com.whatsapp/WhatsApp/Media")`
  - **Advisory Rule:** `EXTRA_INITIAL_URI` is strictly advisory. DocumentsUI may ignore it, open at the storage root, or fall back to recents depending on OEM customizations and OS version. The application must never assume DocumentsUI honors this hint.
- **Dynamic Storage Volume Resolution:**
  - Do NOT assume `"primary:"` is universally the active storage volume.
  - The native layer inspects `StorageManager.storageVolumes` (API 24+) or `context.getExternalFilesDirs(null)`:
    - Primary volume: uses `"primary"` if `StorageVolume.isPrimary` is true.
    - Removable/Adoptable storage: derives the active volume UUID (e.g. `"1A2B-3C4D"`).
    - If provider or storage root is unavailable, omits `EXTRA_INITIAL_URI` gracefully, launching `ACTION_OPEN_DOCUMENT_TREE` without crashing.
- **Persisting Read Permission:**
  - Takes persistable read permission: `ContentResolver.takePersistableUriPermission(treeUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)`.
  - Write permission on WhatsApp directory is **never** requested or required.
- **SAF Target Validation Contract (7-Step Contract):**
  1. *URI Sanity Check:* Verify scheme is `"content"` and `DocumentsContract.isTreeUri(selectedTreeUri) == true`.
  2. *Extract Tree Document ID:* Call `DocumentsContract.getTreeDocumentId(selectedTreeUri)`. Catch any `IllegalArgumentException` and return `INVALID`.
  3. *Determine Logical Identity:* Parse document ID (e.g. `<volume>:<path>`). Note that document IDs are provider-opaque strings; string heuristics must be confirmed through `ContentResolver` queries.
  4. *Resolve WhatsApp Hierarchy:* Evaluate whether the selected tree is direct `.Statuses`, canonical `Media`, or a supported parent (`WhatsApp`, `com.whatsapp`, `Android/media`).
  5. *Locate `.Statuses`:* Traverse down using `DocumentsContract.buildChildDocumentsUriUsingTree()` to locate `.Statuses`.
  6. *Verify Query Capability:* Execute a test cursor query on `.Statuses` via `ContentResolver.query()` with projection `arrayOf(Document.COLUMN_DOCUMENT_ID, Document.COLUMN_DISPLAY_NAME, Document.COLUMN_MIME_TYPE)`.
  7. *Classify Result Status:*
     - `VALID`: Direct `.Statuses` or `WhatsApp/Media` folder selected and verified readable.
     - `VALID_PARENT`: Ancestor directory (`WhatsApp`, `com.whatsapp`, `Android/media`) selected and traversal successfully resolved `.Statuses`.
     - `INVALID`: Unrelated folder (e.g. `Download`, `DCIM`, storage root) where hierarchy cannot be resolved.
     - `UNAVAILABLE`: Correct WhatsApp folder structure selected, but `.Statuses` is missing (user has not opened WhatsApp or viewed any statuses).
     - `PERMISSION_REVOKED`: Persisted URI permission was revoked in Settings or cleared by OS.
- **User Selection Variants Handling Matrix:**
  - *Variant A (`.../WhatsApp/Media`):* `VALID` -> Accepted (Canonical target).
  - *Variant B (`.../WhatsApp/Media/.Statuses`):* `VALID` -> Accepted (Direct target).
  - *Variant C (`.../WhatsApp`):* `VALID_PARENT` -> Accepted as parent; traverses to `Media/.Statuses`.
  - *Variant D (`.../com.whatsapp`):* `VALID_PARENT` -> Accepted as parent; traverses to `WhatsApp/Media/.Statuses`.
  - *Variant E (`.../Android/media`):* `VALID_PARENT` -> Accepted as parent (if OEM picker allows); traverses to `.Statuses`.
  - *Variant F (Unrelated folder `DCIM`, `Download`):* `INVALID` -> Rejected. User message: *"Incorrect folder selected. Please select WhatsApp Media."* Retry launches picker with visual guide.
  - *Variant G (Storage root `primary:`):* `INVALID` -> Rejected. User message: *"Entire storage root cannot be used. Please choose WhatsApp Media."*
  - *Variant H (Missing WhatsApp directory):* `UNAVAILABLE` -> Rejected. User message: *"WhatsApp Status folder not found. View a status in WhatsApp first."*
  - *Variant I (WhatsApp uninstalled):* `UNAVAILABLE` -> Rejected. User message: *"WhatsApp is not installed on this device."*
  - *Variant J (Permission revoked):* `PERMISSION_REVOKED` -> Rejected. User message: *"Folder access was revoked. Please reconnect."* Clear stale URI and prompt reconnection.
- **Limitations of Provider-Specific Path Identity:**
  - SAF document IDs are opaque strings assigned by `ExternalStorageProvider`.
  - The application avoids relying solely on string matching (e.g. `.contains(".Statuses")`) and always validates tree accessibility by executing cursor queries via `ContentResolver`.

#### 2. `StatusDocumentReader`
- Resolves the `.Statuses` directory deterministically:
  - Direct target docId calculation: `"$treeDocId/.Statuses"` (or resolved relative path for parent trees).
  - Fallback: bounded traversal of direct children of the tree for `.Statuses`.
- Direct `ContentResolver.query()` using `DocumentsContract.buildChildDocumentsUriUsingTree()` with projection:
  ```kotlin
  val projection = arrayOf(
      DocumentsContract.Document.COLUMN_DOCUMENT_ID,
      DocumentsContract.Document.COLUMN_DISPLAY_NAME,
      DocumentsContract.Document.COLUMN_MIME_TYPE,
      DocumentsContract.Document.COLUMN_SIZE,
      DocumentsContract.Document.COLUMN_LAST_MODIFIED
  )
  ```
- Filters out `.nomedia` and directories.
- Returns clean DTO maps to `AndroidStatusScanner`.

#### 3. `MediaStoreSaver`
- Zero-permission export to public gallery:
  - Images -> `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` with `RELATIVE_PATH = "Pictures/SavedStatus/"`.
  - Videos -> `MediaStore.Video.Media.EXTERNAL_CONTENT_URI` with `RELATIVE_PATH = "Movies/SavedStatus/"`.
- Lifecycle & Atomic Rollback:
  1. Insert row with `IS_PENDING = 1`.
  2. Stream bytes from SAF `InputStream` to MediaStore `OutputStream`.
  3. On success: update `IS_PENDING = 0`.
  4. On failure: catch exception, delete the pending row via `contentResolver.delete(targetUri, null, null)` to prevent corrupt 0-byte orphan files in the user's gallery, and throw structured error.

#### 4. `ThumbnailManager` (Disk & RAM Thumbnail Architecture)
- **Problem:** Full-resolution status photos can be 5–15 MB. Loading dozens in a grid would cause Out-Of-Memory (OOM) crashes.
- **Disk Thumbnail Cache:**
  - **Owner:** `ThumbnailManager.kt`.
  - **Location:** `context.cacheDir/thumbnails/` (canonical location).
  - **Quota:** **100 MB maximum**.
  - **Eviction Policy:** **LRU** (Least Recently Used) based on file `lastModified` / access time. When cache directory exceeds 100 MB, files are deleted in ascending access order until total size drops to <= 80 MB (20% hysteresis buffer).
  - **Generation Strategy:** Decode 256x256 thumbnail using `BitmapFactory.Options.inSampleSize` from `ContentResolver.openFileDescriptor(documentUri, "r")`. Compress to WebP (or JPEG 85%) as `cacheDir/thumbnails/<docIdHash>.webp`.
  - **Cache Lookup:** If file exists and modification timestamp matches, return cached path immediately without re-decoding.
- **RAM Thumbnail Cache:**
  - **Owner:** Flutter Presentation Layer (`PaintingBinding.instance.imageCache`).
  - **Capacity:** **35 MB maximum**.
  - **Eviction Policy:** LRU managed by Flutter `ImageCache.maximumSizeBytes = 35 * 1024 * 1024`.
- **User Reporting & Management:** Reported in Settings as *"Thumbnail Cache: XX MB (Max 100 MB)"*.

#### 5. `VideoCacheManager` (Video Playback Stream Cache)
- **Problem:** Playing videos directly through `content://` URIs via SAF in Flutter `video_player` (ExoPlayer) often fails random seeks, triggers slow buffering, or drops playback on backgrounding.
- **Video Playback Cache:**
  - **Owner:** `VideoCacheManager.kt`.
  - **Location:** `context.cacheDir/videos/` (canonical location).
  - **Quota:** **100 MB maximum**.
  - **Eviction Policy:** **Bounded LRU Eviction Strategy** based on file access timestamp. When streaming a new video would push cache over 100 MB, least recently accessed video cache files are evicted until size drops to <= 75 MB. (LRU prevents evicting actively looped or re-watched statuses).
  - **Streaming Strategy:** Stream MP4 bytes from SAF `InputStream` to `context.cacheDir/videos/<docIdHash>.mp4` on `Dispatchers.IO`. Status videos (1–10 MB, 30–60s) transfer in < 100 ms on modern storage.
  - **Playback:** Returns local filesystem path to Flutter. `VideoPlayerController.file()` initializes hardware-accelerated playback with instantaneous seek bar response.
- **User Reporting & One-Tap Clear:**
  - Reported in Settings as *"Video Playback Cache: XX MB (Max 100 MB)"*.
  - *"Clear Temporary Caches"* in Settings triggers `clearCache()` on the platform channel, purging both `cacheDir/thumbnails/` and `cacheDir/videos/` with zero effect on saved gallery media.

---

## 9. State Management Architecture

The application uses **Riverpod** with immutable sealed state models to eliminate boolean explosion.

### 9.1 Sealed State Definitions

```dart
// Status List State
sealed class StatusListState {
  const StatusListState();
}
class StatusListInitial extends StatusListState {}
class StatusListLoading extends StatusListState {}
class StatusListLoaded extends StatusListState {
  final List<StatusItem> statuses;
  final bool isRefreshing;
  const StatusListLoaded(this.statuses, {this.isRefreshing = false});
}
class StatusListEmpty extends StatusListState {
  final EmptyReason reason; // noStatusesInWhatsApp | folderEmpty
  const StatusListEmpty(this.reason);
}
class StatusListError extends StatusListState {
  final AppFailure failure;
  const StatusListError(this.failure);
}

// Save State
sealed class SaveState {
  const SaveState();
}
class SaveIdle extends SaveState {}
class SavingItem extends SaveState {
  final String statusId;
  const SavingItem(this.statusId);
}
class SaveSuccess extends SaveState {
  final SavedMedia savedMedia;
  const SaveSuccess(this.savedMedia);
}
class SaveFailureState extends SaveState {
  final String statusId;
  final AppFailure failure;
  const SaveFailureState(this.statusId, this.failure);
}
```

---

## 10. Typed Error Model

Platform exceptions are caught at the platform boundary and converted into strongly-typed domain failures:

```dart
sealed class AppFailure {
  final String message;
  final String? technicalDetails;
  const AppFailure(this.message, [this.technicalDetails]);
}

class NoStorageAccessFailure extends AppFailure {
  const NoStorageAccessFailure([String? details])
      : super('Storage access has not been granted.', details);
}

class AccessRevokedFailure extends AppFailure {
  const AccessRevokedFailure([String? details])
      : super('WhatsApp media access was revoked. Please grant access again.', details);
}

class PickerCancelledFailure extends AppFailure {
  const PickerCancelledFailure([String? details])
      : super('Folder selection was cancelled.', details);
}

class InvalidTreeFailure extends AppFailure {
  const InvalidTreeFailure([String? details])
      : super('The selected folder is not a valid WhatsApp Media folder.', details);
}

class StatusesUnavailableFailure extends AppFailure {
  const StatusesUnavailableFailure([String? details])
      : super('No active WhatsApp statuses found. View statuses in WhatsApp first.', details);
}

class StatusReadFailure extends AppFailure {
  const StatusReadFailure([String? details])
      : super('Failed to read status media.', details);
}

class ThumbnailGenerationFailure extends AppFailure {
  const ThumbnailGenerationFailure([String? details])
      : super('Could not generate media thumbnail.', details);
}

class SaveMediaFailure extends AppFailure {
  const SaveMediaFailure([String? details])
      : super('Failed to save status to gallery.', details);
}

class UnknownPlatformFailure extends AppFailure {
  const UnknownPlatformFailure(String message, [String? details])
      : super(message, details);
}
```

---

## 11. Access Lifecycle & Recovery Flows

```
               +----------------------+
               |    Fresh Install     |
               +----------------------+
                          |
                          v
               +----------------------+
               |  CheckFolderAccess   |
               +----------------------+
                     /          \
            hasAccess=true    hasAccess=false
                   /              \
                  v                v
     +-------------------+   +------------------------+
     |   ScanStatuses    |   | Show Permission Guide  |
     +-------------------+   +------------------------+
              |                            |
              |                   User taps "Grant Access"
              |                            |
              |                            v
              |               +------------------------+
              |               |  ACTION_OPEN_DOC_TREE  |
              |               |  (pre-seeded with URI) |
              |               +------------------------+
              |                        /        \
              |                RESULT_OK      CANCEL
              |                      /            \
              |                     v              v
              |          +--------------------+  +----------------------+
              |          | Persist Tree URI   |  | Show Cancelled State |
              |          +--------------------+  +----------------------+
              |                     |
              |                     v
              +------------>+--------------------+
                            | Scan & Show Grid   |
                            +--------------------+
                                      |
                         If ContentResolver fails
                         (e.g. tree permission revoked)
                                      |
                                      v
                            +--------------------+
                            | Transition State:  |
                            | StorageAccessRevoked|
                            +--------------------+
                                      |
                                      v
                            +--------------------+
                            | Show Recovery UI   |
                            | (Prompt Re-grant)  |
                            +--------------------+
```

---

## 12. Local Persistence Strategy

### Evaluation:
- **Option A: Drift (SQLite)** - High overhead, requires code generation (`build_runner`), complex migrations. Overkill for simple metadata tracking.
- **Option B: `shared_preferences` / JSON file storage** - Zero boilerplate, instant execution, reliable for key-value settings and saved status ID tracking.

### Decision:
- **No SQLite / Drift for Phase 2.**
- Tree URI persistence is natively handled by Android `ContentResolver.takePersistableUriPermission`.
- Saved media records (mapping original status IDs to saved timestamps and gallery URIs) are stored in a lightweight JSON record file in app documents or `shared_preferences`.
- If Phase 3 introduces custom user albums, tagging, or full-text status search, Drift will be evaluated at that time behind the existing `SavedMediaRepository` contract.

---

## 13. Multiple Accounts Strategy

### Context:
Users may run:
1. Standard WhatsApp (`com.whatsapp`)
2. WhatsApp Business (`com.whatsapp.w4b`)
3. Dual Apps / Cloned profiles (e.g. Xiaomi dual app user 999)

### Decision:
- **Architectural Readiness:** Domain entities and repository methods accept an optional `accountType` parameter (`AccountType.whatsappStandard`, `AccountType.whatsappBusiness`).
- Native `SafStorageManager` accepts target package name and can store multiple persisted tree URIs keyed by package.
- **Phase 2 Scope:** Default to WhatsApp Standard. UI exposes a clean extension point where a segmented switch or drawer can easily switch accounts without altering data or domain contracts.

---

## 14. Dependency Decisions

| Dependency | Purpose | Why Flutter built-in is insufficient | Platform implications | Decision |
|---|---|---|---|---|
| `flutter_riverpod` | State management & DI | `ChangeNotifier` / `setState` lacks predictable unidirectional flow and testability. | Pure Dart, cross-platform | **Adopt in Phase 2D** |
| `go_router` | Declarative routing | Default Navigator 1.0 lacks clean deep link handling and modal sheet routing. | Pure Dart, cross-platform | **Adopt in Phase 2D** |
| `video_player` | Video status playback | Flutter has no built-in video rendering. | Uses native ExoPlayer on Android | **Adopt in Phase 2G** |
| `path_provider` | Internal cache directories | Needed to resolve thumbnail and video cache paths. | Calls standard platform directory APIs | **Adopt in Phase 2B/2C** |
| `shared_preferences` | App settings persistence | Needed for theme, onboarding flag, saved items list. | Cross-platform KV storage | **Adopt in Phase 2D** |
| `photo_manager` | Gallery scanning | WhatsApp status folder is hidden (`.Statuses` with `.nomedia`), which `photo_manager` strictly ignores. | Not suitable for discovery | **REJECTED** |
| `gal` | Media saving | Native Kotlin `MediaStoreSaver` already implements zero-permission MediaStore saving with rollback. | Duplicate dependency | **REJECTED** |
| `permission_handler`| Runtime permissions | Modern Android requires SAF and MediaStore, neither of which uses standard runtime permissions. | Unnecessary permissions in manifest | **REJECTED** |
| `drift` | Database | Too heavy for basic saved items list. | Requires build_runner, sqlite3 native libraries | **DEFERRED (Phase 3+)** |

---

## 15. Testing Architecture

### 15.1 Unit Tests (`test/unit/`)
- `StatusRepositoryImpl`: Mock `StatusPlatformDatasource` and test DTO mapping, error wrapping, and cache behavior.
- `UseCases`: Test business logic in isolation.
- `StateNotifiers`: Test state transitions (`Loading` -> `Loaded`, `Loading` -> `Empty`, error handling).

### 15.2 Platform Channel Tests (`test/platform/`)
- Intercept `MethodChannel('com.example.whatsapp_status_saver/scanner')` using `TestDefaultBinaryMessengerBinding`.
- Verify method arguments and error code translation.

### 15.3 Native Android Tests (`android/app/src/test/`)
- Test `SafStorageManager` URI construction and path parsing.
- Test `MediaStoreSaver` MIME detection and display name generation.

### 15.4 Widget Tests (`test/widget/`)
- Test `StatusScreen` in all 4 states: Loading, Loaded with grid items, Empty state, and Error state with retry action.
- Test `PermissionGuideSheet` rendering and user tap forwarding.

### 15.5 Physical Device Integration Testing
- Target: **Xiaomi 2311DRK48I (Android 16, API 36, HyperOS 3.0)**.
- Full end-to-end user journey: Launch -> Onboarding Guide -> SAF Picker -> Grid Discovery -> Thumbnail Rendering -> Video Playback -> MediaStore Save -> Restart App.

---

## 16. Performance & Memory Strategy

1. **Thumbnail Bounding:** Grid renders 256x256 thumbnails only. Full-resolution media is only loaded on the viewer screen.
2. **Direct ContentResolver Queries:** Cursor query with column projection avoids the catastrophic N+1 query overhead of `DocumentFile.fromTreeUri()`.
3. **Background Concurrency:** All disk and ContentResolver I/O runs on `Dispatchers.IO` in Kotlin and background isolates/futures in Dart.
4. **Video Seeking:** Local cache file streaming avoids SAF pipe buffer stalls during video scrubbing.
5. **Authoritative Cache Budgets & Eviction Strategy:**
   - **RAM Thumbnail Cache:** 35 MB maximum (managed via Flutter `ImageCache`, LRU eviction).
   - **Disk Thumbnail Cache:** 100 MB maximum (`context.cacheDir/thumbnails/`, LRU eviction targeting 80 MB upon exceeding quota).
   - **Video Playback Cache:** 100 MB maximum (`context.cacheDir/videos/`, bounded LRU eviction targeting 75 MB upon exceeding quota).

---

## 17. Security & Privacy Strategy

1. **Zero Network Permissions:** `AndroidManifest.xml` does not include `android.permission.INTERNET`. The app cannot communicate with external servers.
2. **Zero Telemetry:** No analytics SDKs or remote crash reporters that could leak media metadata.
3. **No Media Byte Logging:** Binary data streams are never printed to logcat or console.
4. **Least-Privilege Storage:** Uses SAF scoped to `WhatsApp/Media` and zero-permission `MediaStore` export. No `MANAGE_EXTERNAL_STORAGE`.

---

## 18. Migration Plan from POC

| POC Artifact | Production Destination | Action |
|---|---|---|
| `MainActivity.kt` (440 lines) | `android/.../status/*` | Extract SAF, DocumentReader, MediaStoreSaver into dedicated classes. Keep `MainActivity.kt` < 40 lines. |
| `checkFolderAccess()` in POC | `SafStorageManager.kt` | Rewrite to validate specific target tree and check accessibility. |
| `scanStatuses()` in POC | `StatusDocumentReader.kt` | Rewrite with deterministic targetDocId and clean DTO mapping. |
| `verifyMediaRead()` in POC | `ThumbnailManager.kt` & `VideoCacheManager.kt` | Replaced by thumbnail downsampling and video cache streaming. |
| `saveTestImage()` in POC | `MediaStoreSaver.kt` | Rewrite to support both image and video with rollback cleanup on error. |
| `lib/main.dart` (621 lines) | `lib/presentation/...`, `lib/app/...` | Replace POC diagnostic UI with production clean architecture screens. |
| `test/widget_test.dart` | `test/widget/...` | Replace POC smoke test with production screen widget tests. |
| `docs/android/storage-access.md` | `docs/android/storage-access.md` | Preserved as authoritative feasibility evidence. |
| `walkthrough.md` | `walkthrough.md` | Preserved as authoritative POC verification record. |

---

## 19. Architectural Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| OEM updates block `Android/media` selection | Users cannot grant folder access | Point to parent directory (`WhatsApp/Media`), provide visual step-by-step onboarding guide. |
| WhatsApp moves `.Statuses` to internal private sandbox (`/data/user/0/com.whatsapp/`) | Third-party status discovery permanently blocked on Android | Monitor WhatsApp updates; show friendly error if directory no longer exists. |
| Out-Of-Memory on large status libraries | App crashes during rapid scrolling | Strict thumbnail downsampling (256x256) and disk caching. |
| Video playback freezes on seek | Poor UX in media viewer | Stream videos to local cache file before ExoPlayer playback. |
| Incomplete save leaves orphan 0-byte files | Corrupt gallery entries | Atomic rollback: delete pending MediaStore row if stream copying throws exception. |

---

## 20. Architecture Decision Records (ADRs)

Detailed ADR documents are recorded under `docs/decisions/`:

1. [ADR 001: Storage Access Framework (SAF) for Status Discovery](../decisions/001-saf-media-discovery.md)
   - *Decision:* Use SAF `ACTION_OPEN_DOCUMENT_TREE` with advisory `EXTRA_INITIAL_URI` (dynamically derived) and persisted URI permissions. Direct file access is blocked on Android 11–16, and MediaStore ignores hidden `.Statuses`. Validate returned tree and handle selection variants dynamically.
2. [ADR 002: Zero-Permission MediaStore Saving with Atomic Rollback](../decisions/002-mediastore-zero-permission-export.md)
   - *Decision:* Native Kotlin `MediaStoreSaver` inserts directly into `MediaStore.Images` and `MediaStore.Video` using `IS_PENDING = 1` and cleans up via `contentResolver.delete()` on error.
3. [ADR 003: Deferral of Drift / SQLite Database for Phase 2](../decisions/003-defer-drift-database.md)
   - *Decision:* Avoid heavy database dependencies and code generation for Phase 2. Use `shared_preferences` and lightweight JSON files behind an abstract `SavedMediaRepository`.
4. [ADR 004: Native Background Thumbnail Downsampling via BitmapFactory](../decisions/004-bitmap-factory-thumbnail-pipeline.md)
   - *Decision:* Target 256x256 WebP thumbnails on background threads using `BitmapFactory` `inSampleSize` to prevent Out-Of-Memory errors during grid scrolling (100 MB disk limit, 35 MB RAM limit).
5. [ADR 005: On-Demand Video Cache Streaming for Playback](../decisions/005-video-cache-streaming.md)
   - *Decision:* Stream status videos to an app cache file (`cacheDir/videos/`) before opening with `video_player`, ensuring seamless seek bar responsiveness and zero SAF pipe drops (bounded 100 MB LRU disk cache).
6. [ADR 006: Opaque String Identifiers across the Platform Boundary](../decisions/006-opaque-id-platform-boundary.md)
   - *Decision:* The domain model uses an opaque `String id` so the UI never touches Android `content://` URIs or document IDs.
