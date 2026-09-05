# ADR 006: Opaque String Identifiers across the Platform Boundary

## Context
Flutter UI needs a stable identifier for each `StatusItem` to support:
- Unique keys in `GridView.builder`
- Hero animations
- Selection tracking
- State notifiers managing item-specific save progress

If the native layer passes raw Android SAF URIs (`content://com.android.externalstorage.documents/...`) or raw Document IDs (`primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses/...`), the UI becomes tightly coupled to Android storage implementation details, violating the core architectural boundary mandated by `AGENTS.md`.

## Decision
1. The domain entity `StatusItem` uses a single `final String id` property.
2. For the Android platform, `id` is the stable encoded document identifier or its SHA-256 hash.
3. The UI treats `id` as an opaque token. It passes `id` back through use cases to repository methods (`getThumbnailPath(item)`, `saveStatus(item)`, `prepareVideoPlayback(item)`).
4. Only the native platform layer (`StatusDocumentReader` / `AndroidStatusScanner`) maps `id` back to the actual SAF document URI when opening streams.
5. In test environments or iOS implementations, `id` can represent a file path, UUID, or mock identifier without altering any domain or UI code.

## Status
Accepted.

## Consequences
- **Positive:** UI never knows about SAF, Document IDs, or Content URIs. Architecture remains strictly testable and decoupled.
- **Negative:** None.
