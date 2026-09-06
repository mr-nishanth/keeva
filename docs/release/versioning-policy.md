# Keeva Versioning Policy

**Product:** Keeva
**Developer:** Nishvanta Labs
**Package:** `io.nishvanta.keeva`

---

## 1. Overview

Keeva follows standard semantic versioning for human-facing releases combined with a strictly monotonic integer sequence for Android platform builds.

Version declarations originate in `pubspec.yaml`:

```yaml
version: MAJOR.MINOR.PATCH+BUILD
```

When building for Android, Flutter automatically maps:
- `MAJOR.MINOR.PATCH` $\rightarrow$ `versionName` (visible in system settings, stores, and user-facing dialogs)
- `BUILD` $\rightarrow$ `versionCode` (internal integer evaluated by Android OS and package managers)

---

## 2. Component Specifications

### 2.1 `versionName` (User-Facing Version)

Format: `MAJOR.MINOR.PATCH` (e.g., `1.0.0`)

- **MAJOR**: Incremented for significant architectural shifts, complete UI redesigns, or foundational platform paradigm changes.
- **MINOR**: Incremented for new functional capabilities, features, or substantial enhancements (e.g., adding new tab views, advanced media handling, additional export capabilities).
- **PATCH**: Incremented for bug fixes, performance optimizations, security patches, or documentation updates that do not introduce new user-facing features.

Pre-release tags (e.g., `1.0.0-rc.1`) may be appended in release notes or git tags, but store distribution builds must use canonical numeric semantic versions.

### 2.2 `versionCode` (Android Platform Build Number)

Format: Positive 32-bit Integer (`1`, `2`, `3`, ...)

#### Mandatory Rules:
1. **Strictly Monotonic Increase:** Every production, beta, or internal release artifact submitted to a store or distributed to users **must** have a higher `versionCode` than the previous build.
2. **Never Reuse a `versionCode`:** Once an APK or Android App Bundle (AAB) with a given `versionCode` has been published or uploaded to a release track, that integer can never be reused, even if the release was halted or rolled back.
3. **Never Decrease a `versionCode`:** Android package managers refuse updates where `versionCode` is lower than the currently installed version (downgrade rejection).
4. **Independence from `versionName`:** `versionCode` is completely decoupled from `versionName`. Multiple internal builds or hotfixes of `1.0.0` can have `versionCode` values of `1`, `2`, `3`, etc.
5. **No ABI-Specific Offset Overwrites:** Flutter's default tooling can add `1000 * ABI_VERSION` when building split APKs. When publishing Android App Bundles (AAB), a single unified `versionCode` is processed and managed by Google Play.

---

## 3. Current Release Baseline

For the initial release milestone (Phase 3A):

```yaml
version: 1.0.0+1
```

- `versionName`: `1.0.0`
- `versionCode`: `1`

This baseline will be preserved for the first release candidate. Any change to `versionCode` will occur only when cutting subsequent distribution builds.
