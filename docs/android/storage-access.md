# Android Storage Access

**Document Status:** Complete Architecture & Feasibility Research  
**Target Platform:** Android (API 29 – 36 / Android 10 – 16)  
**Primary Authors:** Engineering & Architecture Research  
**Last Updated:** September 2026  

---

## Executive Summary

This document evaluates the technical feasibility of building a WhatsApp Status Saver on Android using Flutter and Kotlin, in full compliance with modern Android platform storage security models and Google Play developer policies.

### Core Verdicts
* **Direct File API Access (`java.io.File`) to Statuses:** **NOT POSSIBLE** on Android 11+ (API 30+) due to Scoped Storage and FUSE restrictions on app-specific directories (`/Android/media/` and `/Android/data/`).
* **MediaStore Discovery for Statuses:** **NOT POSSIBLE**. WhatsApp intentionally stores statuses in a hidden folder (`.Statuses`) with a leading dot and `.nomedia`, which the system `MediaScanner` strictly ignores. MediaStore queries will always return 0 status items.
* **All Files Access (`MANAGE_EXTERNAL_STORAGE`):** **NOT POSSIBLE** for Google Play distribution. While technically capable on device, Google Play policy strictly rejects status savers attempting to claim broad storage management.
* **Storage Access Framework (SAF / `ACTION_OPEN_DOCUMENT_TREE`):** **VERIFIED** on Android 11–12; **LIKELY with platform & OEM constraints** on Android 13–16. Access requires user-granted tree URI permissions via the system file picker (`DocumentsUI`). The feasibility depends on whether the system file picker on the user's specific OS/OEM build allows selecting the WhatsApp Media folder or whether `FLAG_DIR_BLOCKS_OPEN_DOCUMENT_TREE` blocks it.
* **Saving Discovered Media to User's Gallery:** **VERIFIED**. Modern `MediaStore` APIs allow seamless insertion of images and videos into public collections (`Pictures/`, `Movies/`) on Android 10+ (API 29+) with **zero permissions required**.
* **Kotlin Native Implementation Requirement:** **VERIFIED**. Pure Dart (`dart:io`) cannot handle SAF tree traversal, persistent ContentResolver URI grants, thumbnail decoders, or MediaStore streaming. A native Android Kotlin service behind a platform channel is required.

---

## Android Storage Model

The Android storage architecture has evolved significantly across API versions, shifting from an open shared filesystem to a strict sandbox and capability-based access model:

```
+-----------------------------------------------------------------------------+
|                               Android OS                                    |
+-----------------------------------------------------------------------------+
|  Legacy (API <= 28)    |  Direct File access across /sdcard with           |
|                        |  READ/WRITE_EXTERNAL_STORAGE.                      |
+------------------------+----------------------------------------------------+
|  Android 10 (API 29)   |  Scoped Storage introduced; opt-out available via  |
|                        |  requestLegacyExternalStorage="true".               |
+------------------------+----------------------------------------------------+
|  Android 11 (API 30)   |  Scoped Storage strictly enforced. Legacy flag     |
|                        |  ignored. FUSE filesystem layer blocks direct      |
|                        |  File access to /Android/data and /Android/media.  |
|                        |  SAF blocks root and Android/data selection.       |
+------------------------+----------------------------------------------------+
|  Android 13 (API 33)   |  Granular media permissions introduced.           |
|                        |  READ_EXTERNAL_STORAGE deprecated/inactive.       |
|                        |  DocumentsUI restrictions tightened on system paths|
+------------------------+----------------------------------------------------+
|  Android 14 (API 34)   |  Selected Photos access introduced                 |
|                        |  (READ_MEDIA_VISUAL_USER_SELECTED).               |
+------------------------+----------------------------------------------------+
|  Android 15 (API 35) & |  Mandatory edge-to-edge; 16 KB page size support;  |
|  Android 16 (API 36)   |  Photo Picker enforcement for broad media picker;  |
|                        |  MediaStore version lockdown.                      |
+-----------------------------------------------------------------------------+
```

### 1. App-Specific Storage vs. Shared Storage
* **App-Specific Internal (`/data/user/0/<package>/`):** Accessible only by the owning application. No other app can read this without root privileges.
* **App-Specific External (`/storage/emulated/0/Android/data/<package>/` & `/storage/emulated/0/Android/media/<package>/`):** Accessible by the owning app without permissions. Standard `File` APIs from third-party apps are completely blocked by the Linux kernel/FUSE layer since Android 11.
* **Public Shared Storage (`DCIM/`, `Pictures/`, `Movies/`, `Download/`):** Governed by MediaStore and Storage Access Framework.

### 2. Status Classification:
* WhatsApp storage location on modern Android:
  ```text
  /storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses
  ```
  *(Legacy location on Android 10 and below: `/storage/emulated/0/WhatsApp/Media/.Statuses`)*
* Direct POSIX path access via `java.io.File("/storage/emulated/0/Android/media/com.whatsapp/...")`:
  * **Classification:** **NOT POSSIBLE** (API 30+). Calling `file.listFiles()` or `file.canRead()` returns `null` / `false` or throws `FileNotFoundException` / `SecurityException`.

---

## MediaStore

### 1. Purpose and Architecture
`MediaStore` is an indexed database provider (`content://media/...`) provided by `com.android.providers.media` (`MediaProvider`). It scans shared public directories to provide fast querying for audio, video, images, and download collections.

### 2. Capabilities for Media Discovery
* **Other apps' public media:** If granted `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` (on Android 13+) or `READ_EXTERNAL_STORAGE` (on Android 10–12), an app can query public images and videos across `DCIM/`, `Pictures/`, and `Movies/`.
* **WhatsApp Public Media:** Regular incoming WhatsApp photos and videos saved to public media folders (e.g. `Pictures/WhatsApp/` or indexed by MediaStore) can be found in MediaStore.

### 3. Critical MediaStore Limitation for Statuses
* **Classification:** **NOT POSSIBLE** to discover WhatsApp Statuses via MediaStore (**VERIFIED**).
* **Technical Reason:**
  1. The directory name is `.Statuses`. In Unix and Android filesystems, any directory or file starting with a period (`.`) is hidden.
  2. WhatsApp creates a `.nomedia` sentinel file inside the `Media` and `.Statuses` directories.
  3. Under Android source code (`MediaScanner.java` / `MediaProvider.java`), any directory containing `.nomedia` or prefixed with `.` is explicitly bypassed during system media indexing.
  4. Querying `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` or `MediaStore.Video.Media.EXTERNAL_CONTENT_URI` will **never** yield status items.

### 4. Capabilities for Saving Media
* **Classification:** **VERIFIED**.
* `MediaStore` is the ideal, officially supported mechanism for **saving** statuses to the device gallery.
* Since Android 10 (API 29), an app does **not** need `WRITE_EXTERNAL_STORAGE` or any runtime permission to create new media files in `MediaStore.Images` or `MediaStore.Video`. The creating app has full ownership of the rows it inserts into `MediaStore`.

---

## Android 16 / API 36

### 1. Platform Timeline & Enforcement
* Android 16 (API 36) represents the current baseline target required for new applications and updates on Google Play.

### 2. Storage & Media Behavior Changes
* **Photo Picker Preference / Enforcement:** Google has continued to restrict broad media library access, pushing apps toward the system Photo Picker (`ActivityResultContracts.PickVisualMedia`). However, the Photo Picker allows users to choose *their own* photos for import; it cannot be used by a status saver to discover external status folders.
* **MediaStore Version Lockdown:** API 36 hardens `MediaStore` database operations, disallowing low-level hacks or unauthenticated version tampering in media providers.
* **Storage Access Framework in API 36:**
  * Directory blocking flags (`Document.FLAG_DIR_BLOCKS_OPEN_DOCUMENT_TREE`) continue to be enforced by `ExternalStorageProvider`.
  * The system file picker UI continues to restrict selecting the root of storage and sensitive app data directories.
* **Edge-to-Edge and 16 KB Page Compatibility:**
  * Mandatory edge-to-edge UI layout handling is enforced for apps targeting API 36.
  * Any native C/C++ libraries compiled into the APK must support 16 KB memory pages. (Standard Kotlin/Java and Flutter engine already support this).

---

## WhatsApp Status Discovery

### 1. WhatsApp Storage Layout
WhatsApp stores cached statuses locally on device once a user views them in the official WhatsApp app:

| Android Version | Primary Path | Business Path |
|---|---|---|
| **Android 10 and below** | `/storage/emulated/0/WhatsApp/Media/.Statuses` | `/storage/emulated/0/WhatsApp Business/Media/.Statuses` |
| **Android 11 – Android 16** | `/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses` | `/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses` |
| **Dual Apps / Cloned Accounts** | `/storage/emulated/<userId>/Android/media/com.whatsapp/...` (e.g. `userId = 999` on Xiaomi/Samsung) | Varies by OEM |

### 2. The Storage Access Framework (SAF) Mechanism
Because direct file access is blocked and MediaStore does not index hidden folders, **Storage Access Framework (SAF)** via `Intent.ACTION_OPEN_DOCUMENT_TREE` is the only non-root platform mechanism available.

#### How It Operates:
1. The app creates an `Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)`.
2. The app pre-populates `DocumentsContract.EXTRA_INITIAL_URI` pointing to the encoded URI of the target folder:
   ```kotlin
   val initialUri = Uri.parse(
       "content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia"
   )
   intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
   ```
3. The system opens `DocumentsUI` (the system document picker).
4. The user verifies the folder and taps **"Use this folder"**, then grants permission in the system confirmation prompt.
5. In `onActivityResult` / `ActivityResultCallback`, the app receives a `treeUri`.
6. The app calls:
   ```kotlin
   context.contentResolver.takePersistableUriPermission(
       treeUri,
       Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
   )
   ```
7. Once persisted, the app can enumerate children inside this tree across application restarts without reprompting the user.

### 3. Feasibility Classification Across Android Versions
* **Android 10 and below:** **VERIFIED**. Simple `File("/storage/emulated/0/WhatsApp/Media/.Statuses").listFiles()` works with `READ_EXTERNAL_STORAGE`.
* **Android 11 – 12 (API 30 – 32):** **VERIFIED**. SAF selection of `Android/media/com.whatsapp/...` functions smoothly with persisted tree URI.
* **Android 13 – 16 (API 33 – 36):** **LIKELY with platform & OEM constraints**:
  * **AOSP Baseline:** In stock AOSP `ExternalStorageProvider.java`, `shouldBlockDirectoryFromTree()` explicitly blocks `Android/data/`, `Android/obb/`, and `Android/sandbox/`. It does **not** block `Android/media/`.
  * **OEM Variations & Google Files Updates:** Some device vendors (and certain Google Play System updates to `com.google.android.documentsui`) have expanded the block rule or grayed out "Use this folder" for any subdirectory inside `/Android/`, returning the message: *"To protect your privacy, choose another folder"*.
  * **Targeting the Parent:** Requesting access to `Android/media/com.whatsapp/WhatsApp/Media` (the parent of `.Statuses`) is generally more reliable than requesting `.Statuses` directly, because `.Statuses` is hidden and invisible unless "Show hidden files" is toggled on in the system picker. Once access to `WhatsApp/Media` is granted, the app can programmatically query the hidden `.Statuses` subfolder via `DocumentsContract`.

---

## Image Access

### 1. Reading Discovered Images
* **Classification:** **VERIFIED**.
* Once the tree URI is acquired, individual image documents are referenced by document URIs:
  ```kotlin
  val documentUri = DocumentsContract.buildDocumentUriUsingTree(
      treeUri,
      documentId
  )
  ```
* Media stream extraction:
  ```kotlin
  val inputStream = context.contentResolver.openInputStream(documentUri)
  ```

### 2. High-Performance Thumbnail Generation
* Generating thumbnails is critical to prevent Out-Of-Memory (OOM) errors when displaying dozens of statuses in a Flutter grid:
  * **Android 10+ API:** `DocumentsContract.getDocumentThumbnail(contentResolver, documentUri, Point(width, height), null)` or `ImageDecoder.decodeBitmap`.
  * Alternatively, decode via `BitmapFactory.Options.inSampleSize` from `ContentResolver.openFileDescriptor(documentUri, "r")`.
* Thumbnails can be cached in the app's internal cache directory (`context.cacheDir/thumbnails/`) and served to Flutter via local file paths or memory buffers.

---

## Video Access

### 1. Reading Discovered Videos
* **Classification:** **VERIFIED**.
* Video documents in `.Statuses` (typically `.mp4`) can be opened via:
  ```kotlin
  val pfd = context.contentResolver.openFileDescriptor(documentUri, "r")
  ```

### 2. Playback Challenges & Solutions
* **Flutter `video_player` plugin:**
  * When fed a `content://` URI directly, some video players or platform codecs experience buffering delays or fail if the ContentProvider does not support random seek operations across SAF pipe streams.
* **Recommended Strategy for Smooth Playback:**
  * For the video viewer screen: Stream from `content://` or copy the target video to a temporary local cache file in `context.cacheDir/status_preview.mp4` when the user taps to play.
  * Local cache playback guarantees 100% hardware-accelerated, instantaneous seeking, scrub bar responsiveness, and zero SAF permission drops during playback.

---

## Permissions

### 1. Permissions Matrix by Android Version

| Android Version | API Level | Status Discovery Permission | Media Saving Permission | Mechanism |
|---|---|---|---|---|
| **Android 10 & below** | 28 – 29 | `READ_EXTERNAL_STORAGE` | `WRITE_EXTERNAL_STORAGE` | Runtime Permission + File API |
| **Android 11 – 12L** | 30 – 32 | None (SAF Tree Grant) | None (MediaStore API) | User Action via SAF `DocumentsUI` |
| **Android 13 – 16** | 33 – 36 | None (SAF Tree Grant) | None (MediaStore API) | User Action via SAF `DocumentsUI` |

### 2. Why `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` are NOT Applicable
* **Classification:** **VERIFIED**.
* Android 13 introduced `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` to replace `READ_EXTERNAL_STORAGE`.
* However, these permissions grant access **only to MediaStore collections**.
* Because WhatsApp statuses are located in a hidden directory (`.Statuses`) with `.nomedia`, MediaStore has no knowledge of them.
* Granting or denying `READ_MEDIA_IMAGES` has **zero effect** on an app's ability to read files inside WhatsApp's private `.Statuses` folder.

### 3. All Files Access (`MANAGE_EXTERNAL_STORAGE`)
* **Classification:** **VERIFIED** on device / **NOT POSSIBLE** on Google Play.
* Declaring `MANAGE_EXTERNAL_STORAGE` in the manifest and directing the user to `Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION` grants direct POSIX `File` access to `/Android/media/com.whatsapp/`.
* However, submitting an app with this permission to Google Play will cause immediate app rejection (see [Google Play Considerations](#google-play-considerations)).

---

## URI Handling

### 1. Structure of SAF Tree URIs
A tree URI returned by `ACTION_OPEN_DOCUMENT_TREE` looks like:
```text
content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia
```

To access a child document (or subfolder like `.Statuses`), the URI must be constructed via `DocumentsContract`:
```kotlin
val statusesDirUri = DocumentsContract.buildChildDocumentsUriUsingTree(
    treeUri,
    "primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses"
)
```

### 2. Querying Directory Contents via ContentResolver
Instead of using slow `DocumentFile.fromTreeUri()`, which issues individual ContentResolver queries per file and kills grid performance, production native code should query `ContentResolver` directly:
```kotlin
val projection = arrayOf(
    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
    DocumentsContract.Document.COLUMN_MIME_TYPE,
    DocumentsContract.Document.COLUMN_LAST_MODIFIED,
    DocumentsContract.Document.COLUMN_SIZE
)

val cursor = context.contentResolver.query(
    childrenUri,
    projection,
    null,
    null,
    "${DocumentsContract.Document.COLUMN_LAST_MODIFIED} DESC"
)
```

### 3. Taking Persistable URI Permissions
URI permissions granted by an activity result are temporary by default. To retain access when the app is closed or the device reboots:
```kotlin
val takeFlags: Int = intent.flags and (
    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
)
context.contentResolver.takePersistableUriPermission(treeUri, takeFlags)
```

---

## Flutter ↔ Kotlin Boundary

### 1. Architectural Boundary
In compliance with `AGENTS.md` (Section 5, 10, 11, 12), the UI must not know anything about Android storage internals, content URIs, or MediaStore.

```
+-------------------------------------------------------------+
|                     Flutter Presentation                    |
|             (StatusScreen, StatusGrid, MediaViewer)         |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                Application / State Layer (Riverpod)         |
|              (StatusViewModel, PermissionState)             |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                     Domain & Repository                     |
|           (StatusRepository, StatusItem, SavedMedia)        |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|              StatusScanner Platform Interface               |
|            (MethodChannel: status_scanner_channel)          |
+-------------------------------------------------------------+
                              |
                     Platform Channel Boundary
                              |
                              v
+-------------------------------------------------------------+
|                   Native Kotlin Plugin                      |
|                (AndroidStatusScanner.kt)                    |
+-------------------------------------------------------------+
           |                                  |
           v                                  v
+------------------------+      +-----------------------------+
|   SAF ContentResolver  |      |      MediaStore API         |
|  (Discovery & Reading) |      |    (Export / Saving Media)  |
+------------------------+      +-----------------------------+
```

### 2. Platform Channel Protocol Definition

#### Channel Name:
`com.example.whatsapp_status_saver/scanner`

#### Methods:
1. `checkFolderAccess()`
   * **Returns:** `Map<String, Any>`: `{ "hasAccess": Boolean, "persistedUri": String? }`
2. `requestFolderAccess(targetType: String)`
   * Initiates SAF picker via Android Activity result.
   * **Returns:** `Map<String, Any>`: `{ "granted": Boolean, "treeUri": String?, "error": String? }`
3. `scanStatuses()`
   * Queries child documents from persisted SAF URI.
   * **Returns:** `List<Map<String, Any>>`:
     ```json
     [
       {
         "id": "primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses/sample.jpg",
         "uri": "content://com.android.externalstorage.documents/...",
         "fileName": "sample.jpg",
         "mimeType": "image/jpeg",
         "dateModified": 1757068800000,
         "sizeBytes": 204850,
         "isVideo": false
       }
     ]
     ```
4. `getThumbnail(uri: String, width: Int, height: Int)`
   * Decodes and scales thumbnail in background isolate / coroutine, saves to app cache.
   * **Returns:** `String` (local filesystem path to cached thumbnail image).
5. `saveStatus(sourceUri: String, fileName: String, mimeType: String)`
   * Reads from source SAF URI, writes to `MediaStore.Images` or `MediaStore.Video`.
   * **Returns:** `Map<String, Any>`: `{ "success": Boolean, "savedUri": String?, "error": String? }`

---

## Google Play Considerations

### 1. `MANAGE_EXTERNAL_STORAGE` Policy
* **Policy Rule:** Google Play Developer Policy explicitly limits `MANAGE_EXTERNAL_STORAGE` to apps where the core purpose is file management, document management, antivirus, or device backup.
* **Status:** **NOT POSSIBLE** on Google Play. Status Saver apps requesting `MANAGE_EXTERNAL_STORAGE` are routinely rejected or removed during policy review.

### 2. Storage Access Framework (SAF) Compliance
* **Policy Rule:** SAF relies on explicit user consent via the system-provided file picker.
* **Status:** **VERIFIED COMPLIANT**. Google Play allows apps to use SAF to access folders that the user selects.

### 3. WhatsApp Branding & Trademark Policy
* **Play Policy:** Apps cannot impersonate WhatsApp or use the WhatsApp trademark deceptively.
* **Guidelines:**
  * App title must be "Status Saver for WhatsApp" or "Status Downloader", not "WhatsApp Status Saver" as an official-looking title.
  * Cannot copy official WhatsApp green launcher icons or logos without modification.

### 4. Privacy & User Data
* Status media belongs to contacts of the user.
* All processing must be strictly **on-device**.
* No network transmission, telemetry of media bytes, or uploading of statuses is permitted under privacy guidelines.

---

## Known Limitations

1. **WhatsApp Deletion / Expiration:** Status files are transient. WhatsApp automatically purges them after 24 hours. If a user does not view a status in WhatsApp, it is never downloaded to the local device.
2. **Hidden File Setting in System Picker:** If the user is prompted to pick `.Statuses` directly, the system picker hides dot-folders by default. The user must know to open the menu and tap "Show hidden storage/files".
   * *Mitigation:* Prompt the user to pick the parent folder (`WhatsApp/Media` or `com.whatsapp`), which is visible by default. The app then programmatically resolves the `.Statuses` subfolder within the granted tree.
3. **OEM Firmware Aggression:** Certain OEM skins (e.g. Xiaomi MIUI/HyperOS, Vivo Funtouch, or Samsung OneUI updates) have occasionally blocked picking `Android/media` entirely or suffered from DocumentsUI picker crashes.
4. **Dual WhatsApp / Work Profiles:** If WhatsApp is installed in a work profile or cloned app space (e.g. user `999`), the media resides under a different user storage ID that standard SAF cannot cross without cross-profile permissions.
5. **Future WhatsApp Architectural Shift:** If WhatsApp moves its status cache from `/storage/emulated/0/Android/media/` to its private internal sandbox `/data/user/0/com.whatsapp/cache/`, status discovery will become **permanently impossible** for all third-party applications on non-rooted devices.

---

## Recommended Approach

### Step 1: Hybrid Dual-Path Discovery Strategy
1. **Detect Android OS Version:**
   * If `SDK_INT <= 29` (Android 10 and below): Use legacy direct `File` discovery (`/WhatsApp/Media/.Statuses`) with `READ_EXTERNAL_STORAGE`.
   * If `SDK_INT >= 30` (Android 11 – 16): Use Storage Access Framework (`ACTION_OPEN_DOCUMENT_TREE`).

2. **Smart SAF Target Selection:**
   * Do **not** ask the user to pick `.Statuses` directly (avoids "hidden file" confusion).
   * Request permission for the parent directory:
     `Android/media/com.whatsapp/WhatsApp/Media`
   * Pre-seed `DocumentsContract.EXTRA_INITIAL_URI` pointing to this directory so the picker opens directly at the target folder.
   * Provide a 1-screen visual onboarding guide illustrating the exact button ("Use this folder" -> "Allow") before opening the system picker.

3. **Query via Native ContentResolver:**
   * Traverse the granted tree URI to find the `.Statuses` child directory.
   * Query the child documents via native Cursor with projection to retrieve metadata.

4. **Zero-Permission Export via MediaStore:**
   * Save images to `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` (`Pictures/SavedStatus`).
   * Save videos to `MediaStore.Video.Media.EXTERNAL_CONTENT_URI` (`Movies/SavedStatus`).
   * No runtime storage permission required.

---

## Open Questions

1. **Specific OEM Behavior on Latest Android 15/16 Security Updates:**
   * *Question:* Does the latest Google Play system update on physical Pixel or Samsung devices running Android 15/16 display *"To protect your privacy, choose another folder"* when selecting `Android/media/com.whatsapp/WhatsApp/Media`?
   * *Status:* **UNKNOWN** until validated on live target hardware or an active emulator running the latest image.

2. **WhatsApp Business and Dual Accounts:**
   * *Question:* Should the initial release support both WhatsApp Standard and WhatsApp Business, and can both tree permissions be stored concurrently in `ContentResolver`?
   * *Status:* Technically verified that multiple tree URIs can be persisted; product decision needed on multi-account UI.

3. **Direct Tree Subfolder Traversal:**
   * *Question:* If a user grants access to `WhatsApp/Media`, does every OEM's `ExternalStorageProvider` allow querying child documents of a hidden subfolder (`.Statuses`) without explicit grant on the child itself?
   * *Status:* **LIKELY** based on AOSP tree URI specification, requires verification in the POC.

---

## Recommended Android Proof-of-Concept (POC)

Before implementing the complete Flutter UI, navigation, database, or state management layers, implement the smallest possible Android Native proof-of-concept to validate SAF discovery and MediaStore export.

### POC Scope & Verification Criteria:
1. **Folder Selection:**
   * Launch `ACTION_OPEN_DOCUMENT_TREE` with `EXTRA_INITIAL_URI` configured for `primary:Android/media/com.whatsapp/WhatsApp/Media`.
   * Verify that the system picker opens and allows tapping **"Use this folder"** on the target test device/emulator without displaying *"To protect your privacy, choose another folder"*.
2. **Permission Persistence:**
   * Call `takePersistableUriPermission`. Restart the test app and verify that access remains active without reprompting.
3. **Child Document Enumeration:**
   * Resolve `.Statuses` within the tree URI.
   * Query `DocumentsContract.buildChildDocumentsUriUsingTree` and log file names, MIME types, and sizes.
4. **Media Stream Verification:**
   * Open `InputStream` on one sample image and one sample video from the status folder. Read bytes successfully.
5. **MediaStore Export Verification:**
   * Insert a test status into `MediaStore.Images.Media.EXTERNAL_CONTENT_URI`.
   * Confirm the saved image appears immediately in the device Gallery app.

*(Note: In accordance with project instructions, this POC is specified here for evaluation and should NOT be implemented until explicitly requested).*
