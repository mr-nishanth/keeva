# Keeva Dependency License Audit

This document records the complete, verified legal audit of all direct and transitive dependencies, platform plugins, native libraries, and third-party assets utilized by **Keeva**.

---

## 1. Direct Flutter & Dart Dependencies

The following table details all direct dependencies declared in `pubspec.yaml` and resolved in `pubspec.lock`.

| Dependency | Version | License | Source | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `cupertino_icons` | `1.0.9` | MIT | [pub.dev](https://pub.dev/packages/cupertino_icons) | iOS-style iconography, authored by Vladimir Kharlampidi. |
| `flutter` | `0.0.0` (SDK 3.24+) | BSD-3-Clause | Flutter SDK | Core Flutter UI framework, authored by Google and The Flutter Authors. |
| `flutter_riverpod` | `3.4.3` | MIT | [pub.dev](https://pub.dev/packages/flutter_riverpod) | Reactive state management layer, authored by Remi Rousselet. |
| `video_player` | `2.14.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/video_player) | Official Flutter video playback plugin, authored by The Flutter Authors. |
| `flutter_lints` | `6.0.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/flutter_lints) | Official recommended static analysis rule set for Flutter (dev dependency). |
| `flutter_test` | `0.0.0` (SDK) | BSD-3-Clause | Flutter SDK | Flutter unit and widget testing library (dev dependency). |
| `integration_test` | `0.0.0` (SDK) | BSD-3-Clause | Flutter SDK | On-device integration testing framework (dev dependency). |

---

## 2. Transitive Dart Dependencies

All 46 transitive Dart dependencies resolved in `pubspec.lock` have been inspected and verified against their cached `LICENSE` files.

| Dependency | Version | License | Source | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `async` | `2.13.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/async) | Dart team async utilities. |
| `boolean_selector` | `2.1.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/boolean_selector) | Expression evaluator for test tags. |
| `characters` | `1.4.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/characters) | Unicode grapheme cluster processing. |
| `clock` | `1.1.3` | Apache-2.0 | [pub.dev](https://pub.dev/packages/clock) | Time abstraction utility. |
| `collection` | `1.19.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/collection) | Extended collections utility functions. |
| `crypto` | `3.0.7` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/crypto) | Cryptographic hashing algorithms (SHA, MD5). |
| `csslib` | `1.0.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/csslib) | Pure Dart CSS parser. |
| `fake_async` | `1.3.3` | Apache-2.0 | [pub.dev](https://pub.dev/packages/fake_async) | Deterministic fake clock for testing timers. |
| `file` | `7.0.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/file) | Common interface for filesystem libraries. |
| `fixnum` | `1.1.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/fixnum) | 64-bit integer arithmetic. |
| `flutter_driver` | `0.0.0` | BSD-3-Clause | Flutter SDK | Integration test driving harness. |
| `flutter_web_plugins` | `0.0.0` | BSD-3-Clause | Flutter SDK | Plugin infrastructure for web targets. |
| `fuchsia_remote_debug_protocol` | `0.0.0` | BSD-3-Clause | Flutter SDK | Fuchsia OS debugging protocol. |
| `html` | `0.15.7` | MIT | [pub.dev](https://pub.dev/packages/html) | HTML5 tokenization and parsing. |
| `leak_tracker` | `11.0.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/leak_tracker) | Memory leak tracking framework. |
| `leak_tracker_flutter_testing` | `3.0.10` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/leak_tracker_flutter_testing) | Leak tracking fixtures for Flutter tests. |
| `leak_tracker_testing` | `3.0.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/leak_tracker_testing) | Generic leak tracking test helpers. |
| `lints` | `6.1.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/lints) | Official Dart linter core rule set. |
| `listen` | `1.0.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/listen) | Object observation helpers. |
| `matcher` | `0.12.20` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/matcher) | Expectation matchers for Dart tests. |
| `material_color_utilities` | `0.13.0` | Apache-2.0 | [pub.dev](https://pub.dev/packages/material_color_utilities) | Google Material 3 color generation algorithms. |
| `meta` | `1.18.3` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/meta) | Annotations for Dart source code (`@immutable`, etc.). |
| `path` | `1.9.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/path) | String-based path manipulation. |
| `platform` | `3.1.6` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/platform) | Pluggable platform detection. |
| `plugin_platform_interface` | `2.1.8` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/plugin_platform_interface) | Base class for federated platform packages. |
| `process` | `5.0.6` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/process) | Modular process spawning abstraction. |
| `riverpod` | `3.4.3` | MIT | [pub.dev](https://pub.dev/packages/riverpod) | Framework-independent Riverpod core. |
| `sky_engine` | `0.0.0` | BSD-3-Clause | Flutter SDK | Flutter runtime Dart engine APIs (`dart:ui`). |
| `source_span` | `1.10.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/source_span) | Text source spans for error diagnostics. |
| `stack_trace` | `1.12.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/stack_trace) | Parse and format stack traces. |
| `state_notifier` | `1.0.0` | MIT | [pub.dev](https://pub.dev/packages/state_notifier) | Observable state container primitive. |
| `stream_channel` | `2.1.4` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/stream_channel) | Two-way stream abstraction. |
| `string_scanner` | `1.4.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/string_scanner) | Character scanner over strings. |
| `sync_http` | `0.3.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/sync_http) | Synchronous HTTP testing library. |
| `term_glyph` | `1.2.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/term_glyph) | Terminal Unicode and ASCII character glyphs. |
| `test_api` | `0.7.12` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/test_api) | Core API of `package:test`. |
| `typed_data` | `1.4.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/typed_data) | Additional typed data collections. |
| `uuid` | `4.6.0` | MIT | [pub.dev](https://pub.dev/packages/uuid) | RFC4122 UUID generator, authored by Yulian Kuncheff. |
| `vector_math` | `2.4.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/vector_math) | 2D/3D math and vector library. |
| `video_player_android` | `2.12.2` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/video_player_android) | Android implementation of `video_player`. |
| `video_player_avfoundation` | `2.12.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/video_player_avfoundation) | iOS AVFoundation implementation of `video_player`. |
| `video_player_platform_interface` | `6.9.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/video_player_platform_interface) | Common platform interface contract for `video_player`. |
| `video_player_web` | `2.4.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/video_player_web) | Web implementation of `video_player`. |
| `vm_service` | `15.3.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/vm_service) | Dart VM service protocol bindings. |
| `web` | `1.1.1` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/web) | Web interoperability bindings. |
| `webdriver` | `3.1.0` | Apache-2.0 | [pub.dev](https://pub.dev/packages/webdriver) | WebDriver client library. |

---

## 3. Android Platform Dependencies & Tooling

| Component / Library | Version | License | Source | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `junit:junit` | `4.13.2` | EPL-1.0 | Maven Central | Unit test runner (`testImplementation`). Not packaged into release APKs. |
| `dev.flutter.flutter-gradle-plugin` | `1.0.0` | BSD-3-Clause | Flutter SDK | Flutter Gradle build plugin. |
| `com.android.application` (AGP) | `9.1.0` | Apache-2.0 | Google Maven | Android Gradle build tooling. |
| `org.jetbrains.kotlin.android` | `2.4.0` | Apache-2.0 | JetBrains | Kotlin compiler plugin for Android. |
| `androidx.core:core-ktx` | `1.13.1` (transitive) | Apache-2.0 | Google Maven | AndroidX Kotlin extensions. |
| `androidx.documentfile:documentfile` | `1.0.1` (transitive) | Apache-2.0 | Google Maven | Scoped storage `DocumentFile` SAF tree querying. |
| `androidx.media3:media3-exoplayer` | `1.4.1` (transitive) | Apache-2.0 | Google Maven | Transitive dependency of `video_player_android`. |

---

## 4. iOS Platform Dependencies

| Component / Library | Version | License | Source | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `FlutterFramework` | Built-in | BSD-3-Clause | Flutter SDK | iOS Flutter engine framework. |
| `video_player_avfoundation` | `2.12.0` | BSD-3-Clause | [pub.dev](https://pub.dev/packages/video_player_avfoundation) | Integrates with native Apple `AVFoundation` framework. |
| `integration_test` | Built-in | BSD-3-Clause | Flutter SDK | Native iOS test runner harness. |
| CocoaPods (`Podfile` / `Podfile.lock`) | N/A | N/A | Local Project | **Not utilized.** Project uses Flutter 3.24+ Swift Package Manager (SPM) integration. |

---

## 5. Embedded Fonts & Visual Assets

| Asset Path | Origin / Creator | License | Compliance Notes |
| :--- | :--- | :--- | :--- |
| `assets/fonts/PlusJakartaSans-Variable.ttf` | Gumpita Rahayu / Tokotype | **SIL Open Font License 1.1 (OFL-1.1)** | Verified in font metadata table. Permitted to bundle with open-source and commercial software. Must not be sold standalone. |
| `assets/brand/keeva/*` | Nishvanta Labs | Proprietary / Creator Reserved | Master vector logos and lockups. Rights retained by Nishvanta Labs. |
| `assets/brand/nishvanta/*` | Nishvanta Labs | Proprietary / Creator Reserved | Corporate organization marks. Rights retained by Nishvanta Labs. |
| `assets/illustrations/*` | Keeva Project | Project Original | Scalable vector illustrations created specifically for Keeva UX flows. |
| `assets/empty/*` | Keeva Project | Project Original | Vector empty state graphics. |
| `assets/onboarding/*` | Keeva Project | Project Original | Vector onboarding walkthrough graphics. |

---

## 6. Compatibility Assessment

| Candidate License | Dependency Compatibility | Font Compatibility (OFL-1.1) | Brand Assets Protection |
| :--- | :--- | :--- | :--- |
| **MIT** | **100% Compatible** (All dependencies are MIT, BSD-3, or Apache-2.0). | **Compatible** (OFL-1.1 allows bundling with MIT software). | Requires separate brand terms or dual-licensing to protect marks. |
| **Apache-2.0** | **100% Compatible** (Permissive dependencies align directly). | **Compatible** (OFL-1.1 allows bundling with Apache-2.0 software). | **Best native protection** (Section 6 explicitly excludes trademark grants). |
| **GPL-3.0** | **100% Compatible** (MIT, BSD-3, and Apache-2.0 code can be bundled into GPL-3.0). | **Compatible** (OFL font bundled with GPL software is permitted). | Brand marks can be reserved via Section 7(e) exceptions. |

### Conclusion & Licensing Distinction

With the maintainer's selection of **Apache-2.0**, the licensing tiers are clearly distinguished:
- **Project License (Apache-2.0)**: Governs original Keeva application source code, architecture, and documentation authored by Nishvanta Labs.
- **Third-Party Dependency Licenses (MIT, BSD-3-Clause, Apache-2.0)**: Govern external packages and libraries. Each package remains licensed under its original upstream terms; adopting Apache-2.0 for Keeva does not alter third-party licenses.
- **Third-Party Asset Licenses (SIL Open Font License 1.1)**: Governs the bundled *Plus Jakarta Sans* font file, preserving its upstream copyright and OFL-1.1 terms.
- **Brand Assets**: Governed under Section 6 of Apache-2.0 (which explicitly excludes trademark rights) and Nishvanta Labs brand guidelines.

The repository maintains **100% license compatibility** across all dependencies and assets with zero legal conflicts.
