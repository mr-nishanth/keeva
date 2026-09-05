# Keeva UI/UX Screen & Wireframe Specification

**Product:** Keeva (WhatsApp Status Saver → New Product Identity)  
**Document Status:** Approved UI/UX Specification  
**Design Phase:** Phase 2E-A (Product Brand & UI/UX Design System)  
**Authors:** Senior Mobile UX Architect & Visual Interaction Designer  
**Date:** September 2026  

---

## 1. Information Architecture & Navigation Model

Keeva is structured around three primary destinations, accessible via a bottom navigation bar on mobile and an adaptive navigation rail on tablets and landscape orientations:

```
                              ┌─────────────────────────┐
                              │       APP LAUNCH        │
                              └────────────┬────────────┘
                                           │
                                    Has Access?
                                  ┌────────┴────────┐
                                 YES                NO
                                  │                 │
                                  │        ┌────────▼────────┐
                                  │        │ 3-STEP ONBOARD  │
                                  │        │ (SAF Auth Flow) │
                                  │        └────────┬────────┘
                                  │                 │
                                  └────────┬────────┘
                                           │
                        ┌──────────────────┴──────────────────┐
                        │                                     │
           ┌────────────▼────────────┐           ┌────────────▼────────────┐
           │     PHONE LAYOUT        │           │     TABLET LAYOUT       │
           │  (Bottom Navigation)    │           │   (Navigation Rail)     │
           └────────────┬────────────┘           └────────────┬────────────┘
                        │                                     │
         ┌──────────────┼──────────────┐       ┌──────────────┼──────────────┐
         ▼              ▼              ▼       ▼              ▼              ▼
     [MOMENTS]       [KEPT]       [SETTINGS] [MOMENTS]     [KEPT]       [SETTINGS]
   (Live Inbox)   (Saved Vault)   (Prefs/SAF)
```

---

## 2. Comprehensive Screen & Wireframe Specifications (17 Screens)

---

### Screen 01: Splash Screen

```
┌─────────────────────────────────────────┐
│ [Status Bar: 12:00  •  5G  •  100%]     │
│                                         │
│                                         │
│                                         │
│                                         │
│                   ╭──╮                  │
│                  │  ● │                 │  <-- Keeva Logo Mark (64×64dp)
│                   ╰──╯                  │      Subtle aurora mint shimmer
│                                         │
│                  KEEVA                  │  <-- Plus Jakarta Sans (18sp, Tracking +2)
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│            Private by design            │  <-- 12sp textTertiary
│                                         │
└─────────────────────────────────────────┘
```

- **Visual Hierarchy:** Centered logo mark with subtle radiant glow. Brand wordmark placed 16dp below. Tagline "Private by design" anchored 32dp above navigation bar.
- **Components:** `KeevaLogoMark`, `BrandWordmark`, `Text` tagline.
- **Colors:** Canvas `background` (`#090B0E`), Mark `primary` (`#10B981`) + `accent` (`#6366F1`) subtle gradient, text `textSecondary` (`#9CA3AF`).
- **Interaction & Logic:** Native Android 12+ Splash API transitions seamlessly into Flutter. StateNotifier checks persisted SAF access via native `checkFolderAccess`. If granted, navigates to Moments Home (0200ms); if absent, navigates to Onboarding Screen 02.
- **Animation:** Central spark fades in with a gentle spring scale (`0.8` to `1.0` over 350ms).
- **Accessibility:** `Semantics(label: "Keeva, private moment keeper, loading")`.

---

### Screen 02: First Launch / Welcome Screen (Onboarding 1/3)

```
┌─────────────────────────────────────────┐
│                                   [Skip]│
│                                         │
│        ╭───────────────────────╮        │
│        │  [ILLUSTRATION:       │        │  <-- assets/onboarding/welcome.svg
│        │   Floating Moment     │        │      Clean geometric aperture
│        │   Cards in Soft Sky]  │        │      framing memories
│        ╰───────────────────────╯        │
│                                         │
│   Keep the moments                      │  <-- Display Medium (28sp SemiBold)
│   that matter.                          │
│                                         │
│   Statuses disappear in 24 hours.       │  <-- Body Large (15sp, textSecondary)
│   Keeva lets you quietly save photos    │
│   and videos before they vanish.        │
│                                         │
│   ● ○ ○                                 │  <-- Pagination Dots (8dp mint pill)
│                                         │
│   ┌─────────────────────────────────┐   │
│   │            Continue             │   │  <-- Primary CTA Button (48dp height)
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Visual Hierarchy:** Top-right subtle "Skip" action (routes straight to folder connection). Hero vector illustration occupying 40% height. Main headline, explanatory paragraph, pagination dots, sticky bottom CTA button.
- **Spacing:** Horizontal padding 24dp, title top margin 24dp, body margin 12dp, button bottom inset 24dp + safe area.
- **Typography:** Headline `displayMedium` (28sp, `#F9FAFB`), body `bodyLarge` (15sp, `#9CA3AF`), button `labelLarge` (14sp, SemiBold).
- **Colors:** Illustration in obsidian/mint/indigo palette. Button `primary` (`#10B981`), onPrimary text (`#042F2E`).
- **Interaction:** Swiping left or tapping "Continue" advances to Screen 03 (Privacy).
- **Accessibility:** Header marked as `header` semantic node. Button minimum hit target 48dp.

---

### Screen 03: Privacy Assurance Screen (Onboarding 2/3)

```
┌─────────────────────────────────────────┐
│ [←]                                     │
│                                         │
│        ╭───────────────────────╮        │
│        │  [ILLUSTRATION:       │        │  <-- assets/onboarding/privacy.svg
│        │   Device Hardware     │        │      Shield boundary enclosing
│        │   Enclave Shield]     │        │      media, zero external wires
│        ╰───────────────────────╯        │
│                                         │
│   Private by design.                    │  <-- Headline Large (24sp SemiBold)
│                                         │
│   ✓ No account required                 │  <-- Feature Checklist
│   ✓ Zero network connections            │      14sp Body Medium
│   ✓ No access to chats or contacts      │      8dp icon spacing
│   ✓ Media never leaves your phone       │
│                                         │
│   ○ ● ○                                 │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │            Continue             │   │  <-- Primary CTA
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Visual Hierarchy:** Back arrow top left. Centered hardware privacy shield illustration. Clear 4-point bullet checklist with mint checkmarks.
- **Tone:** Reassuring, uncompromising, direct.
- **Components:** `PrivacyFeatureRow(icon, text)` with 16dp vertical spacing between items.
- **Colors:** Checkmark icons `primary` (`#10B981`), checklist text `textPrimary` (`#F9FAFB`).
- **Accessibility:** Screen reader reads each guarantee sequentially with positive confirmation semantics.

---

### Screen 04: Connect WhatsApp Media (Onboarding 3/3)

```
┌─────────────────────────────────────────┐
│ [←]                                     │
│                                         │
│   Connect your media folder             │  <-- Headline Large (24sp)
│   Follow these 3 simple steps:          │  <-- Body Medium (14sp)
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ [1]  Open WhatsApp              │   │  <-- Step 1 Card (Surface Level 1)
│   │      View the statuses you want │   │
│   ├─────────────────────────────────┤   │
│   │ [2]  Tap Connect below          │   │  <-- Step 2 Card
│   │      Android will open files    │   │
│   ├─────────────────────────────────┤   │
│   │ [3]  Tap "Use this folder"      │   │  <-- Step 3 Card (Highlighted)
│   │      Folder: Android/media/...  │   │      Shows neutral folder badge
│   └─────────────────────────────────┘   │
│                                         │
│   ○ ○ ●                                 │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │      Connect Media Folder       │   │  <-- Triggers native SAF Picker
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Visual Hierarchy:** Step-by-step guidance cards breaking down the Android platform requirement clearly. Highlighted third step showing the exact system button name ("Use this folder").
- **Crucial Rule:** Zero WhatsApp logos or copied UI screenshots. Uses clean, neutral system folder illustrations (`assets/onboarding/connect_folder.svg`).
- **Interaction:** Tapping "Connect Media Folder" calls `requestFolderAccess` method channel, launching Android's `DocumentsUI` with the initial URI pre-configured to `Android/media/com.whatsapp/WhatsApp/Media`.
- **Accessibility:** Clear explanatory instructions for users navigating with TalkBack.

---

### Screen 05: Android SAF Picker Transition & Return

```
┌─────────────────────────────────────────┐
│  [Android System DocumentsUI Appears]   │
│  Files > Android > media > WhatsApp     │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ [✓ USE THIS FOLDER]               │  │  <-- Android OS System Button
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                    │
           User Grants Access
                    │
┌───────────────────▼─────────────────────┐
│ [KEEVA RE-ENTERS FOREGROUND]            │
│                                         │
│                 ╭───╮                   │
│                │  ✓  │                  │  <-- Animated Mint Pulse
│                 ╰───╯                   │
│          Connected safely               │  <-- Title Large (18sp)
│          Discovering moments...         │  <-- Body Medium (14sp)
│                                         │
└─────────────────────────────────────────┘
```

- **State Machine Transition:**
  - When the native picker returns `granted: true`, the native layer captures the persisted URI grant (`takePersistableUriPermission`).
  - App displays a 600ms transitional confirmation dialog with an animated checkmark before transitioning to Moments Home.
  - If user cancels or dismisses without granting, the screen returns to Screen 04 with a gentle helper toast: *"Folder access is needed to discover statuses. Tap Connect whenever you're ready."*

---

### Screen 06: Moments Home (Primary Inbox Screen)

```
┌─────────────────────────────────────────┐
│  KEEVA                       [🔒 Private]│  <-- Top Bar (Brand + Trust Pill)
│                                         │
│  Today                                  │  <-- Display Medium (28sp SemiBold)
│  18 moments available                   │  <-- Body Small (12sp textSecondary)
│                                         │
│  [ All (18) ] [ Photos (12) ] [ Videos (6) ] <-- Compact Filter Chips
│                                         │
│  ┌───────────────┐ ┌───────────────┐    │
│  │               │ │               │    │
│  │               │ │  [▶ 0:15]     │    │  <-- 9:16 Media Card
│  │               │ │               │    │      Thumbnail loaded via Kotlin
│  │               │ │  [Kept ✓]     │    │      Background Decoder
│  │   14m ago     │ │   1h ago      │    │
│  └───────────────┘ └───────────────┘    │
│  ┌───────────────┐ ┌───────────────┐    │
│  │               │ │               │    │
│  │               │ │               │    │
│  └───────────────┘ └───────────────┘    │
│                                         │
│  [  Moments  ]   [    Kept   ]   [ Settings ] <-- Bottom Navigation Bar
└─────────────────────────────────────────┘
```

- **Visual Hierarchy:**
  1. Top Bar: Wordmark left, "Private" trust pill right.
  2. Header: "Today" in prominent display type with moment count below.
  3. Filter Bar: Horizontally scrollable pill chips (All, Photos, Videos).
  4. Grid: 2-column (or 3-column on wide phones) media-first masonry/staggered grid.
  5. Bottom Navigation: 3 tabs with active pill indicator.
- **Card Metadata:** No raw filenames (`status_2026_09...jpg` is hidden). Shows only relative freshness ("14m ago", "Today") and duration if video.
- **Interaction:**
  - Single tap on card opens Media Viewer (Screen 10 or 11).
  - Long press on card enters Selection Mode (Screen 09).
  - Pull-to-refresh triggers native `scanStatuses` with haptic tick.

---

### Screen 07: Smart Inbox Filters & Sub-Categories

```
┌─────────────────────────────────────────┐
│  [ All (18) ] [ Photos ] [ Videos ] [ Expiring ] [ New (5) ]
│                                         │
│  • All: Entire discovered stream (default)
│  • Photos: Filters MIME image/*         │
│  • Videos: Filters MIME video/* (shows duration overlays)
│  • Expiring: Moments older than 20 hours (urgency amber dot)
│  • New: Discovered since last app open (mint badge)
└─────────────────────────────────────────┘
```

- **Visual Specifications:** Filter chips use `radiusPill` (9999dp). Height 32dp.
  - Active chip: Background `primaryContainer` (`#064E3B`), text `onPrimaryContainer` (`#A7F3D0`), border `1px solid rgba(16,185,129,0.3)`.
  - Inactive chip: Background `surfaceLevel1` (`#161A22`), text `textSecondary` (`#9CA3AF`), border `1px solid rgba(255,255,255,0.06)`.
- **Animation:** Filter transitions cross-fade the grid with a 150ms subtle scale.

---

### Screen 08: Moments Grid & Status Card Specification

```
         STATUS MEDIA CARD ANATOMY
         
┌───────────────────────────────────────┐
│ [○] Selection Circle (Top Left)       │  <-- Appears on Long-press / Select
│                                       │
│                                       │
│          HIGH-RESOLUTION              │
│        DOWNSAMPLED THUMBNAIL          │  <-- Decoded in background Kotlin
│                                       │      via BitmapFactory (sub-50ms)
│                                       │
│                                       │
│                         [Kept ✓]      │  <-- Top-right if already saved
│ [▶ 0:24]                              │  <-- Bottom-left if video (4dp radius)
│  2h ago               [ ⬇ Keep ]      │  <-- Bottom-right Quick-Keep action
└───────────────────────────────────────┘
```

- **Geometry:** Aspect ratio `9:16` (portrait) or `3:4`. Rounded corners `radiusMd` (12dp).
- **Elevation:** `borderSubtle` (`rgba(255, 255, 255, 0.06)`).
- **Overlays:**
  - *Bottom Scrim:* Linear gradient from black (`0.85` alpha) to transparent (`0.0` alpha) over the bottom 35% of the card.
  - *Freshness Label:* 11sp tabular numerals in off-white (`#F9FAFB`) at bottom left.
  - *Quick-Keep Icon:* 32×32dp circular glass button at bottom right. Tapping immediately triggers single-item keep without opening full viewer.
  - *Quick-Keep Accessibility Contract:* Visual affordance is 32dp. Interactive hit area is 48dp minimum (`48×48dp` hit test envelope). Do not enlarge the visual icon merely to satisfy the hit target requirement; maintain the 32dp visual footprint with a 48dp interactive padding envelope.


---

### Screen 09: Multi-Selection Mode

```
┌─────────────────────────────────────────┐
│  [✕]  3 selected                 [All]  │  <-- Contextual Action Bar (Top)
│                                         │
│  ┌───────────────┐ ┌───────────────┐    │
│  │ [✓]           │ │ [✓]           │    │  <-- Checked Accent Ring (#6366F1)
│  │               │ │               │    │      Card scales to 0.96 with
│  │               │ │               │    │      indigo border
│  └───────────────┘ └───────────────┘    │
│  ┌───────────────┐ ┌───────────────┐    │
│  │ [○]           │ │ [✓]           │    │
│  │               │ │               │    │
│  └───────────────┘ └───────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ [Keep (2 new)]  [Share]  [Done] │    │  <-- Floating Bottom Action Bar
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

- **Trigger:** Long press on any card or tapping "Select" in top menu.
- **Header:** Close `[✕]` button, item counter ("3 selected"), "Select All" toggle button.
- **Card State:** Selected cards display a filled violet checkmark (`#6366F1`) and a 1.5px violet border.
- **Smart Bottom Bar:** Shows primary CTA **"Keep (2 new)"** (automatically factoring out the 1 item already kept). Secondary action `Share` (launches standard Android share sheet).
- **Accessibility:** Announces `"Item 2 of 18 selected. 3 total items selected."`

---

### Screen 10: Immersive Image Viewer

```
┌─────────────────────────────────────────┐
│  [←]   Today, 2:14 PM         [Share] [⋮]│ <-- Auto-hiding Minimal Top Bar
│                                         │
│                                         │
│                                         │
│             IMMERSIVE FULL-BLEED        │  <-- Edge-to-edge high-res photo
│                    IMAGE                │      Pinch-to-zoom (up to 4×)
│                                         │      Double-tap to 2× toggle
│                                         │      Swipe-down to dismiss
│                                         │
│                                         │
│                                         │
│   Original • 1080 × 1920 • 2.8 MB       │  <-- Quality Integrity Badge
│   ┌─────────────────────────────────┐   │
│   │           Keep Photo            │   │  <-- Floating Signature Action Pill
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Visual Tone:** Pure immersive canvas. System navigation bar and top bar fade out after 3 seconds of inactivity or upon single tap.
- **Gestures:**
  - Pinch-to-zoom with fluid spring bounce-back.
  - Double-tap toggles between 1× and 2.5× zoom.
  - Vertical swipe-down translates the image and fades background scrim to dismiss back to grid.
  - Horizontal swipe navigates to previous/next status seamlessly.
- **Quality Integrity Display:** Discrete pill above bottom bar showing true technical metrics: `"Original • 1080 × 1920 • 2.8 MB"` in tabular figures.
- **Bottom Action:** 48dp pill button: `"Keep Photo"` (or `"Already kept"` with checkmark).

---

### Screen 11: Immersive Video Viewer

```
┌─────────────────────────────────────────┐
│  [←]   Today, 1:45 PM         [Share] [⋮]│
│                                         │
│                                         │
│                   [ ▶ ]                 │  <-- Center Play/Pause Overlay
│                                         │      (Auto-hides during playback)
│             VIDEO PLAYBACK              │
│                                         │
│                                         │
│                                         │
│  0:12 ━━━━━━━━●━━━━━━━━━━━━━━━ 0:30     │  <-- Scrubber Track (Mint Progress)
│                                         │
│   Original • 720 × 1280 • 8.4 MB        │  <-- Quality Badge
│   ┌─────────────────────────────────┐   │
│   │           Keep Video            │   │  <-- Signature Keep CTA
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Playback Engine:** Native video stream cached to internal file sandbox for instant seeking without memory bloat.
- **Controls:**
  - Scrubber with draggable thumb (`radiusXs`, mint progress bar).
  - Time readout (current elapsed vs total duration).
  - Tap anywhere toggles play/pause and controls visibility.
  - Mute/unmute toggle in top-right corner.
- **Keep Action:** Saves high-fidelity MP4 directly into public `Movies/SavedStatus` via MediaStore.

---

### Screen 12: Signature Action ("KEEP") & Feedback States

```
STATE A: UNKEPT (DEFAULT)
┌─────────────────────────────────────────┐
│  [ ⬇  Keep ]                            │  <-- Gradient #10B981 to #059669
└─────────────────────────────────────────┘

STATE B: IN PROGRESS (SAVING)
┌─────────────────────────────────────────┐
│  [  ◌  Keeping... ]                     │  <-- Circular Mint Progress Spinner
└─────────────────────────────────────────┘

STATE C: KEPT SAFELY (CONFIRMATION)
┌─────────────────────────────────────────┐
│  [  ✓  Kept safely ]                    │  <-- Soft Mint Tint #064E3B + Haptic Tick
└─────────────────────────────────────────┘

STATE D: ALREADY KEPT (DUPLICATE)
┌─────────────────────────────────────────┐
│  [  ✓  Already kept  ▾ ]                │  <-- Opens options: View / Keep anyway
└─────────────────────────────────────────┘
```

- **Haptic Design:** `HapticFeedback.mediumImpact()` triggers upon save completion.
- **Toast / Banner:** Subtle bottom toast: `"Saved to Gallery in Pictures/SavedStatus"` with `"View"` action button.

---

### Screen 13: Duplicate Shield Experience

```
┌─────────────────────────────────────────┐
│  Duplicate Shield                       │  <-- Modal Bottom Sheet
│                                         │
│         ╭───╮                           │
│        │ 🛡️ │                           │  <-- assets/illustrations/duplicate.svg
│         ╰───╯                           │
│  Already Kept                           │  <-- Headline Medium (20sp)
│  This exact photo was saved to your     │
│  gallery on Today, 11:30 AM.            │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │           View Saved            │   │  <-- Primary CTA: Opens in Kept tab
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │           Keep Anyway           │   │  <-- Secondary Ghost CTA: Saves copy
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Duplicate Detection Logic:** Compares document display name, byte size, and last modified timestamp against local SQLite/prefs ledger.
- **Zero Guilt:** Validates the user's intent without scolding them; provides an effortless path to view the existing saved photo in gallery.

---

### Screen 14: Kept Library (Saved Vault Tab)

```
┌─────────────────────────────────────────┐
│  KEPT                        [1.2 GB] [⋮]│  <-- Storage Footprint Header
│                                         │
│  Your Saved Moments                     │  <-- Headline Large (24sp)
│  42 items kept safely                   │
│                                         │
│  Yesterday                              │  <-- Date Grouping Header
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐│
│  │       │ │ [▶]   │ │       │ │       ││  <-- 4-column compact grid
│  └───────┘ └───────┘ └───────┘ └───────┘│
│                                         │
│  September 3                            │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐│
│  │       │ │       │ │ [▶]   │ │       ││
│  └───────┘ └───────┘ └───────┘ └───────┘│
│                                         │
│  [  Moments  ]   [    Kept   ]   [ Settings ]
└─────────────────────────────────────────┘
```

- **Organization:** Chronologically grouped by date saved (Today, Yesterday, Last Week, Earlier).
- **Header Badge:** Live storage footprint pill (`1.2 GB`) showing total space occupied by saved statuses in public storage.
- **Actions:** Share, open in device gallery app, or remove from Kept.

---

### Screen 15: Settings Screen

```
┌─────────────────────────────────────────┐
│  SETTINGS                               │
│                                         │
│  APPEARANCE                             │  <-- Section Header (12sp Label)
│  Theme                       Dark (OLED)│
│                                         │
│  STORAGE & CACHE                        │
│  Saved Location       Pictures/Movies   │
│  Thumbnail Cache                 24 MB  │
│  Video Stream Cache              48 MB  │
│  [ Clear Temporary Caches ]             │  <-- Ghost Button
│                                         │
│  MEDIA SOURCE                           │
│  WhatsApp Folder             Connected ✓│  <-- SAF Path
│  [ Re-select Media Folder ]             │
│                                         │
│  PRIVACY & SECURITY                     │
│  Privacy Model               100% Local │
│  [ View Privacy Enclave Details ]       │
│                                         │
│  ABOUT                                  │
│  Version                        1.0.0   │
│  Build                    Phase 2 Native│
└─────────────────────────────────────────┘
```

- **Cache Management:** Allows user to safely flush downsampled thumbnails and temporary video playback buffers without touching saved gallery media.
- **Folder Management:** Displays status of connected SAF tree; allows re-running folder picker if user moved their WhatsApp directory or switched devices.

---

### Screen 16: Privacy Surface Sheet

```
┌─────────────────────────────────────────┐
│  Privacy & Data Architecture            │  <-- Modal Sheet Header
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ [✓] 100% On-Device Processing     │  │
│  │     Keeva has zero internet        │  │
│  │     permissions in AndroidManifest│  │
│  ├───────────────────────────────────┤  │
│  │ [✓] Isolated Folder Access        │  │
│  │     Only the WhatsApp/Media       │  │
│  │     folder chosen by you is read  │  │
│  ├───────────────────────────────────┤  │
│  │ [✓] No Chats or Contacts          │  │
│  │     Keeva cannot read messages,    │  │
│  │     sender identities, or numbers │  │
│  ├───────────────────────────────────┤  │
│  │ [✓] Zero Telemetry Tracking       │  │
│  │     No analytics SDKs or remote   │  │
│  │     crash trackers embedded       │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [ Done ]                               │
└─────────────────────────────────────────┘
```

- **Purpose:** Builds unshakeable trust by translating complex Android security concepts (no network permissions, Scoped Storage isolation) into simple, verifiable statements.

---

### Screen 17: Moment Replay Concept (Future Architecture)

```
┌─────────────────────────────────────────┐
│  ━━━━━ ━━━━━ ━━━━━ ━━━━━ ━━━━━ ━━━━━    │  <-- Chronological Progress Segments
│  [✕]   Moment Replay          Today     │  <-- Header overlay
│                                         │
│                                         │
│                                         │
│         FULL-SCREEN STORY               │  <-- Auto-advancing chronological
│            PLAYBACK OF                  │      slideshow of all current
│          CURRENT MOMENTS                │      unkept moments
│                                         │
│                                         │
│                                         │
│   Tap Left: Prev  │  Tap Right: Next   │
│   Hold: Pause     │  Swipe Up: Keep    │  <-- Gesture Affordance
│                                         │
│   ┌─────────────────────────────────┐   │
│   │           Keep Moment           │   │  <-- Instant Keep Pill
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

- **Concept:** Enables viewing all discovered moments sequentially in a full-screen story format with 5-second automatic progression.
- **Gestures:** Tap right to skip, tap left to go back, press-and-hold to freeze, swipe up to instantly keep.
- **Status:** Architectural specification complete; scheduled for rollout in future Phase 2 follow-ups.

---

## 3. Responsive & Multi-Window Layout Rules

```
Screen Width       Layout Adaptations
─────────────────────────────────────────────────────────────────────────────────────────────
< 400dp            2-column grid. Bottom navigation text labels hidden (icons only).
400dp – 600dp      2-column grid (large cards). Standard bottom navigation bar with labels.
600dp – 840dp      3-column grid. Left-docked 80dp Navigation Rail replaces bottom bar.
> 840dp (Tablet)   4 or 5-column grid. Expanded 220dp Navigation Rail with text labels.
Landscape Mode     Navigation Rail docked to left. Top bar condensed. Grid columns expand to 4.
Multi-Window / Split Fluidly recalculates column count based on container width (`LayoutBuilder`).
```

---

## 4. Accessibility & Contrast Safeguards

1. **Light-Theme Text Contrast Rule:**
   - Token `#9CA3AF` (`textTertiary`) has a contrast ratio of only **3.0:1** against the `#F9FAFB` light background.
   - **Rule:** `#9CA3AF` must **NEVER** be used for readable body text, captions, timestamps, durations, or metadata in the light theme where the contrast is insufficient.
   - All readable light-theme text must use `textSecondary` (`#4B5563`, 7.8:1 AAA) or `textPrimary` (`#111827`, 16.1:1 AAA).
   - In the light theme, `#9CA3AF` is strictly reserved for disabled UI controls and non-text inactive iconography.

2. **Quick-Keep Button Accessibility Contract:**
   - **Visual Affordance:** 32dp circular glass container.
   - **Interactive Hit Area:** 48dp minimum (`48×48dp` hit test envelope).
   - **Rule:** Do NOT enlarge the visual icon merely to satisfy the hit target requirement. Keep the visual affordance at 32dp to prevent obscuring media thumbnails while wrapping the touch target in a 48×48dp hit boundary.

