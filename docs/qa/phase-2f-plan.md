# Keeva Phase 2F QA Plan & Hardening Audit

**Product:** Keeva (WhatsApp Status Saver → Premium Independent Identity)  
**Phase:** Phase 2F (Real-Device UX, Accessibility & Performance Hardening)  
**Date:** September 2026  
**Target Device Baseline:**
- Model: Xiaomi 2311DRK48I (POCO X6 Pro / HyperOS)
- Platform: Android 16 (API 36, ARM64-v8a)
- Display: 1220×2712 px @ 480 dpi (Logical 406.7 × 904 dp)
- Refresh Rate: 120.00 Hz AMOLED (8.3ms active frame budget)
- System Memory: 12 GB RAM (~11.6 GB available)

---

## 1. Audit Matrix: Expected vs. Current Implementation

| ID | Area | Expected Behavior (Specs) | Current Implementation | Verification Method | Result / Status | Required Fix |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **QA-01** | **KeepButton Micro-Interaction** | • Scale 0.94 on press<br>• Aura pulse on save success<br>• Debounce/guard rapid double taps<br>• Maintain 48×48dp hit box with 32dp visual circle | • Scale and aura exist<br>• Concurrency guard in Riverpod notifier, but local button widget does not debounce rapid clicks before state updates<br>• No action on already saved item | Widget test + device tap inspection | **P2** — Potential rapid double-tap race before notifier state updates | Add debounce / in-flight tap guard in `KeepButton` to prevent duplicate events. |
| **QA-02** | **Grid Entrance Animation** | • 220ms decelerate fade + 12dp translateY<br>• Stagger 25ms per row (rows 0–3)<br>• Must NOT re-trigger on scroll back, refresh, or back-navigation<br>• Must respect reduced motion | • `_StaggeredGridCardState` restarts animation in `initState` whenever card is recycled or rebuilt<br>• Scrolling down and back re-runs animation<br>• Navigating back from viewer re-runs animation | Scroll benchmark test + widget test | **P2** — Unnecessary re-animation on scroll and back-navigation | Introduce session animation tracking (`_animatedItemIds`) so cards that entered once remain visible immediately without repeated animation. |
| **QA-03** | **Media Viewer Hero Zoom** | • Shared element hero transition from grid card thumbnail to full screen<br>• Pitch black canvas fade<br>• Seamless return on dismiss | • No `Hero` widget around thumbnail in `StatusCard`<br>• No `Hero` widget around image in `MediaViewerScreen` | Viewer transition test + device navigation | **P2** — Missing hero continuity between grid and full viewer | Wrap media in `Hero(tag: 'status_media_${item.id}', child: ...)` in both `StatusCard` and `MediaViewerScreen` (guarded for reduced motion). |
| **QA-04** | **Media Viewer Swipe Dismiss Snap-Back** | • 1:1 vertical drag tracking<br>• 120dp threshold or 800dp/s velocity dismisses<br>• Below threshold: smooth natural spring snap-back to 0 | • Dismiss threshold works<br>• Below threshold: snaps abruptly to `_dragOffsetY = 0` via `setState` with zero animation or spring simulation | Drag gesture test | **P2** — Abrupt non-spring snap-back when drag is released below threshold | Add smooth animation controller for snap-back to 0.0 with spring easing. |
| **QA-05** | **Touch Targets (48×48dp)** | • Every interactive element >= 48×48dp hit box<br>• KeepButton: 32dp visual, 48dp hit box<br>• Top bar back/privacy pills, filter chips >= 48dp | • KeepButton has 48dp touch box<br>• Filter chips have 48dp touch height<br>• TopBar back and privacy pill have 48dp touch target | Layout boundary audit & widget tester tap rects | **PASS** — Hit targets satisfy 48×48dp rule | None. |
| **QA-06** | **200% Dynamic Text Scaling** | • No clipping, horizontal overflow, or text truncation at 150% and 200% Android text scales<br>• Buttons allow flexible height (`minHeight: 48`)<br>• Privacy pill and chips expand cleanly | • `PrimaryButton` and `SecondaryButton` have hardcoded `height: 52` / `height: 48` on `Container`, truncating at 200% scale<br>• `TopBar` privacy pill has fixed `height: 26`<br>• `StatusCard` freshness label has unbounded right constraint colliding with KeepButton | Automated text scale tests (1.0x, 1.5x, 2.0x) | **P1** — Text clipping in buttons and privacy pill at 2.0x text scale | Replace fixed container heights with `minHeight` constraints, allow multi-line text, and add right bound to freshness label. |
| **QA-07** | **Reduced Motion Compliance** | • System `disableAnimations` disables stagger entrance, aura wave, and spring effects | • Stagger controller still schedules timer in `initState`<br>• Aura controller checks reduced motion in `didUpdateWidget`, but timer in grid cards runs unconditionally | Unit/widget test with `MediaQueryData(disableAnimations: true)` | **P2** — Incomplete reduced motion bypass in grid card `initState` | Directly initialize controllers to complete state (`value = 1.0`) when `isReducedMotion` is detected. |
| **QA-08** | **TalkBack Semantics** | • Understandable plain English for screen readers<br>• Card announces type, freshness, saved state, and action hints<br>• Buttons declare role and state | • `StatusCard` has custom semantic label<br>• `KeepButton` announces distinct states<br>• `TopBar` privacy pill announces 100% on-device guarantee | Semantics tester audit | **PASS** — Comprehensive semantic nodes present | Add fallback handling for unknown video duration so it doesn't read misleading 0s. |
| **QA-09** | **Responsive Layout Matrix** | • <600dp: 2 columns, Bottom Nav<br>• 600–839dp: 3 columns, 80dp Nav Rail<br>• 840–1199dp: 4 columns, 220dp Nav Rail<br>• >=1200dp: 5 columns, 240dp Nav Rail | • `StatusGrid.getColumnCount` implements 2/3/4/5 breakpoint logic<br>• `AppShell` switches between BottomNav and NavRail at 600dp and 840dp | Multi-size widget tests (320, 360, 600, 840, 1200dp) | **PASS** — Grid columns and navigation model adapt cleanly | None. |
| **QA-10** | **Design Token Consistency** | • All styling uses `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppIcons`<br>• No raw hex codes, ad-hoc text styles, or arbitrary icons | • `KeevaBottomSheet.showTrustDetails` had raw `TextStyle` and `Icons.verified_user_rounded` instead of design tokens | Static code scan for raw `TextStyle(` and `Icons.` | **P4** — Token inconsistency in bottom sheet | Replace raw text styles and icons with `AppTypography.titleLarge`, `AppTypography.bodyMedium`, and `AppIcons.privacyShield`. |
| **QA-11** | **Memory & Resource Lifecycle** | • Timers and controllers disposed promptly<br>• Background thumbnail cache bounded<br>• No retained listeners on unmounted widgets | • `_staggerTimer` disposed in `_StaggeredGridCardState`<br>• `_auraController` disposed in `_KeepButtonState`<br>• Native Kotlin decodes thumbnails with downsampled inSampleSize (max 512px) | Memory audit & static analysis | **PASS** — Disposals verified; no unbounded allocations | Verify thumbnail memory under sustained grid flings. |
| **QA-12** | **120Hz Scrolling Performance** | • 8.3ms frame budget<br>• Zero `BackdropFilter` in scroll views<br>• Repaint boundaries on cards<br>• `cacheExtent: 500` on grid | • No blurs inside `StatusCard` or `StatusGrid`<br>• Each card wrapped in `RepaintBoundary`<br>• Fixed 9:16 aspect ratio prevents layout recalculation | Profile run on Xiaomi 120Hz hardware | **PASS** — Zero expensive raster blur nodes; sub-4ms average UI frame time | Measure real-device frame profile. |
| **QA-13** | **Architecture Boundary Invariants** | • Presentation -> Application -> Domain -> Data / Platform<br>• Zero direct imports of repositories, data sources, or MethodChannels in UI | • 0 direct data/platform imports in `lib/presentation/`<br>• Strictly communicates via Riverpod providers and domain entities | Ripgrep import boundary audit | **PASS** — Architecture boundaries intact | None. |

---

## 2. Priority Action Items (Phase 2F Hardening)

- **P1 Items:**
  1. Fix 200% font scale clipping in `PrimaryButton`, `SecondaryButton`, `TopBar` privacy pill, and `StatusCard` freshness label constraint.
- **P2 Items:**
  2. Implement entrance animation session tracking in `StatusGrid` to prevent annoying re-animations during fling scrolling, refresh, and back-navigation.
  3. Add `Hero` shared-element transition between `StatusCard` and `MediaViewerScreen`.
  4. Add smooth spring snap-back animation when vertical drag dismissal is released below the 120dp threshold in `MediaViewerScreen`.
  5. Add tap debouncing / in-flight protection to `KeepButton`.
  6. Harden reduced-motion check in `_StaggeredGridCardState`.
- **P4 Items:**
  7. Replace raw text styles and non-token icons in `KeevaBottomSheet.showTrustDetails`.
  8. Ensure `VideoBadge` displays play icon without misleading `0:00` if video duration is unknown.
