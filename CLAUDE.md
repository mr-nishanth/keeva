# CLAUDE.md

## WhatsApp Status Saver

This file contains Claude Code-specific instructions for working on the WhatsApp Status Saver repository.

The project-wide engineering rules are defined in:

```text
AGENTS.md
```
@AGENTS.md

**`AGENTS.md` is the primary source of truth.**

Claude Code must read and follow `AGENTS.md` before making meaningful changes.

Do not duplicate or contradict the architecture rules defined there.

---

# 1. Project Context

This is a Flutter application targeting:

```text
Primary: Android
Secondary: iOS
```

The project uses:

```text
Flutter
Dart
Kotlin
```

The application is a WhatsApp Status Saver focused on discovering, previewing, saving, and organizing WhatsApp Status media.

Android media/storage integration is the highest-risk technical area.

---

# 2. Repository Root

The repository root is:

```text
<project-root>
```

Always treat the current working directory containing this file as the project root.

Do not modify the Flutter SDK directory.

---

# 3. Read Before Coding

Before implementing a non-trivial task, inspect:

```text
AGENTS.md
CLAUDE.md
README.md
pubspec.yaml
lib/
android/
test/
```

Also inspect relevant files under:

```text
docs/
```

when they exist.

For a feature-specific task, first locate the existing implementation and tests before creating new files.

---

# 4. Do Not Start Coding Immediately

For meaningful tasks, first establish:

```text
Requirement
    ↓
Existing implementation
    ↓
Architecture boundary
    ↓
Files to change
    ↓
Implementation
    ↓
Verification
```

Do not immediately start editing because the task sounds straightforward.

Inspect first.

---

# 5. Plan Before Significant Changes

For changes involving multiple files, create a concise implementation plan before editing.

The plan should identify:

```text
1. Existing behavior
2. Desired behavior
3. Files/components involved
4. Architectural boundary
5. Testing strategy
6. Verification commands
```

Keep the plan proportional to the task.

Do not produce excessive planning for a one-line change.

---

# 6. User Approval

If the user explicitly asks for implementation, proceed.

If the user asks for:

```text
analysis
review
investigation
architecture
research
plan
specification
```

do not start implementation unless the user also asks for implementation.

If the specification contains unresolved product or architectural decisions that materially affect implementation, stop before making irreversible choices and ask for clarification.

Do not invent product requirements.

---

# 7. Existing Code First

Before creating a new class, search for:

```text
Existing class
Existing interface
Existing provider
Existing repository
Existing service
Existing utility
Existing model
Existing test
```

Prefer extending existing architecture over introducing a duplicate abstraction.

---

# 8. File Creation Rules

Create files only when they have a clear responsibility.

Good:

```text
status_repository.dart
status_item.dart
status_view_model.dart
status_screen.dart
android_status_scanner.kt
```

Bad:

```text
common_helper.dart
misc.dart
stuff.dart
manager.dart
helper2.dart
```

Avoid vague names.

---

# 9. Flutter Architecture

Follow the architecture defined by `AGENTS.md`.

In particular:

```text
View
 ↓
ViewModel / Controller
 ↓
Repository
 ↓
Service
 ↓
Platform / Storage
```

Do not let UI widgets directly access:

```text
SQLite
MediaStore
filesystem
MethodChannel
native Android classes
```

unless the architecture explicitly requires it.

---

# 10. Android Work

When working on Android-specific functionality, inspect:

```text
android/app/
android/app/src/main/
android/app/src/main/kotlin/
android/app/src/main/AndroidManifest.xml
android/app/build.gradle.kts
```

before modifying native code.

Understand the existing Flutter-to-Android boundary before introducing a new channel or native service.

---

# 11. Native Android Integration

For Android-specific functionality, prefer:

```text
Dart abstraction
    ↓
Repository / service
    ↓
Platform interface
    ↓
Kotlin implementation
    ↓
Android API
```

Keep Android implementation details out of presentation code.

Do not scatter:

```text
MethodChannel
EventChannel
Android paths
MediaStore queries
permission checks
```

through unrelated Dart widgets.

---

# 12. WhatsApp Media Discovery

Treat WhatsApp Status discovery as a platform capability.

Do not assume that a fixed filesystem path is universally valid.

Before implementing discovery logic:

1. Verify current Android behavior
2. Verify available permissions
3. Verify MediaStore/storage APIs
4. Verify the actual emulator/device
5. Test the smallest native proof of concept
6. Only then integrate it into the production repository

If the platform behavior is uncertain, research first.

---

# 13. Web Research

When current platform behavior matters, use current official documentation.

Prefer:

```text
Flutter official documentation
Android Developers
Apple Developer
Dart documentation
Official package documentation
Official GitHub repositories
```

For Android behavior, do not rely on stale tutorials when current official documentation is available.

When using web research to make an architectural decision, record the important decision in:

```text
docs/decisions/
```

when the decision has long-term impact.

---

# 14. Package Installation

Do not install packages speculatively.

Before running:

```bash
flutter pub add ...
```

determine:

```text
Why is this package required?
What responsibility does it provide?
Does Flutter already provide this?
Does the package support the required platforms?
Does it introduce native dependencies?
Is it actively maintained?
```

After adding a package:

```bash
flutter pub get
flutter analyze
flutter test
```

and verify the relevant platform.

---

# 15. Commands

Use the following baseline verification commands.

### Dependencies

```bash
flutter pub get
```

### Formatting

```bash
dart format .
```

### Analysis

```bash
flutter analyze
```

### Unit/widget tests

```bash
flutter test
```

### Devices

```bash
flutter devices
```

### Android debug build

```bash
flutter build apk --debug
```

### Android release build

```bash
flutter build apk --release
```

Do not run expensive commands unnecessarily.

Use the smallest verification command that gives meaningful confidence, then run the complete baseline before declaring a significant task complete.

---

# 16. Test-First Thinking

When implementing non-trivial logic, identify the test before or alongside the implementation.

For example:

```text
StatusScanner
    ↓
StatusRepository
    ↓
ViewModel
```

should have tests at the appropriate boundaries.

Do not test implementation details unnecessarily.

Prefer testing observable behavior.

---

# 17. Debugging Workflow

When something fails:

1. Reproduce the failure
2. Capture the actual error
3. Identify the failing layer
4. Inspect the relevant implementation
5. Form a hypothesis
6. Make the smallest fix
7. Re-run the failing verification
8. Run broader regression checks

Do not randomly change multiple files until the error disappears.

---

# 18. Error Messages

Do not hide failures.

Never use broad exception swallowing such as:

```dart
try {
  ...
} catch (_) {}
```

unless there is a documented reason.

If an error is intentionally ignored, explain why in code.

---

# 19. Diff Discipline

Before finishing a task:

```bash
git status
git diff --stat
git diff
```

Review:

* Unexpected files
* Debug code
* Temporary files
* Unused imports
* Accidental generated files
* Secrets
* Unrelated changes
* Incorrect formatting

Do not leave experimental changes mixed into production work.

---

# 20. Git Commits

Create a commit only when the user expects the workflow to include commits or when the task explicitly asks for one.

Use conventional, descriptive messages.

Examples:

```text
feat: add status repository contract
feat: implement Android status scanner
fix: handle denied media permission
test: add status repository tests
refactor: isolate native media access
```

Never use vague commit messages.

---

# 21. Do Not Modify Unrelated Files

If the task is:

```text
Add status repository
```

do not simultaneously:

```text
redesign settings
rewrite theme
upgrade all dependencies
refactor navigation
rename unrelated files
```

unless required by the implementation.

Keep the change focused.

---

# 22. Do Not Over-Engineer

Avoid introducing:

```text
interfaces everywhere
factories everywhere
use-cases everywhere
generic managers
generic helpers
generic base classes
```

unless the actual requirements justify them.

Flutter's architecture guidance supports use-cases when application logic is sufficiently complex, but they are not automatically required for every feature.

Use the simplest architecture that maintains the required boundaries.

---

# 23. UI Implementation

When implementing UI:

* Follow the existing design system
* Reuse existing components
* Reuse existing spacing/type/color tokens
* Avoid arbitrary styling duplication
* Handle loading/empty/error states
* Consider accessibility
* Keep widgets focused

Do not replace the entire UI architecture just to implement one screen.

---

# 24. Media UI

Media-heavy interfaces should be designed around:

```text
Thumbnail
    ↓
Lazy loading
    ↓
Preview
    ↓
Full-resolution media only when required
```

Avoid loading large media files unnecessarily.

Be careful with:

* Image memory
* Video initialization
* Thumbnail generation
* Grid scrolling
* Hero animations
* Full-screen viewers

Measure performance rather than guessing.

---

# 25. Security

Never place secrets in source code.

Never log:

```text
tokens
passwords
private keys
media contents
sensitive user information
```

Do not add analytics or remote uploads unless explicitly approved.

---

# 26. Generated Code

Do not manually edit generated code unless the task specifically requires it.

If a generated file is wrong:

```text
Find the generator/configuration/source
        ↓
Fix source
        ↓
Regenerate
```

Do not patch generated output as the permanent solution.

---

# 27. Documentation

Update documentation when implementation changes an important architectural decision.

Useful locations:

```text
docs/architecture/
docs/android/
docs/decisions/
```

Do not create documentation for every trivial implementation detail.

---

# 28. Completion Report

After completing a significant task, report:

```text
Implemented
- ...

Changed
- ...

Verification
- flutter analyze ✓
- flutter test ✓
- flutter build apk --debug ✓

Notes
- ...
```

If a verification command was not run, say so.

Never claim success based on expectation.

---

# 29. When Blocked

If blocked by:

* Missing requirement
* Unknown platform behavior
* Missing dependency
* Permission issue
* Build configuration
* External service
* Ambiguous product decision

do not invent an answer.

Explain:

```text
What is blocked
Why it is blocked
What has been verified
What decision/information is needed
```

If possible, propose the smallest experiment that can resolve the uncertainty.

---

# 30. Final Claude Rule

Before changing code, ask internally:

```text
Is this the correct layer?
Is this already implemented?
Is this required?
Can this be simpler?
How will I test it?
How will I verify it?
```

Then implement the smallest correct change.

Follow `AGENTS.md` as the project-wide authority.
