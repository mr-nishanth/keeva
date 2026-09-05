# Comprehensive Digital Asset Inventory & Specification

**Product:** Keeva (WhatsApp Status Saver → New Product Identity)  
**Document Status:** Approved Asset Inventory & Visual Guidelines  
**Design Phase:** Phase 2E-A (Product Brand & UI/UX Design System)  
**Authors:** Senior Visual & Brand Designer  
**Date:** September 2026  

---

## 1. Overview & Asset Standards

All visual assets in Keeva are crafted to reinforce the **Obsidian + Aurora** aesthetic:
- **Vector-First:** All icons, brand marks, and explanatory illustrations are authored in scalable vector graphics (SVG) with clean semantic paths, viewBox attributes, and zero raster dependencies.
- **Strict Brand Independence:** Zero WhatsApp logos, green phone bubbles, or Meta intellectual property are used anywhere. All guidance art employs neutral, modern Android system metaphors.
- **Resolution & Optimization:** All SVG files are hand-optimized with minimal control points, formatted for Flutter's vector rendering pipelines (`flutter_svg`), and accompanied by high-density raster exports (512×512 PNGs for store icons and Android adaptive layers).

---

## 2. Complete Master Asset Inventory

### 2.1 Brand & Identity Assets (`assets/brand/`)

| File Path | Format | Canonical Dimensions | Semantic Role & Purpose | Dominant Color Tokens | Accessibility Description |
| :--- | :---: | :---: | :--- | :--- | :--- |
| `assets/brand/logo.svg` | SVG | 800×240 (viewBox) | Master Horizontal Lockup: Aperture Mark + "Keeva" Wordmark. | `#10B981`, `#6366F1`, `#F9FAFB` | "Keeva brand logo with geometric aperture mark and bold wordmark" |
| `assets/brand/logo_mark.svg` | SVG | 512×512 (viewBox) | Standalone Geometric Symbol: Outer squircle media frame + inward fold + aurora spark. | `#10B981`, `#6366F1`, `#11141A` | "Keeva logo mark, an abstract folding aperture framing a luminous spark" |
| `assets/brand/logo_wordmark.svg` | SVG | 600×180 (viewBox) | Pure Typographic Wordmark set in Plus Jakarta Sans SemiBold. | `#F9FAFB` (Dark) / `#111827` (Lt) | "Keeva wordmark in clean geometric sans-serif typography" |
| `assets/brand/logo_light.svg` | SVG | 800×240 (viewBox) | High-contrast lockup optimized for white paper / light backgrounds. | `#059669`, `#4F46E5`, `#111827` | "Keeva logo lockup in high-contrast dark forest green and obsidian typography" |
| `assets/brand/logo_dark.svg` | SVG | 800×240 (viewBox) | High-contrast lockup optimized for obsidian dark mode canvas. | `#10B981`, `#818CF8`, `#F9FAFB` | "Keeva logo lockup in radiant aurora mint and crisp off-white typography" |
| `assets/brand/brand_guidelines.md` | MD | Text Document | Quick brand rules, clear space metrics, color codes, and misuse guidelines. | — | Brand documentation for developers and marketing. |

---

### 2.2 Android App Icon Assets (`assets/icon/`)

| File Path | Format | Canonical Dimensions | Target Surface & Usage | Color Palette | Technical Specification |
| :--- | :---: | :---: | :--- | :--- | :--- |
| `assets/icon/adaptive_foreground.svg` | SVG | 432×432 (viewBox) | Android Adaptive Icon Foreground layer (centered 240dp safe zone). | `#10B981`, `#6366F1`, `#F9FAFB` | Zero background; mark centered within 66dp inset radius. |
| `assets/icon/adaptive_background.svg` | SVG | 432×432 (viewBox) | Android Adaptive Icon Background layer. | `#090B0E`, `#161A22` | Deep charcoal canvas with 2% radial specular center sheen. |
| `assets/icon/app_icon_512.svg` | SVG | 512×512 (viewBox) | Master vector squircle launcher & store asset source. | Obsidian canvas + Aurora mint mark | Scalable vector graphic, standalone squircle frame with aperture mark. |
| `assets/icon/app_icon_round_512.svg` | SVG | 512×512 (viewBox) | Master vector round launcher icon source. | Obsidian canvas + Aurora mint mark | Scalable vector graphic, circular clipping mask with aperture mark. |
| `assets/icon/app_icon_512.png` | PNG | 512×512 px (32-bit RGBA) | Master Google Play Store listing icon & standard launcher squircle. | Obsidian canvas + Aurora mint mark | 512×512 PNG, sRGB color profile, uncompressed. |
| `assets/icon/app_icon_round_512.png` | PNG | 512×512 px (32-bit RGBA) | Circular launcher icon for Pixel Launcher and Samsung OneUI. | Obsidian canvas + Aurora mint mark | 512×512 circular mask, smooth antialiased perimeter. |

---

### 2.3 Onboarding Guidance Illustrations (`assets/onboarding/`)

All onboarding illustrations are authored in vector SVG for fidelity and paired with pre-rendered WebP counterparts for lightweight fallback/raster performance.

| File Path | Format | Canonical Dimensions | Onboarding Step | Conceptual Illustration Description | Accessibility Description |
| :--- | :---: | :---: | :---: | :--- | :--- |
| `assets/onboarding/welcome.svg` | SVG | 600×500 (viewBox) | Step 1: Welcome | Abstract luminous photographic cards floating gently through an obsidian aperture into a safe harbor. | "Illustration of glowing visual cards being preserved in an aperture frame" |
| `assets/onboarding/welcome.webp` | WebP | 600×500 px (lossless) | Step 1: Welcome (Raster) | Optimized raster counterpart of welcome illustration. | "Illustration of glowing visual cards being preserved in an aperture frame" |
| `assets/onboarding/privacy.svg` | SVG | 600×500 (viewBox) | Step 2: Privacy | A geometric hardware boundary shield enclosing local media files with zero external connections or wires. | "Illustration of a protective digital vault shield securing personal photos" |
| `assets/onboarding/privacy.webp` | WebP | 600×500 px (lossless) | Step 2: Privacy (Raster) | Optimized raster counterpart of privacy illustration. | "Illustration of a protective digital vault shield securing personal photos" |
| `assets/onboarding/connect_folder.svg` | SVG | 600×500 (viewBox) | Step 3: Connect | Clean, neutral Android `DocumentsUI` folder tree pointing clearly to the system "Use this folder" action button. | "Illustration demonstrating Android's system file folder picker dialog" |
| `assets/onboarding/connect_folder.webp` | WebP | 600×500 px (lossless) | Step 3: Connect (Raster) | Optimized raster counterpart of connect folder illustration. | "Illustration demonstrating Android's system file folder picker dialog" |
| `assets/onboarding/ready.svg` | SVG | 600×500 (viewBox) | Step 4: Success | An animated radiant mint checkmark encircled by an aurora ring, indicating complete setup. | "Illustration of a bright checkmark confirming successful media folder connection" |
| `assets/onboarding/ready.webp` | WebP | 600×500 px (lossless) | Step 4: Success (Raster) | Optimized raster counterpart of ready illustration. | "Illustration of a bright checkmark confirming successful media folder connection" |

---

### 2.4 Empty State Illustrations (`assets/empty/`)

All empty state illustrations are paired with pre-rendered WebP counterparts.

| File Path | Format | Canonical Dimensions | Empty State Condition | Emotional Tone & Visual Content | Accessibility Description |
| :--- | :---: | :---: | :---: | :--- | :--- |
| `assets/empty/no_status.svg` | SVG | 500×450 (viewBox) | No Statuses in Inbox | A tranquil coffee cup on a quiet desk beside a glowing dawn window: peaceful stillness. Accompanied by text: *"Nothing here yet. Statuses appear here after you view them in WhatsApp."* | "Illustration of a peaceful morning desk representing no new statuses currently available" |
| `assets/empty/no_status.webp` | WebP | 500×450 px (lossless) | No Statuses in Inbox (Raster) | Optimized raster counterpart of no status illustration. | "Illustration of a peaceful morning desk representing no new statuses currently available" |
| `assets/empty/no_saved.svg` | SVG | 500×450 (viewBox) | No Saved Media in Kept | An open, pristine keepsake box with a gentle aurora glow waiting for its first treasured photo or video. Accompanied by: *"Nothing kept yet. Tap the Keep button on any moment to save it here forever."* | "Illustration of an open keepsake chest ready to store preserved moments" |
| `assets/empty/no_saved.webp` | WebP | 500×450 px (lossless) | No Saved Media in Kept (Raster) | Optimized raster counterpart of no saved illustration. | "Illustration of an open keepsake chest ready to store preserved moments" |
| `assets/empty/access_required.svg` | SVG | 500×450 (viewBox) | SAF Permission Revoked | A discrete geometric door with a keyhole emitting an emerald beacon. Accompanied by: *"Connect your media folder to discover moments."* | "Illustration of a safe door prompting user to authorize storage folder access" |
| `assets/empty/access_required.webp` | WebP | 500×450 px (lossless) | SAF Permission Revoked (Raster) | Optimized raster counterpart of access required illustration. | "Illustration of a safe door prompting user to authorize storage folder access" |

---

### 2.5 Utility & Micro-Feedback Illustrations (`assets/illustrations/`)

| File Path | Format | Canonical Dimensions | Usage Context | Description |
| :--- | :---: | :---: | :--- | :--- |
| `assets/illustrations/save_success.svg` | SVG | 300×300 (viewBox) | Instant Save Feedback Sheet | A luminous mint checkmark encircled by an expanding aurora pulse ring. |
| `assets/illustrations/save_success.webp` | WebP | 300×300 px (lossless) | Instant Save Feedback Sheet (Raster) | Optimized raster counterpart of save success pulse illustration. |
| `assets/illustrations/duplicate.svg` | SVG | 300×300 (viewBox) | Duplicate Shield Modal Sheet | Overlapping twin photo frames shielded by a protective vault badge, preventing duplicate saving. |
| `assets/illustrations/duplicate.webp` | WebP | 300×300 px (lossless) | Duplicate Shield Modal Sheet (Raster) | Optimized raster counterpart of duplicate shield illustration. |
| `assets/illustrations/privacy.svg` | SVG | 300×300 (viewBox) | Privacy Trust Details Sheet | A minimal microchip with an embedded lock symbol, representing 100% on-device sandboxed processing. |
| `assets/illustrations/privacy.webp` | WebP | 300×300 px (lossless) | Privacy Trust Details Sheet (Raster) | Optimized raster counterpart of privacy lock illustration. |

---

### 2.6 Google Play Store Assets (`assets/store/`)

| File Path | Format | Canonical Dimensions | Target Surface & Usage | Color Palette | Technical Specification |
| :--- | :---: | :---: | :--- | :--- | :--- |
| `assets/store/feature_graphic/feature_graphic.svg` | SVG | 1024×500 (viewBox) | Master vector Play Store promotional header banner. | `#090B0E`, `#10B981`, `#6366F1`, `#F9FAFB` | Vector layout with aperture mark, brand lockup, and tagline. |
| `assets/store/feature_graphic/feature_graphic.png` | PNG | 1024×500 px (24/32-bit) | Google Play Console Feature Graphic upload asset. | `#090B0E`, `#10B981`, `#6366F1`, `#F9FAFB` | Exact 1024×500 px Google Play store specification requirement. |
| `assets/store/feature_graphic/feature_graphic.webp` | WebP | 1024×500 px (lossless) | Lightweight web/store banner variant. | `#090B0E`, `#10B981`, `#6366F1`, `#F9FAFB` | Optimized WebP export under 150 KB. |
| `assets/store/screenshots/README.md` | MD | Text Specification | Store listing screenshot guidelines. | — | Device frames, resolutions, and copy guidelines for Play listing. |

---

## 3. Brand & Trademark Guidelines

1. **Clear Space:** The master logo mark requires a minimum clear space equivalent to 50% of its height (`0.5H`) on all four sides. No text or secondary graphic elements may enter this boundary.
2. **Minimum Sizing:**
   - Digital Screens: Minimum mark width 24dp (displays sharply down to 48px on standard 2× devices).
   - Wordmark: Minimum width 64dp.
3. **Misuse Prohibitions:**
   - Do NOT rotate or tilt the logo mark.
   - Do NOT replace the central spark with an emoji, icon, or heart.
   - Do NOT recolor the mark in garish neon greens (`#00FF00`) or corporate WhatsApp green (`#25D366`).
   - Do NOT place the dark lockup on low-contrast mid-grey surfaces.
4. **Brand Name Status:** "Keeva" is approved as the project's internal development and testing brand name. Formal legal trademark clearance and registration across target commercial jurisdictions remains a release milestone prior to public distribution.

