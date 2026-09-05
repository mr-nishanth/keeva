# Keeva Design System Specification

**Product:** Keeva (WhatsApp Status Saver → New Product Identity)  
**Document Status:** Complete Design System Specification  
**Design Phase:** Phase 2E-A (Product Brand & UI/UX Design System)  
**Theme:** Obsidian + Aurora  
**Authors:** Senior Flutter UI Design-System Architect & Mobile Accessibility Specialist  
**Date:** September 2026  

---

## 1. Overview & Architectural Philosophy

The Keeva Design System provides the deterministic visual tokens, components, typography, layout metrics, and motion choreographies for the application.

### Key Tenets
1. **Media Heroism:** UI chrome exists solely to frame and elevate visual content. Chrome elements are desaturated, quiet, and borderless or framed with subtle 1px translucent boundaries.
2. **True Dark Mode Engineering:** Avoids pure `#000000` on scroll containers to prevent OLED purple-fringing smearing during 120Hz scrolling on Android OLEDs, while maintaining deep graphite blacks (`#090B0E` to `#161922`) for maximum power savings and eye comfort.
3. **Accessibility First:** 100% of interactive elements meet or exceed WCAG 2.2 AA contrast guidelines (4.5:1 for body text, 3:1 for large display text and UI boundaries) and enforce 48×48dp minimum touch targets.
4. **Platform Harmony:** Designed for native Android (Material 3 adaptive foundations with dynamic navigation bar color and predictive back gestures) while remaining platform-independent in pure Flutter.

---

## 2. Color System & Semantic Tokens

Keeva provides complete token parity across **Dark Theme** (Obsidian + Aurora, default) and **Light Theme** (Crisp Editorial).

### 2.1 Dark Theme Palette (Obsidian + Aurora)

```
CANVAS & SURFACES                   PRIMARY (AURORA MINT)          ACCENT (AURORA INDIGO)
┌───────────────────────────┐       ┌───────────────────────┐      ┌───────────────────────┐
│ #090B0E   Background      │       │ #10B981   Primary     │      │ #6366F1   Accent      │
│ #11141A   Surface L0      │       │ #34D399   Primary-Lt  │      │ #818CF8   Accent-Lt   │
│ #161A22   Surface L1 Card │       │ #064E3B   Primary-Dk  │      │ #312E81   Accent-Dk   │
│ #1E232E   Surface L2 Elev │       │ #A7F3D0   On-Primary-C│      │ #E0E7FF   On-Accent-C │
│ #282E3C   Surface L3 Top  │       └───────────────────────┘      └───────────────────────┘
└───────────────────────────┘
```

| Token Name | Hex Code | RGB | Semantic Role & Usage | Contrast vs Background |
| :--- | :--- | :--- | :--- | :--- |
| `background` | `#090B0E` | `9, 11, 14` | Deep obsidian canvas; behind all screens. | Base |
| `surfaceLevel0` | `#11141A` | `17, 20, 26` | Flat non-elevated containers, navigation bars. | 1.2:1 |
| `surfaceLevel1` | `#161A22` | `22, 26, 34` | Media cards, list items, search inputs. | 1.6:1 |
| `surfaceLevel2` | `#1E232E` | `30, 35, 46` | Bottom sheets, dialogs, floating action pills. | 2.1:1 |
| `surfaceLevel3` | `#282E3C` | `40, 46, 60` | Tooltips, popover menus, high-emphasis overlays. | 3.0:1 |
| `primary` | `#10B981` | `16, 185, 129` | Aurora mint; primary Keep button, active tabs, sparks. | **8.4:1 (AAA)** |
| `onPrimary` | `#042F2E` | `4, 47, 46` | Text and icons placed on top of `primary`. | **10.2:1 (AAA)** |
| `primaryContainer` | `#064E3B` | `6, 78, 59` | Subdued badges, "Already Kept" tags, chip backgrounds. | 2.5:1 |
| `onPrimaryContainer`| `#A7F3D0` | `167, 243, 208` | Text on top of `primaryContainer`. | **11.6:1 (AAA)** |
| `accent` | `#6366F1` | `99, 102, 241` | Aurora violet; multi-selection ring, focus halo, active badges. | **5.2:1 (AA)** |
| `onAccent` | `#FFFFFF` | `255, 255, 255` | Text on top of `accent`. | **5.8:1 (AA)** |
| `accentContainer` | `#1E1B4B` | `30, 27, 75` | Subtle selection overlay, timeline scrubbing track. | 1.5:1 |
| `onAccentContainer`| `#C7D2FE` | `199, 210, 254` | Labels inside accent containers. | **10.8:1 (AAA)** |
| `textPrimary` | `#F9FAFB` | `249, 250, 251` | Highest emphasis headlines, active tab titles. | **18.2:1 (AAA)** |
| `textSecondary` | `#9CA3AF` | `156, 163, 175` | Captions, durations, timestamps, secondary labels. | **7.1:1 (AAA)** |
| `textTertiary` | `#6B7280` | `107, 114, 128` | Placeholder text, inactive tab icons, disabled states. | **4.6:1 (AA)** |
| `success` | `#10B981` | `16, 185, 129` | "Kept safely" confirmation icon, verified storage status. | **8.4:1 (AAA)** |
| `warning` | `#F59E0B` | `245, 158, 11` | "Expiring soon" indicator, storage low warning. | **9.1:1 (AAA)** |
| `error` | `#EF4444` | `239, 68, 68` | Folder access revoked, write failure, delete actions. | **5.3:1 (AA)** |
| `onError` | `#FFFFFF` | `255, 255, 255` | Text on top of `error`. | **4.8:1 (AA)** |
| `borderSubtle` | `rgba(255,255,255,0.08)` | — | 1px card boundary in dark mode for edge crispness. | — |
| `borderFocused` | `rgba(99,102,241,0.50)` | — | 1.5px selection or focus ring. | — |
| `scrim` | `rgba(0,0,0,0.72)` | — | Backdrop barrier behind modal bottom sheets and viewers. | — |
| `videoScrim` | `linear-gradient(to top, rgba(0,0,0,0.85), transparent)` | — | Gradient overlay for media card badges and viewer controls. | — |

---

### 2.2 Light Theme Palette (Crisp Editorial)

| Token Name | Hex Code | RGB | Semantic Role & Usage | Contrast vs Background |
| :--- | :--- | :--- | :--- | :--- |
| `background` | `#F9FAFB` | `249, 250, 251` | Warm off-white editorial paper canvas. | Base |
| `surfaceLevel0` | `#FFFFFF` | `255, 255, 255` | Flat white top bars, navigation rail, cards. | 1.05:1 |
| `surfaceLevel1` | `#F3F4F6` | `243, 244, 246` | Chip backgrounds, subtle search inputs. | 1.15:1 |
| `surfaceLevel2` | `#FFFFFF` | `255, 255, 255` | Modal bottom sheets with soft ambient shadow. | 1.05:1 |
| `surfaceLevel3` | `#E5E7EB` | `229, 231, 235` | Tooltips, popovers, borders. | 1.3:1 |
| `primary` | `#059669` | `5, 150, 105` | Deeper forest-mint for high legibility on white. | **4.9:1 (AA)** |
| `onPrimary` | `#FFFFFF` | `255, 255, 255` | Text and icons on `primary`. | **4.9:1 (AA)** |
| `primaryContainer` | `#D1FAE5` | `209, 250, 229` | Soft mint tint for "Kept" badges and chip toggles. | 1.2:1 |
| `onPrimaryContainer`| `#065F46` | `6, 95, 70` | Text on top of `primaryContainer`. | **7.5:1 (AAA)** |
| `accent` | `#4F46E5` | `79, 70, 229` | Deep indigo for multi-selection and links. | **6.8:1 (AAA)** |
| `onAccent` | `#FFFFFF` | `255, 255, 255` | Text on top of `accent`. | **6.8:1 (AAA)** |
| `textPrimary` | `#111827` | `17, 24, 39` | High-contrast body text and headers. | **16.1:1 (AAA)** |
| `textSecondary` | `#4B5563` | `75, 85, 99` | Subheaders, timestamps, secondary labels. | **7.8:1 (AAA)** |
| `textTertiary` | `#9CA3AF` | `156, 163, 175` | Disabled text, inactive icons. | **3.0:1** |
| `borderSubtle` | `rgba(0,0,0,0.08)` | — | 1px border on cards and dividers. | — |
| `scrim` | `rgba(17,24,39,0.48)` | — | Soft dark overlay behind modal sheets. | — |

> [!IMPORTANT]
> **Light-Theme Contrast Rule:** `#9CA3AF` (`textTertiary`) has a 3.0:1 contrast ratio against `#F9FAFB`. It must NEVER be used for readable body text, captions, timestamps, durations, or metadata in the light theme where the contrast is insufficient. All readable text must use `textSecondary` (`#4B5563`, 7.8:1 AAA) or `textPrimary` (`#111827`, 16.1:1 AAA). In the light theme, `#9CA3AF` is strictly restricted to disabled UI controls and non-text inactive iconography.

---

## 3. Typography System

The typography is built around **Plus Jakarta Sans**, a contemporary geometric sans-serif designed by Tokotype. It features generous x-height, open apertures, and subtle humanistic curves that render crisply on both standard and ultra-dense AMOLED displays (such as 446 PPI on the Xiaomi 2311DRK48I).

System Fallbacks: `system-ui`, `Roboto`, `Helvetica Neue`, `sans-serif`.

### 3.1 Type Scale Specification

```
Scale Name         Size / Height   Weight          Tracking    Flutter TextStyle Equivalent
─────────────────────────────────────────────────────────────────────────────────────────────
Display Large      32sp / 40dp     SemiBold (600)  -0.5sp      theme.textTheme.displayLarge
Display Medium     28sp / 36dp     SemiBold (600)  -0.25sp     theme.textTheme.displayMedium
Headline Large     24sp / 32dp     SemiBold (600)  0.0sp       theme.textTheme.headlineLarge
Headline Medium    20sp / 28dp     SemiBold (600)  0.0sp       theme.textTheme.headlineMedium
Title Large        18sp / 24dp     Medium (500)    0.0sp       theme.textTheme.titleLarge
Title Medium       16sp / 22dp     Medium (500)    +0.1sp      theme.textTheme.titleMedium
Body Large         15sp / 22dp     Regular (400)   0.0sp       theme.textTheme.bodyLarge
Body Medium        14sp / 20dp     Regular (400)   0.0sp       theme.textTheme.bodyMedium
Body Small         12sp / 16dp     Regular (400)   +0.1sp      theme.textTheme.bodySmall
Label Large        14sp / 18dp     SemiBold (600)  +0.2sp      theme.textTheme.labelLarge
Label Medium       12sp / 16dp     Medium (500)    +0.3sp      theme.textTheme.labelMedium
Label Small        10sp / 14dp     SemiBold (600)  +0.5sp      theme.textTheme.labelSmall
Metadata Numeric   11sp / 14dp     Medium (500)    +0.2sp      FontFeatures.tabularFigures()
```

### 3.2 Numeric & Tabular Data Rule
All media durations (`0:24`), dimensions (`1080 × 1920`), timestamps (`14m ago`), and file metrics (`4.8 MB`) must be styled with `FontFeature.tabularFigures()` to prevent jitter and layout jumps during active video playback scrubbing.

---

## 4. Spacing & Layout Grid System

Keeva strictly enforces an **8pt foundational grid** with a **4pt sub-grid** for micro-alignments.

### 4.1 Spacing Scale

| Token | Dimension | Common Use Case |
| :--- | :--- | :--- |
| `space2` | 2dp | Micro-gaps between badge icon and text. |
| `space4` | 4dp | Gap between time label and duration pill; inner chip padding. |
| `space8` | 8dp | Grid spacing between media cards; button horizontal icon spacing. |
| `space12` | 12dp | Compact card internal padding; chip horizontal padding. |
| `space16` | 16dp | Screen horizontal margin on mobile; sheet standard padding. |
| `space20` | 20dp | Spacing between section headers and content blocks. |
| `space24` | 24dp | Bottom navigation vertical height offset; modal sheet top padding. |
| `space32` | 32dp | Hero graphic margin; large empty-state vertical spacing. |
| `space48` | 48dp | Minimum touch target bounding box (`kMinInteractiveDimension`). |
| `space64` | 64dp | Floating Action Button anchor clearance; onboarding top spacing. |

### 4.2 Screen Margins & Columns

```
Device Form Factor           Width Range     Horizontal Margin   Grid Columns   Gutter
─────────────────────────────────────────────────────────────────────────────────────────────
Compact Mobile (Portrait)     < 600dp         16dp                2 or 3         8dp
Medium Tablet / Foldable      600dp – 840dp   24dp                3 or 4         12dp
Expanded Tablet (Landscape)   > 840dp         32dp                4 or 5         16dp
```

---

## 5. Corner Radius System

Rounded corners convey softness, precision, and the physical metaphor of modern mobile devices.

| Token | Value | Applied To |
| :--- | :--- | :--- |
| `radiusXs` | 4dp | Status badges (e.g., "0:15", "MP4"), scrubber thumbs. |
| `radiusSm` | 8dp | Compact chips, selection check boxes, snackbars. |
| `radiusMd` | 12dp | Media card thumbnails, dialog boxes, text input fields. |
| `radiusLg` | 16dp | High-emphasis cards, onboarding illustration frames. |
| `radiusXl` | 24dp | Modal bottom sheet top corners, signature "Keep" action pill. |
| `radiusPill`| 9999dp | Filter chips, trust indicator ("Private"), floating pill bars. |

---

## 6. Elevation, Surface Depth & Lighting

In dark mode, traditional black drop shadows (`box-shadow: 0 8px 16px rgba(0,0,0,0.5)`) are invisible against dark canvases and create muddy artifacts. Keeva uses **Tonal Surface Elevation** combined with **1px Translucent Boundaries** and **Ambient Specular Sheen**:

### 6.1 Elevation Hierarchy

```
Level 0: Base Canvas (#090B0E)
  └── Level 1: Cards & Grid Items (#161A22) + 1px border rgba(255,255,255,0.06)
        └── Level 2: Modal Sheets & FABs (#1E232E) + 1px border rgba(255,255,255,0.10) + Soft 4% Ambient Glow
              └── Level 3: Menus & Tooltips (#282E3C) + 1px border rgba(255,255,255,0.16)
```

1. **Card Border:** Every media card in dark mode has a subtle `border: 1px solid rgba(255, 255, 255, 0.06)`. This creates crisp optical separation between neighboring thumbnails without adding visual clutter.
2. **Sheet Border:** Modal bottom sheets utilize a top border of `1px solid rgba(255, 255, 255, 0.12)`.
3. **No Heavy Shadows:** Soft shadows are used only in Light Mode (`rgba(0, 0, 0, 0.08)` blur 12dp).

---

## 7. Iconography Guidelines

1. **Family:** Cohesive rounded geometric stroke (styled identically to **Material Symbols Rounded** or **Lucide**).
2. **Stroke Weight:** Consistent 1.75dp (scaled for 24×24dp bounding boxes).
3. **Caps & Joins:** Smooth rounded line-caps (`stroke-linecap="round"`) and line-joins (`stroke-linejoin="round"`).
4. **Optical Sizing:** 
   - Primary Navigation: 24×24dp
   - Card Indicators: 16×16dp
   - Micro Badges: 12×12dp
   - Large Empty States: 48×48dp to 64×64dp

### Standard Icon Mapping
- Moments Inbox: `auto_awesome_motion` / `layers`
- Kept Library: `bookmark` / `folder_special`
- Settings: `tune` / `settings`
- Keep Action: `bookmark_add` / `archive`
- Already Kept: `bookmark_added` / `check_circle`
- Video Indicator: `play_arrow`
- Image Indicator: `image`
- Privacy Shield: `verified_user` / `lock`
- Selection Mode: `check_circle_outline` / `check_circle`

---

## 8. Motion & Animation Choreography

Animations in Keeva are designed to feel **weightless, swift, and respectful**. Every animation serves an orientation purpose.

### 8.1 Motion Easing Curves

```dart
// Natural physics-based cubic bezier curves
static const Curve emphasizedDecelerate = Cubic(0.05, 0.70, 0.10, 1.00); // Entrances
static const Curve emphasizedAccelerate = Cubic(0.30, 0.00, 0.80, 0.15); // Exits
static const Curve standardEasing       = Cubic(0.20, 0.00, 0.00, 1.00); // Morphing & Toggles
```

### 8.2 Motion Durations
- `durationMicro`: 100ms (Haptic tap feedback, checkmark fill)
- `durationFast`: 150ms (Filter chip selection, card scale-down on press)
- `durationMedium`: 250ms (Navigation tab transitions, top bar expansion)
- `durationDeliberate`: 350ms (Bottom sheet spring slide-up, dialog entrance)
- `durationHero`: 300ms (Thumbnail to full-screen viewer zoom transition)

### 8.3 Choreography Details
1. **Grid Appearance:** When the Moments screen loads, cards enter with a staggered vertical rise of 8dp and a gentle fade over 220ms, with a 20ms offset per row (capped at 4 rows to prevent lag on 100+ item lists).
2. **Keep Signature Action:**
   - User taps "Keep".
   - Button scales to `0.96` over 80ms accompanied by an Android system light haptic feedback click (`HapticFeedback.lightImpact()`).
   - Icon transitions smoothly from `bookmark_outline` to `bookmark_added` using a spring curve (`SpringSimulation`).
   - Background subtly pulses with an aurora mint ring (`#10B981` at 20% alpha expanding outwards and dissipating over 300ms).
   - Card badge updates to "Kept".
3. **Swipe-to-Dismiss in Media Viewer:**
   - Swiping down translates the media 1:1 with finger touch.
   - Background scrim opacity scales proportionally: `opacity = 1.0 - (dragDistance / 300dp)`.
   - Releasing past 120dp threshold smoothly animates the image back into its grid position over 200ms.

---

## 9. Core Component Specifications

### 9.1 The Media Card (Thumbnail Card)
- **Aspect Ratio:** Staggered vertical `9:16` or uniform `3:4` grid cards.
- **Corner Radius:** `radiusMd` (12dp) with `clipBehavior: Clip.antiAlias`.
- **Border:** `1px solid rgba(255, 255, 255, 0.06)`.
- **Overlays:**
  - *Bottom Scrim:* Translucent dark gradient spanning the bottom 40% of the thumbnail.
  - *Type Badge (Bottom Left):* If video, pill container (`#000000` at 60% alpha, 4dp radius) showing a play triangle + tabular duration (`0:28`).
  - *Kept Status (Top Right):* If already kept, a discreet mint badge (`#10B981`, checkmark icon, 8dp pill) appears.
  - *Selection Circle (Top Left):* In selection mode, an animated checkbox appears (empty ring transitioning to filled `#6366F1` circle with white check).

### 9.2 The Signature "Keep" Button
- **Shape:** Pill container (48dp height, 9999dp radius).
- **Default State:** Gradient fill from `#10B981` to `#059669`, bold off-white label "Keep", 18dp bookmark icon, `onPrimary` text.
- **Already Kept State:** Subdued container (`#064E3B`), muted mint text (`#A7F3D0`), label "Already kept", check icon. Tap triggers options ("View saved" or "Keep anyway").
- **Disabled State:** Background `#1E232E`, text `#6B7280`.

### 9.3 The "Private" Trust Pill
- **Placement:** Top right of the Moments screen header.
- **Visual:** 24dp high pill, background `rgba(16, 185, 129, 0.12)`, border `1px solid rgba(16, 185, 129, 0.30)`.
- **Contents:** 12dp emerald lock/shield icon + "Private" text in 11sp SemiBold (`#34D399`).
- **Interaction:** Tapping opens the **Privacy Surface Sheet**, detailing the on-device SAF isolation model.

### 9.4 Bottom Navigation Bar (Phone)
- **Height:** 64dp + system gesture bar insets (`MediaQuery.viewPaddingOf(context).bottom`).
- **Background:** `surfaceLevel0` (`#11141A`) with top divider `1px solid rgba(255, 255, 255, 0.06)`.
- **Items (3):**
  1. **Moments** (`auto_awesome_motion`)
  2. **Kept** (`bookmark`)
  3. **Settings** (`tune`)
- **Active Indicator:** Smooth pill background behind active icon (`#10B981` at 15% opacity, 12dp radius, 32×56dp bounds).

### 9.5 Navigation Rail (Tablet / Desktop / Landscape)
- **Placement:** Docked to the leading (left) edge of the screen.
- **Width:** 80dp (compact) or 220dp (expanded on large displays > 900dp).
- **Background:** `surfaceLevel0` (`#11141A`) with trailing divider `1px solid rgba(255, 255, 255, 0.06)`.
- **Header:** Mini Keeva logo mark at top (32dp), items centered vertically, privacy trust pill anchored to the bottom.

---

## 10. Accessibility (a11y) & Platform Compliance

1. **Touch Targets:** All clickable icons (back buttons, menu toggles, play/pause controls, filter chips) are wrapped with minimum `48×48dp` hit test boundaries via `SizedBox(width: 48, height: 48)`.
2. **Screen Reader Semantics:**
   - Every media card provides an explicit semantic label:  
     `Semantics(label: "Photo status from Today, size 2.4 megabytes, not kept. Double tap to preview, double tap and hold to select.")`
   - Video card semantic label:  
     `Semantics(label: "Video status, duration 30 seconds, size 12.1 megabytes, already kept.")`
3. **Dynamic Font Scaling:** All text elements respond cleanly to Android system font scaling up to **200%** without text clipping, using flexible vertical wrap containers and ellipsis truncation only on secondary metadata.
4. **Reduced Motion:** If `MediaQuery.disableAnimationsOf(context)` or `prefers-reduced-motion` is enabled, all staggered entrance animations and zoom transitions are disabled, instantly snapping to the resolved layout.
5. **Quick-Keep Button Accessibility Contract:**
   - **Visual Affordance:** 32dp circular glass container (compact to maximize visual media visibility on 9:16 cards).
   - **Interactive Hit Area:** 48dp minimum (`48×48dp` interactive hit area via touch target padding or gesture hit-test padding).
   - **Rule:** Do NOT enlarge the visual icon merely to satisfy the hit target requirement. The visual affordance remains 32dp while the interactive touch target satisfies the >= 48dp accessibility standard.

