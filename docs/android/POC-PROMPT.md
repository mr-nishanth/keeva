# Native Android SAF POC
## WhatsApp Status Saver
## Phase: Storage Feasibility Validation

You are working inside:

~/development/whatsapp_status_saver

This is NOT production implementation.

Your task is to build the smallest possible native Android Proof of Concept
that validates whether our Flutter app can access WhatsApp Status media through
the Android Storage Access Framework on the real physical test device.

============================================================
PRIMARY TEST DEVICE
============================================================

Manufacturer:
Xiaomi

Model:
2311DRK48I

Product:
duchamp_in

Android:
16

API:
36

ABI:
arm64-v8a

HyperOS:
3.0

WhatsApp package:
com.whatsapp

ADB transport:
wireless

The physical Xiaomi device is the PRIMARY and REQUIRED validation target.

Do NOT substitute the emulator.

============================================================
KNOWN LIVE DEVICE STATE
============================================================

ADB inspection has already verified:

/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/

The directory currently contains:

- .nomedia
- JPG status media
- MP4 status media

Example files previously observed:

6e0d286c8a4e4492ba09b360cfd5a522.jpg

e319ecbbbfe94152a565828f465f452f.mp4

e5e208ede1fb4112adb2a4c680a90717.mp4

These are real files on the physical device.

Do NOT fabricate test media.

============================================================
AUTHORITATIVE PROJECT DOCUMENT
============================================================

Read:

docs/android/storage-access.md

before implementation.

Do not contradict its architecture or POC requirements.

============================================================
OBJECTIVE
============================================================

Prove or disprove the following flow:

Flutter app
    ↓
Native Kotlin
    ↓
ACTION_OPEN_DOCUMENT_TREE
    ↓
User grants access to:

Android/media/com.whatsapp/WhatsApp/Media
    ↓
Persist tree URI permission
    ↓
Traverse child documents
    ↓
Locate .Statuses
    ↓
Enumerate JPG/MP4
    ↓
Open streams
    ↓
Read bytes
    ↓
Export one image using MediaStore

============================================================
STRICT SCOPE
============================================================

Implement ONLY:

1. SAF folder picker
2. Persisted tree URI permission
3. Existing persisted permission detection
4. .Statuses child traversal
5. Status file enumeration
6. Metadata extraction
7. Image byte-read verification
8. Video byte-read verification
9. One MediaStore image export
10. POC diagnostic output
11. Minimal Flutter MethodChannel bridge if required to
    launch and display the native POC

Do NOT implement:

- Riverpod
- GoRouter
- Drift
- SQLite
- production repositories
- production domain models
- status grid
- polished UI
- onboarding
- animations
- caching architecture
- video player
- thumbnail system
- background scanning
- notifications
- authentication
- analytics
- networking
- Firebase
- ads
- MANAGE_EXTERNAL_STORAGE
- READ_MEDIA_IMAGES
- READ_MEDIA_VIDEO

============================================================
ANDROID STORAGE RULES
============================================================

Do NOT use:

MANAGE_EXTERNAL_STORAGE

Do NOT attempt to bypass Android storage restrictions.

Do NOT use root.

Do NOT use shell commands from inside the application to read
WhatsApp files.

Do NOT use java.io.File against:

/Android/media/com.whatsapp/...

The POC must use:

ACTION_OPEN_DOCUMENT_TREE

and:

ContentResolver

and:

DocumentsContract

============================================================
TARGET TREE
============================================================

The preferred user-selected directory is:

Android/media/com.whatsapp/WhatsApp/Media

Do NOT initially ask the user to select:

.Statuses

because it is hidden.

Use EXTRA_INITIAL_URI where supported to suggest:

content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia

However:

DO NOT assume that the picker will accept the URI.

The actual result on the Xiaomi device is what matters.

============================================================
POC TEST 1
============================================================

Launch:

ACTION_OPEN_DOCUMENT_TREE

with:

EXTRA_INITIAL_URI

pointing at:

Android/media/com.whatsapp/WhatsApp/Media

Record:

- picker launched
- initial location
- whether Media directory is visible
- whether "Use this folder" is enabled
- whether Xiaomi shows a privacy restriction
- final selected URI

The user must manually approve the folder.

============================================================
POC TEST 2
============================================================

When the result returns:

- obtain treeUri
- inspect intent flags
- persist read permission using
  takePersistableUriPermission()

Use READ access only unless WRITE access is genuinely required.

Record:

- granted
- treeUri
- persisted permission result
- exception if persistence fails

============================================================
POC TEST 3
============================================================

After permission is granted:

Use ContentResolver + DocumentsContract.

Do NOT use DocumentFile for the main traversal.

Resolve:

.Statuses

under:

WhatsApp/Media

Then enumerate children.

Record for every discovered status:

- documentId
- displayName
- mimeType
- size
- lastModified
- URI

Only report actual files.

Do not assume a fixed filename.

============================================================
POC TEST 4
============================================================

Find at least:

- one JPG/image
- one MP4/video

If either does not exist, report:

NOT FOUND

Do not create fake files.

============================================================
POC TEST 5
============================================================

For the discovered JPG:

Open using:

ContentResolver.openInputStream()

Read the complete stream.

Record:

- bytes requested
- bytes successfully read
- success/failure
- exception

For the discovered MP4:

Perform the same test.

Do not play the video.

This test is only verifying readable bytes.

============================================================
POC TEST 6
============================================================

Export ONE discovered JPG to MediaStore.

Use:

MediaStore.Images.Media.EXTERNAL_CONTENT_URI

Use MediaStore insertion with:

DISPLAY_NAME
MIME_TYPE
RELATIVE_PATH
IS_PENDING

Use a suitable application-owned gallery directory such as:

Pictures/StatusSaverPOC/

Write the bytes from the SAF InputStream into the MediaStore output stream.

Finalize IS_PENDING.

Record:

- inserted URI
- bytes copied
- success/failure

Do not request WRITE_EXTERNAL_STORAGE.

============================================================
POC TEST 7
============================================================

Verify persisted access.

After the first successful permission grant:

1. Kill the app.
2. Relaunch it.
3. Call checkFolderAccess().
4. Verify that the previously persisted tree URI is still usable.
5. Enumerate .Statuses again.

The POC must demonstrate that the app can reopen the tree without
asking the user for permission again.

============================================================
FLUTTER ↔ KOTLIN BOUNDARY
============================================================

If a MethodChannel is used, keep it minimal.

Channel:

com.example.whatsapp_status_saver/scanner

Methods:

checkFolderAccess

requestFolderAccess

scanStatuses

verifyMediaRead

saveTestImage

Return simple Maps/Lists.

Example:

checkFolderAccess()

{
  "hasAccess": true,
  "treeUri": "content://..."
}

scanStatuses()

[
  {
    "displayName": "...jpg",
    "mimeType": "image/jpeg",
    "sizeBytes": 87600,
    "lastModified": 123456789,
    "uri": "content://..."
  }
]

Do not design production models yet.

============================================================
DIAGNOSTIC OUTPUT
============================================================

Create a clear diagnostic report.

Example:

==================================================
WHATSAPP STATUS SAF POC
==================================================

DEVICE
--------------------------------------------------
Manufacturer: Xiaomi
Model: 2311DRK48I
Android: 16
API: 36
HyperOS: 3.0
WhatsApp: com.whatsapp

SAF
--------------------------------------------------
Picker launched:              PASS / FAIL
Initial URI accepted:         PASS / FAIL
Media folder selectable:     PASS / FAIL
User grant received:          PASS / FAIL
Persisted URI permission:     PASS / FAIL

WHATSAPP MEDIA
--------------------------------------------------
Media folder accessible:      PASS / FAIL
.Statuses discovered:         PASS / FAIL
Status files enumerated:      PASS / FAIL

MEDIA READ
--------------------------------------------------
Image discovered:             PASS / FAIL
Image bytes readable:         PASS / FAIL
Video discovered:             PASS / FAIL
Video bytes readable:         PASS / FAIL

MEDIASTORE
--------------------------------------------------
Image inserted:               PASS / FAIL
Gallery URI returned:         PASS / FAIL

PERSISTENCE
--------------------------------------------------
Access survives restart:      PASS / FAIL

==================================================
FINAL RESULT
==================================================

SAF STATUS ACCESS:

VERIFIED
FAILED
or
PARTIALLY VERIFIED

============================================================

IMPORTANT:

Do not call the result VERIFIED merely because the picker opened.

The final result is VERIFIED only if all critical operations succeed:

1. User can grant Media folder access
2. URI can be persisted
3. .Statuses can be traversed
4. Real JPG is discovered
5. Real JPG bytes can be read
6. Real MP4 is discovered
7. Real MP4 bytes can be read
8. Image can be exported through MediaStore
9. Persisted permission works after app restart

============================================================
DOCUMENTATION
============================================================

After implementation and testing:

Update:

docs/android/storage-access.md

with the ACTUAL Xiaomi Android 16 results.

Do not replace UNKNOWN with VERIFIED unless the test actually passed.

Add a section:

## Physical Device POC Results

Include:

- device
- OS
- HyperOS
- picker behavior
- selected URI
- persisted URI result
- .Statuses traversal result
- image read result
- video read result
- MediaStore export result
- restart/persistence result
- final verdict

============================================================
VALIDATION COMMANDS
============================================================

Use the physical device:

adb devices -l

flutter devices

Run the Flutter application specifically on the physical Android device.

Do not select macOS.

Do not select Chrome.

After implementation:

flutter analyze

flutter test

flutter build apk --debug

Install/run on the physical Xiaomi device.

Use adb logcat if native diagnostics are needed.

============================================================
GIT
============================================================

Do not commit automatically.

Before finishing:

git status

Show all changed files.

Show the exact commands used for validation.

Show the complete POC result.

STOP if the SAF picker cannot grant the target folder.

Do not work around the failure using:

- MANAGE_EXTERNAL_STORAGE
- root
- hidden APIs
- adb permissions
- filesystem hacks
- third-party storage bypasses

The purpose of this POC is to establish the real platform capability,
not to manufacture a successful result.

============================================================
DEFINITION OF DONE
============================================================

The POC is complete only when:

[ ] Physical Xiaomi device tested
[ ] SAF picker tested
[ ] Target folder grant tested
[ ] URI persistence tested
[ ] .Statuses traversal tested
[ ] Real JPG discovered
[ ] Real JPG read
[ ] Real MP4 discovered
[ ] Real MP4 read
[ ] MediaStore image export tested
[ ] App restart persistence tested
[ ] Diagnostic report produced
[ ] storage-access.md updated
[ ] flutter analyze passes
[ ] flutter test passes
[ ] debug APK builds
[ ] git diff reviewed

Do not proceed to production architecture after this task.

Return the POC results first.