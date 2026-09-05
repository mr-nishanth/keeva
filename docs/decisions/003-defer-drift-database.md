# ADR 003: Deferral of Drift / SQLite Database for Phase 2

## Context
Previous architectural discussions considered `drift` (SQLite) for storing metadata, status caches, and saved status items.
Drift requires `drift`, `sqlite3_flutter_libs`, `build_runner`, and `drift_dev`, significantly increasing code generation time, binary size, and complexity.

## Evaluation of Phase 2 Data Requirements
1. **Status Discovery Cache:** Status items are ephemeral (WhatsApp purges them within 24 hours). Persisting them in a local relational database creates stale cache inconsistencies. Fresh live scans via ContentResolver take < 50 ms.
2. **Selected Folder Grant:** Persisted by Android OS via `ContentResolver.persistedUriPermissions`.
3. **Saved Items Tracker:** A simple list of saved filenames/hashes is needed to display "Saved" badges in the UI and populate a "Saved" tab (< 100 items typical).
4. **Settings:** Active theme mode and default WhatsApp package (key-value data).

## Decision
Do not introduce `drift` or SQLite in Phase 2.
Use `shared_preferences` and lightweight JSON records via `path_provider` for saved media tracking and settings.
Keep the `SavedMediaRepository` contract abstract. If Phase 3 introduces multi-album organization, custom tagging, or full-text search, Drift can be plugged in behind `SavedMediaRepository` without altering presentation or domain logic.

## Status
Accepted.

## Consequences
- **Positive:** Zero code generation overhead (`build_runner`). Fast CI/CD builds. Minimal APK size impact. Simple and robust.
- **Negative:** Limited complex querying, which is not required for Phase 2.
