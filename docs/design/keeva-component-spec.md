# Keeva Component Inventory & Interface Specification

**Product:** Keeva (WhatsApp Status Saver → Premium Independent Identity)  
**Document Status:** Production Component Architecture Specification  
**Phase:** Phase 2E-A (UI/UX Design System Discovery & Specification)  
**Platform Target:** Android-First (Primary), iOS-Compatible (Secondary)  
**Date:** September 2026  

---

## 1. Component Architecture Overview

All Keeva presentation components adhere to the following architectural rules:
1. **Pure Presentation:** Components accept immutable values and callbacks. They never invoke repositories, method channels, or SQLite directly.
2. **Deterministic States:** Components specify distinct visual representations for every state (Idle, Hover/Focus, Pressed, Loading, Disabled, Success, Error).
3. **Accessibility Enforced:** Every interactive component guarantees minimum 48×48dp hit boundaries and WCAG 2.2 AA compliant contrast ratios.
4. **Zero Layout Thrash:** Components use fixed aspect ratios and constraints to prevent reflow during asynchronous image/video thumbnail loading.

---

## 2. Component Inventory (21 Components)

---

### 2.1 `AppShell`
* **Purpose:** The top-level responsive layout container managing screen navigation, safe-area insets, and adaptive navigation switching.
* **Variants:**
  * `Compact`: Phone layout with bottom navigation bar.
  * `Expanded`: Tablet/desktop layout with left-docked navigation rail.
* **States:** Standard, Keyboard Visible (bottom bar hides smoothly).
* **Dimensions:** Screen width × screen height.
* **Spacing:** Insets dictated by `MediaQuery.viewPaddingOf(context)`.
* **Accessibility:** Sets up primary navigation landmark for screen readers.

---

### 2.2 `TopBar`
* **Purpose:** Primary application header displaying brand title, contextual section metadata, and trust affordance.
* **Variants:**
  * `BrandHeader`: Displays "Keeva" wordmark + "Private" trust pill.
  * `ContextualHeader`: Displays back button + title + action buttons (for Viewer and Kept Vault).
  * `SelectionHeader`: Displays active selection count ("3 selected") + batch actions.
* **Dimensions:** 56dp height + top status bar inset.
* **Spacing:** 16dp horizontal screen margin.
* **Typography:** Plus Jakarta Sans SemiBold (20sp), `textPrimary` (`#F9FAFB`).
* **Interaction:** Tapping "Private" pill opens the Privacy Sheet. Back button triggers pop.
* **Accessibility:** Marked as semantic header; back button touch target 48×48dp.

---

### 2.3 `Navigation` (BottomNavigationBar & NavigationRail)
* **Purpose:** Core app destination routing between Moments, Kept Vault, and Settings.
* **Variants:**
  * `BottomNav`: Fixed 64dp bar with 3 items (`Moments`, `Kept`, `Settings`).
  * `AdaptiveNavRail`: 80dp compact or 220dp expanded left-docked rail.
* **States:** Active (Aurora Mint pill highlight + icon + bold label), Inactive (Muted Slate icon + regular label).
* **Dimensions:**
  * BottomNav: Width 100%, Height 64dp + bottom inset. Active indicator: 56dp width × 32dp height pill.
  * NavRail: Width 80dp or 220dp, Height 100%.
* **Spacing:** 8dp vertical item separation in rail.
* **Typography:** Plus Jakarta Sans Medium (12sp), active color `#10B981`, inactive `#9CA3AF`.
* **Interaction:** Tap switches active tab with 200ms ease-out pill morphing.
* **Accessibility:** `BottomNavigationBar` semantics with tab index announcements.

---

### 2.4 `PrimaryButton`
* **Purpose:** Primary call-to-action for high-intent flows (e.g. "Connect Media Folder", "Keep All").
* **Variants:** Solid Mint, Full Width Pill, Compact Pill.
* **States:** Idle, Pressed (scale 0.98), Loading (18dp circular spinner replaces text), Disabled (30% opacity).
* **Dimensions:** Height 48dp or 52dp, Min Width 120dp, Corner Radius 9999dp (pill) or 12dp.
* **Spacing:** 20dp horizontal internal padding.
* **Typography:** Plus Jakarta Sans SemiBold (14sp), `onPrimary` (`#042F2E`).
* **Interaction:** Taps trigger light haptic feedback.
* **Accessibility:** Contrast 8.4:1 vs dark canvas; TalkBack announces loading state.

---

### 2.5 `SecondaryButton`
* **Purpose:** Secondary/neutral actions (e.g. "Try Again", "Learn More", "Cancel").
* **Variants:** Outlined, Ghost/Text.
* **States:** Idle, Pressed (surface tint), Disabled.
* **Dimensions:** Height 44dp, Corner Radius 12dp.
* **Spacing:** 16dp horizontal internal padding.
* **Typography:** Plus Jakarta Sans Medium (14sp), `textPrimary` (`#F9FAFB`).
* **Accessibility:** 1.5px subtle border `rgba(255, 255, 255, 0.16)`.

---

### 2.6 `KeepButton` (Signature Component)
* **Purpose:** The signature Keeva micro-interaction button to save a status item to the gallery.
* **Variants:**
  * `CardOverlayPill`: Circular 32dp visual affordance embedded on the media card.
  * `ViewerActionPill`: Full 48dp height pill button with label "Keep" in media viewer.
* **States:**
  * `Idle`: Translucent dark glass container (`rgba(0,0,0,0.50)`), mint bookmark icon (`#10B981`).
  * `Pressed`: Scales to `0.94` over 80ms + `HapticFeedback.lightImpact()`.
  * `Saving`: Displays 16dp mint circular progress indicator.
  * `Success`: Morphs to solid mint checkmark (`#10B981`) with expanding aura wave.
  * `AlreadyKept`: Subdued container (`#064E3B`), muted mint checkmark (`#A7F3D0`).
  * `Failure`: Amber warning icon + `HapticFeedback.mediumImpact()`.
* **Dimensions:** Visual 32×32dp (card) or 48dp height (viewer). **Touch Target:** Guaranteed 48×48dp hit box via padding.
* **Accessibility:** Semantics: *"Keep this moment. Button."* When already kept: *"Already kept in vault. Button."*

---

### 2.7 `StatusCard`
* **Purpose:** The primary media thumbnail card in the Moments grid.
* **Variants:** Photo Card, Video Card (with duration badge).
* **States:** Default, Pressed (scale 0.98), Selected (accent ring), Saved (kept badge visible).
* **Dimensions:** Fixed aspect ratio `9:16` (width varies by responsive column calculation). Corner Radius: 12dp (`radiusMd`).
* **Spacing:** 8dp grid spacing between cards.
* **Overlays:**
  * Top-Left: `[✓ Kept]` badge if saved.
  * Top-Right: `[▶ 0:24]` video badge if video.
  * Bottom-Left: Relative time (`14m ago`).
  * Bottom-Right: `KeepButton` (48dp touch target).
  * Bottom Scrim: Linear gradient from transparent to `rgba(0,0,0,0.70)`.
* **Accessibility:** Reads: *"Video status, duration 24 seconds, 14 minutes ago. Double tap to preview."*

---

### 2.8 `StatusGrid`
* **Purpose:** The high-performance, edge-aware scrolling grid holding `StatusCard` elements.
* **Variants:** 2-column (phone), 3-column (tablet portrait), 4-column (tablet landscape).
* **States:** Loading (staggered skeleton), Populated, Empty, Error.
* **Dimensions:** Full viewport width.
* **Spacing:** 16dp horizontal margin on phone, 8dp card spacing, bottom padding `64dp + insets`.
* **Performance:** Implements `SliverGrid` with `cacheExtent: 500` for seamless 120fps fling scrolling. Zero off-screen image decoding.

---

### 2.9 `VideoBadge`
* **Purpose:** Indicates that a media item is a video and displays its exact runtime.
* **Variants:** Compact (card overlay), Full (media viewer player).
* **Dimensions:** Height 20dp, Corner Radius 4dp.
* **Spacing:** 6dp horizontal padding, 4dp gap between play icon and time string.
* **Colors:** Background `rgba(0, 0, 0, 0.65)`, Icon & Text `#F9FAFB`.
* **Typography:** 11sp tabular figures (`FontFeature.tabularFigures()`).

---

### 2.10 `DurationLabel`
* **Purpose:** Formats milliseconds into human-friendly time strings (`0:24`, `1:05`).
* **Typography:** Plus Jakarta Sans Medium (11sp), `FontFeature.tabularFigures()`.
* **Contrast:** 14:1 vs dark gradient scrim.

---

### 2.11 `FreshnessLabel`
* **Purpose:** Communicates the relative age of temporary statuses before expiration (`14m ago`, `2h ago`, `Yesterday`).
* **Typography:** Plus Jakarta Sans Regular (11sp), `textSecondary` (`#9CA3AF`).
* **Behavior:** Updates periodically; highlights in amber (`#F59E0B`) when < 2 hours remain.

---

### 2.12 `LoadingIndicator`
* **Purpose:** Communicates asynchronous loading without causing layout shifts.
* **Variants:**
  * `ShimmerCard`: 9:16 card placeholder with subtle gradient shimmer (`#161A22` to `#1E232E`).
  * `CircularSpinner`: 24dp or 40dp indeterminate spinner in Aurora Mint (`#10B981`).
  * `LinearProgressBar`: 2dp non-destructive top refresh line.
* **Motion:** 1.2s smooth sine shimmer cycle.

---

### 2.13 `EmptyState`
* **Purpose:** Provides engaging guidance when no items are available.
* **Variants:** 7 states (No Access, No Statuses, Filter Empty, Vault Empty, Folder Moved, Permission Revoked, Moment Expired).
* **Dimensions:** Centered in available viewport space.
* **Spacing:** 24dp vertical gap between graphic, headline, body, and CTA.
* **Typography:** Headline `titleLarge` (18sp SemiBold), Body `bodyMedium` (14sp textSecondary).

---

### 2.14 `ErrorState`
* **Purpose:** Calm, non-alarmist failure recovery.
* **Variants:** Inline Card Error, Full-Screen Recovery, Floating Toast.
* **Colors:** Surface Level 1 background, Amber/Red accent icon, `textPrimary` title.
* **Copy Rule:** Plain human English, never raw exceptions.

---

### 2.15 `PermissionGuide`
* **Purpose:** The 3-step structured visual guide explaining Android SAF folder access.
* **Components:** Container holding 3 `PermissionStep` cards + privacy guarantee badge.
* **Dimensions:** Full width with 16dp horizontal padding.

---

### 2.16 `PermissionStep`
* **Purpose:** An individual numbered instruction card within the permission guide.
* **Variants:** Standard, Highlighted (Step 3: "Use this folder").
* **Elements:** Numbered circle badge (24dp), Step title (14sp SemiBold), Explanatory text (12sp).
* **Colors:** Standard (`surfaceLevel1`), Highlighted (border `1px solid #10B981`).

---

### 2.17 `BottomSheet` (Modal Sheet)
* **Purpose:** Lightweight secondary surfaces (Privacy Sheet, Media Details, Folder Reconnect).
* **Dimensions:** Width 100% (max 600dp on tablets), Top Corner Radius 24dp (`radiusXl`).
* **Colors:** Background `surfaceLevel2` (`#1E232E`), Top border `1px solid rgba(255,255,255,0.12)`.
* **Scrim:** `rgba(0, 0, 0, 0.72)`.
* **Interaction:** Drag handle at top (32×4dp pill); drag-down to dismiss.

---

### 2.18 `Toast / Snackbar`
* **Purpose:** Transient confirmation of non-critical events ("Moment kept in Pictures/SavedStatus").
* **Dimensions:** Height 48dp, Corner Radius 12dp.
* **Spacing:** Anchored 16dp above bottom navigation bar.
* **Colors:** Background `surfaceLevel3` (`#282E3C`), Border `1px solid rgba(255,255,255,0.12)`, Text `textPrimary`.
* **Duration:** 2500ms auto-dismiss with fade-out.

---

### 2.19 `MediaPlaceholder`
* **Purpose:** Deterministic placeholder rendered while native thumbnail bytes are decoding or if a file is unreadable.
* **Visual:** Obsidian card (`#161A22`) with centered subtle photo/video outline icon (`#6B7280`).
* **Zero Layout Shift:** Always matches target `9:16` aspect ratio exactly.

---

### 2.20 `SectionHeader`
* **Purpose:** Groups moments by chronology ("Today", "Yesterday", "Earlier this week").
* **Dimensions:** Height 36dp.
* **Spacing:** 20dp top margin, 8dp bottom margin.
* **Typography:** Plus Jakarta Sans SemiBold (16sp), `textPrimary` (`#F9FAFB`).

---

### 2.21 `FilterControl`
* **Purpose:** Quick toggles to narrow media types.
* **Options:** "All (count)", "Photos (count)", "Videos (count)".
* **Variants:** Filter Chip Row with horizontal scroll.
* **Dimensions:** Chip height 32dp, Corner Radius 9999dp (pill).
* **Spacing:** 8dp horizontal separation.
* **Colors:**
  * Selected: Background `#1E232E`, Border `1px solid #10B981`, Text `#F9FAFB`.
  * Unselected: Background `#161A22`, Border `1px solid rgba(255,255,255,0.06)`, Text `#9CA3AF`.
