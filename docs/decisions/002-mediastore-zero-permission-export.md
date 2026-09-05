# ADR 002: Zero-Permission MediaStore Saving with Atomic Rollback

## Context
Status saver applications need to save discovered photos and videos permanently to the user's gallery.
Legacy approaches relied on `WRITE_EXTERNAL_STORAGE` and direct file writes to `/sdcard/Pictures/`, which are restricted on Android 10+ and deprecated on Android 13+.
Third-party libraries like `gal` or `image_gallery_saver` introduce extra dependencies, often request legacy permissions unnecessarily, or fail to handle atomic rollbacks when stream copy is interrupted.

## Decision
Implement a native Kotlin `MediaStoreSaver` that directly inserts entries into:
- `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` with `RELATIVE_PATH = "Pictures/SavedStatus/"`
- `MediaStore.Video.Media.EXTERNAL_CONTENT_URI` with `RELATIVE_PATH = "Movies/SavedStatus/"`
Utilize `IS_PENDING = 1` during the stream transfer from SAF `InputStream` to MediaStore `OutputStream`.
Finalize with `IS_PENDING = 0` on success.
Enforce **atomic rollback**: if stream copying fails or throws an exception, immediately call `contentResolver.delete(targetUri, null, null)` before propagating the error, ensuring no corrupt 0-byte orphan files remain in the gallery.

## Status
Accepted and verified on physical hardware (Xiaomi 2311DRK48I / Android 16 / HyperOS 3.0).

## Consequences
- **Positive:** Zero runtime permissions required on Android 10+ (API 29–36). Immediate visibility in Google Photos, Xiaomi Gallery, Samsung Gallery. Clean gallery state with atomic failure cleanup. No external plugin dependencies.
- **Negative:** Requires handling Android 9 legacy storage opt-ins if backwards compatibility is extended below API 29.
