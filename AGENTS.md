# AGENTS.md

## WhatsApp Status Saver

This file defines the project-wide engineering rules, architecture, workflow, and quality standards for AI coding agents working on this repository.

These instructions apply to all AI coding agents operating inside this repository.

---

# 1. Project Overview

**Project:** WhatsApp Status Saver

**Technology:**

* Flutter
* Dart
* Android-first
* Kotlin for Android-specific functionality
* iOS support maintained where practical

**Primary target:**

* Android

**Secondary target:**

* iOS

**Current repository root:**

```text
<project-root>
```

The application is a native-feeling Flutter app for discovering, previewing, saving, organizing, and managing WhatsApp Status media.

The application must prioritize:

1. Reliable Android media discovery
2. Fast and smooth media browsing
3. Safe and predictable saving behavior
4. Clear permission handling
5. Clean architecture
6. Testability
7. Maintainable native Android integration
8. High-quality UI/UX
9. Minimal unnecessary dependencies
10. Correct behavior across supported Android versions

---

# 2. Current Project State

The project was created using Flutter's standard project generator.

The baseline has already been verified:

```text
flutter pub get     ✓
flutter analyze     ✓
flutter test        ✓
Android emulator    ✓
flutter build apk   ✓
```

Do not assume additional dependencies, architecture, native APIs, or product behavior have already been implemented.

The current Flutter-generated project is the starting point.

Do not rewrite the project from scratch unless explicitly instructed.

---

# 3. Source of Truth

When instructions conflict, use this priority order:

1. Explicit user instruction in the current task
2. Approved product/architecture specifications in `docs/`
3. This `AGENTS.md`
4. `CLAUDE.md` or other agent-specific instructions
5. Existing implementation
6. Agent assumptions

Never silently override an explicit user decision.

If an existing implementation conflicts with an approved specification, do not silently change behavior.

Explain the conflict and propose the smallest safe change.

---

# 4. Development Philosophy

Build the application incrementally.

Do not attempt to implement the entire application in one operation.

Every meaningful phase should:

1. Have a clearly defined goal
2. Define the files that will change
3. Implement the smallest complete slice
4. Run static analysis
5. Run relevant tests
6. Verify the Android build
7. Review the resulting diff
8. Commit the completed phase

Prefer small, reversible changes over large rewrites.

---

# 5. Architecture

Use a feature-oriented architecture with clear separation between:

```text
Presentation
    ↓
Application / State
    ↓
Domain
    ↓
Data
    ↓
Platform / Native Services
```

Not every feature requires every layer.

Do not create abstraction layers simply for the sake of abstraction.

Flutter's recommended architecture emphasizes separation of concerns, UI/data boundaries, repositories, ViewModels/Views, dependency injection, unidirectional data flow, and testability.

---

# 6. Feature-First Organization

Prefer organizing application code by feature rather than creating large global folders such as:

```text
screens/
widgets/
services/
utils/
```

Use a structure similar to:

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_typography.dart
│       └── app_spacing.dart
│
├── core/
│   ├── errors/
│   ├── extensions/
│   ├── permissions/
│   ├── storage/
│   ├── media/
│   └── utils/
│
└── features/
    ├── onboarding/
    ├── statuses/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── viewer/
    ├── saved/
    ├── favorites/
    ├── albums/
    └── settings/
```

Adapt this structure when implementation requirements justify it.

Do not create empty folders simply to match a diagram.

---

# 7. UI Architecture

Keep Flutter widgets focused on presentation.

Views should:

* Render state
* Forward user interactions
* Display loading/error/empty states
* Avoid direct database access
* Avoid direct filesystem access
* Avoid direct MediaStore access
* Avoid direct platform-channel calls
* Avoid business logic where practical

Do not put code such as this inside UI widgets:

```dart
Directory(...);
```

```dart
MediaStore.query(...);
```

```dart
MethodChannel(...);
```

```dart
database.execute(...);
```

Instead, UI code should communicate through the appropriate state/application layer.

---

# 8. State Management

Use a predictable, unidirectional state flow.

Preferred conceptual flow:

```text
User action
    ↓
View
    ↓
ViewModel / Controller
    ↓
Repository / Use Case
    ↓
Service
    ↓
Data / Platform
    ↓
State update
    ↓
View
```

State should flow toward the UI.

User events should flow toward the data/application layer.

Avoid:

* Global mutable state
* Hidden singleton state
* Static mutable repositories
* Business logic inside widgets
* Circular dependencies
* UI-driven database mutations

Use immutable state where practical.

---

# 9. Repository Pattern

Repositories are the application's source of truth for data.

Examples:

```text
StatusRepository
SavedMediaRepository
FavoritesRepository
SettingsRepository
```

Repositories should hide the underlying implementation.

For example:

```text
StatusRepository
       │
       ├── StatusScanner
       ├── MediaStore
       └── Local metadata
```

The UI must not need to know where status media comes from.

---

# 10. Native Android Boundary

Android-specific behavior must remain isolated.

The WhatsApp Status discovery layer is expected to follow this general architecture:

```text
Flutter UI
    ↓
StatusRepository
    ↓
StatusScanner abstraction
    ↓
Android implementation
    ↓
Kotlin
    ↓
Android Media APIs
```

Do not scatter Android-specific path assumptions throughout Dart code.

Do not hard-code WhatsApp storage paths in multiple locations.

Android storage behavior varies across Android versions and device implementations.

Keep platform-specific behavior behind a narrow interface.

---

# 11. Kotlin Rules

Use Kotlin for Android-specific functionality when Flutter/Dart alone is insufficient.

Examples include:

* Android media discovery
* MediaStore integration
* Android-specific permission behavior
* Storage framework integration
* Platform-specific media metadata
* Native Android APIs not adequately exposed by a Flutter package

Keep Kotlin classes small and focused.

Do not move normal Flutter application logic into Kotlin.

Do not create native code merely because it is possible.

Use native Android code only where platform functionality actually requires it.

---

# 12. Platform Channels

When Dart needs to communicate with native Android functionality:

* Keep channel names centralized
* Keep method names documented
* Use typed request/response models where practical
* Validate arguments on both sides
* Return structured errors
* Avoid exposing unnecessary native implementation details
* Keep platform-channel code isolated

Prefer a small platform API such as:

```text
scanStatuses()
getStatusMetadata()
openMedia()
```

over exposing many low-level native methods.

---

# 13. Android Media and Storage

Android media access is a high-risk technical area of this application.

Treat it as a first-class architectural concern.

Do not assume that a filesystem path will work on every Android version.

Do not assume that:

```text
/Android/media/com.whatsapp/...
```

will always be directly readable.

Before implementing production media discovery:

1. Verify the Android version
2. Verify the WhatsApp installation/package behavior
3. Verify available media APIs
4. Verify permissions
5. Verify access to the required media
6. Test on the emulator
7. Test on a physical Android device when available

Build a small proof of concept before building the complete Status UI around an unverified storage strategy.

---

# 14. Permissions

Permissions must be treated as application state.

Handle:

```text
unknown
requesting
granted
denied
permanently denied
restricted / unavailable
```

Do not repeatedly request permissions without user interaction.

Explain why access is needed before requesting it when appropriate.

Permission-related UI must provide a useful recovery path.

Do not assume a permission is permanently available simply because it was granted once.

---

# 15. Dependencies

Do not add a package simply because it is popular.

Before adding a dependency:

1. Confirm that the functionality is actually required
2. Check whether Flutter/Dart already provides the functionality
3. Check package maintenance
4. Check platform support
5. Check Android compatibility
6. Check iOS compatibility if relevant
7. Check licensing
8. Check transitive dependency impact
9. Check whether native integration is required
10. Confirm that the dependency fits the architecture

Add dependencies deliberately.

Avoid dependency sprawl.

After adding a dependency:

```bash
flutter pub get
flutter analyze
flutter test
```

and verify the relevant platform build.

---

# 16. Preferred Technology Direction

The current planned technology direction is:

```text
Flutter
Dart
Riverpod
go_router
Drift / SQLite
photo_manager
gal
video_player
permission_handler
path_provider
Kotlin
Android Media APIs
```

These are architectural candidates, not permission to install everything immediately.

Each dependency must be evaluated before adoption.

If a package is no longer appropriate because of current Flutter/Android APIs, prefer the technically correct current solution.

Do not blindly follow an old specification when current platform behavior proves it incorrect.

---

# 17. Navigation

Prefer declarative routing.

Use `go_router` if navigation requirements justify it.

Keep route definitions centralized.

Do not place navigation logic throughout unrelated widgets.

Routes should represent application destinations rather than low-level UI components.

---

# 18. Data Models

Prefer immutable models.

Models should represent meaningful application concepts.

Examples:

```text
StatusItem
MediaItem
SavedMedia
FavoriteItem
Album
AppSettings
PermissionState
```

Avoid passing unstructured maps throughout the application.

Avoid:

```dart
Map<String, dynamic>
```

as a general-purpose application data model.

Use explicit types.

---

# 19. Error Handling

Errors must be intentional and user-safe.

Separate:

```text
Technical error
Application error
User-facing message
```

Do not expose raw exceptions to users.

Do not silently swallow errors.

Bad:

```dart
try {
  ...
} catch (_) {}
```

Prefer:

```text
catch
    ↓
log / classify
    ↓
return application error
    ↓
display appropriate UI
```

---

# 20. Loading and Empty States

Every asynchronous feature should consider:

```text
Initial
Loading
Success
Empty
Error
Refreshing
```

Do not design only the successful state.

For media-heavy screens, consider:

* Skeleton/loading state
* Empty status state
* Permission state
* Media unavailable state
* Scan failure state
* Retry state

---

# 21. Performance

Media browsing must remain smooth.

Avoid unnecessary:

* Widget rebuilds
* Image decoding
* Full-resolution thumbnail loading
* Database queries
* Directory scans
* Native bridge calls
* Synchronous work on the UI isolate

Prefer lazy loading and thumbnail-sized media for grids.

Do not load an entire media library into memory if only a subset is visible.

Measure before introducing complicated optimizations.

---

# 22. UI/UX Rules

The application should feel like a polished production mobile application.

Prioritize:

* Clear hierarchy
* Consistent spacing
* Predictable navigation
* Strong empty states
* Responsive interactions
* Smooth media transitions
* Accessible touch targets
* Good typography
* Correct dark/light behavior where supported
* Minimal visual clutter

Do not blindly copy another application's UI.

Use references for inspiration while maintaining an original product identity.

---

# 23. Shared Design System

Centralize visual decisions.

Prefer:

```text
app/theme/
├── app_theme.dart
├── app_colors.dart
├── app_typography.dart
└── app_spacing.dart
```

Avoid scattering arbitrary values throughout the codebase.

Avoid repeated:

```dart
EdgeInsets.all(17)
```

or arbitrary colors throughout unrelated files when the value represents a reusable design token.

Use semantic naming.

---

# 24. Accessibility

Consider:

* Semantic labels
* Sufficient touch targets
* Text scaling
* Contrast
* Screen reader behavior
* Focus behavior
* Motion sensitivity where relevant

Icons must have meaningful semantics when they perform an action.

Do not rely solely on color to communicate state.

---

# 25. Testing Requirements

Tests are part of implementation, not a final step.

At minimum, test:

### Unit tests

* Repositories
* Services
* ViewModels/controllers
* Business logic
* Parsers
* Media classification
* Sorting/filtering logic

### Widget tests

* Important screens
* Loading states
* Empty states
* Error states
* Permission states
* Navigation behavior

### Integration tests

Use for important end-to-end flows such as:

```text
Launch
  ↓
Permission
  ↓
Discover statuses
  ↓
Open status
  ↓
Save media
  ↓
Verify saved state
```

Use fakes for external dependencies where practical.

---

# 26. Verification Commands

Before considering a change complete, run the smallest relevant verification set.

Standard baseline:

```bash
flutter pub get
flutter analyze
flutter test
```

Android verification:

```bash
flutter build apk --debug
```

When appropriate:

```bash
flutter test integration_test
```

For release verification:

```bash
flutter build apk --release
```

Do not claim a build passed unless the command actually completed successfully.

---

# 27. Formatting

Use Dart formatter.

Run:

```bash
dart format .
```

or format only changed Dart files when appropriate.

Do not manually fight the formatter.

Keep imports clean.

Follow the project's configured lints.

---

# 28. Git Discipline

Use small, meaningful commits.

Examples:

```text
chore: initialize Flutter project
feat: add application shell
feat: add status repository contract
feat: add Android status scanner
feat: add status grid
feat: add media viewer
fix: handle denied media permission
test: cover status repository
refactor: isolate Android media service
```

Do not create commits such as:

```text
changes
update
fix stuff
test
final
```

Never commit:

* API keys
* Signing secrets
* Passwords
* Tokens
* Private certificates
* Local machine secrets
* Generated credentials

---

# 29. Generated Files

Do not manually edit generated Flutter files unless required.

Do not commit build output that is already ignored.

Examples of generated/build artifacts include:

```text
build/
.dart_tool/
```

Respect the repository's `.gitignore`.

Do not modify generated files merely to make an error disappear.

Find and fix the source of the problem.

---

# 30. Existing Platform Folders

The Flutter-generated project currently contains:

```text
android/
ios/
linux/
macos/
web/
windows/
```

Do not remove platform folders merely because the application is Android-first.

However, do not spend development effort implementing unsupported desktop/web functionality unless explicitly requested.

The primary application targets are:

```text
Android
iOS
```

---

# 31. Documentation

Keep architectural decisions documented.

Use:

```text
docs/
├── product/
├── architecture/
├── android/
├── ux/
└── decisions/
```

Important decisions should be recorded when they materially affect future implementation.

Examples:

```text
docs/architecture/status-scanning.md
docs/android/storage-access.md
docs/decisions/001-media-discovery-strategy.md
```

Do not create documentation for trivial code changes.

---

# 32. Research Rules

When implementation depends on current platform behavior, research the current official documentation.

Prioritize:

1. Flutter official documentation
2. Dart official documentation
3. Android Developers documentation
4. Apple developer documentation
5. Official package documentation
6. Source repositories when necessary

Do not rely on old blog posts for security-sensitive or platform-specific behavior when official documentation is available.

For Android storage, permissions, MediaStore, scoped storage, and Play policy, verify current Android documentation before implementation.

---

# 33. AI Agent Behavior

Agents must inspect before modifying.

Before making a significant change:

1. Inspect the relevant files
2. Understand existing architecture
3. Check related tests
4. Check `pubspec.yaml`
5. Check platform configuration when relevant
6. Search for existing implementations
7. Identify the smallest change required

Do not overwrite files blindly.

Do not recreate existing functionality.

Do not introduce duplicate services.

---

# 34. No Speculative Refactoring

Do not refactor unrelated code while implementing a feature.

If you discover unrelated technical debt:

* Do not silently fix it
* Mention it separately
* Fix it only if it blocks the current task or the user explicitly asks

Keep diffs focused.

---

# 35. No Fake Implementations

Do not create fake functionality merely to make the UI appear complete.

Do not use:

```text
hard-coded status data
fake media paths
fake download success
fake permission state
placeholder repositories
```

unless explicitly building a temporary prototype or test fixture.

Clearly label prototypes and mocks.

---

# 36. No Hard-Coded Production Assumptions

Avoid hard-coded assumptions about:

* Android storage paths
* WhatsApp package behavior
* File extensions
* Device manufacturers
* Android versions
* Permissions
* Media locations

Centralize platform-specific assumptions.

Make them replaceable.

---

# 37. Security and Privacy

This application handles user media.

Treat all media as private user data.

Never:

* Upload user media without explicit product requirements
* Log media contents
* Log sensitive file paths unnecessarily
* Include media bytes in analytics
* Expose private media through debug endpoints
* Store unnecessary copies
* Request unrelated permissions

Prefer on-device processing.

---

# 38. Product Scope Discipline

Do not add features merely because they seem useful.

Potential future features such as:

* Cloud backup
* Accounts
* Sharing platforms
* AI processing
* Analytics
* Social features
* Remote synchronization

must not be introduced unless explicitly approved.

Keep the core product focused.

---

# 39. Before Every Implementation Phase

The agent should be able to answer:

```text
What am I changing?
Why am I changing it?
Which layer owns this behavior?
Which files should change?
How will it be tested?
How will I verify the result?
```

If those questions cannot be answered, inspect the repository/specification further before coding.

---

# 40. Definition of Done

A task is not complete merely because code was written.

A task is complete when:

* The implementation matches the approved requirement
* Architecture boundaries remain intact
* No unnecessary dependencies were added
* Code is formatted
* Static analysis passes
* Relevant tests pass
* Relevant platform build passes
* No unrelated regressions were introduced
* Git diff was reviewed
* Documentation was updated when necessary

For Android-specific work, verify the actual Android behavior rather than relying only on Dart tests.

---

# 41. Final Rule

Prefer:

```text
Simple
Explicit
Testable
Maintainable
Platform-aware
```

over:

```text
Clever
Over-engineered
Highly abstract
Dependency-heavy
Platform-assuming
```

Build the smallest correct system first.

Then improve it with evidence.
