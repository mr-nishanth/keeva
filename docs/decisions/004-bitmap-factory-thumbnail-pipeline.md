# ADR 004: Native Background Thumbnail Downsampling via BitmapFactory

## Context
WhatsApp status photos can be 5–15 MB high-resolution images.
Decoding full-resolution images into Flutter memory (`dart:ui`) inside a scrolling grid of dozens of status items causes severe frame drops, UI freezes, and Out-Of-Memory (OOM) crashes.
We evaluated three native thumbnail strategies:
1. `DocumentsContract.getDocumentThumbnail()`: Inconsistent behavior across OEM DocumentProviders (often returns null).
2. `ImageDecoder.decodeBitmap()`: Hardware accelerated, but limited to Android 9+ and higher peak memory during decoding.
3. `BitmapFactory.decodeFileDescriptor()` with `inSampleSize`: Universal compatibility (API 1+), precise memory consumption calculation, and deterministic downsampling.

## Decision
Implement native thumbnail generation using `BitmapFactory` with `inSampleSize` downsampling:
1. Native `ThumbnailManager` opens a `FileDescriptor` via `ContentResolver.openFileDescriptor(documentUri, "r")`.
2. Inspects raw dimensions with `inJustDecodeBounds = true`.
3. Calculates `inSampleSize` to target 256x256 pixel bounds.
4. Decodes downsampled bitmap and encodes as WebP (or JPEG 85%) into internal app cache (`context.cacheDir/thumbnails/<docIdHash>.webp`).
5. Returns the local file path to Flutter.
6. Flutter renders using `Image.file()` with standard image cache parameters.

## Status
Accepted.

## Consequences
- **Positive:** UI isolate never decodes full-resolution images. Bounded memory consumption (< 30 MB heap). High-frame-rate scrolling on budget devices. Disk cache survives until Android cleans cache under memory pressure.
- **Negative:** Requires initial decode time (< 30 ms per image on background thread). Mitigated by asynchronous loading and placeholder skeleton UI in grid cells.
