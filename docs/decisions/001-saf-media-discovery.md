# ADR 001: Storage Access Framework (SAF) for Status Discovery

## Context
On modern Android (API 30–36 / Android 11–16), WhatsApp stores status media in `/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses`.
Direct POSIX file APIs (`java.io.File`) are blocked by the Linux kernel/FUSE layer.
System MediaStore indexes ignore hidden folders (prefixed with `.`) and directories containing `.nomedia`, returning 0 results.
Broad storage access (`MANAGE_EXTERNAL_STORAGE`) violates Google Play Developer Policy for status savers and causes automatic store rejection.

## Decision
Use Android Storage Access Framework (SAF) via `Intent.ACTION_OPEN_DOCUMENT_TREE` with `DocumentsContract.EXTRA_INITIAL_URI` pointing to `primary:Android/media/com.whatsapp/WhatsApp/Media`.
Acquire and persist read permissions via `ContentResolver.takePersistableUriPermission(treeUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)`.
Enumerate status files using direct `ContentResolver.query()` cursor projections over `DocumentsContract.buildChildDocumentsUriUsingTree()`.

## Status
Accepted and verified on physical hardware (Xiaomi 2311DRK48I / Android 16 / HyperOS 3.0).

## Consequences
- **Positive:** Complies 100% with Google Play policy. Operates without root or dangerous permissions. Survives device restarts and app updates. High performance through projection-based cursor queries.
- **Negative:** Requires an initial one-time user interaction via the system file picker (`DocumentsUI`).
- **Mitigation:** Provide a step-by-step visual onboarding guide illustrating the exact "Use this folder" -> "Allow" buttons before opening the picker.
