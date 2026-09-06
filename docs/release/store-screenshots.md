# Keeva Store Screenshot & Visual Asset Specification

**Product:** Keeva
**Developer:** Nishvanta Labs
**Target Platforms:** Google Play Store (Android) & Apple App Store (iOS)

---

## 1. Principles & Quality Guidelines

1. **Authenticity:** All store screenshots must represent real application layouts, authentic typography, and genuine UI screens rendered directly from production builds. Fake mockups, fabricated device chrome, and misleading features are strictly forbidden.
2. **Privacy Preservation:** Test media used in screenshot captures must consist solely of open-source, royalty-free creative commons imagery (nature, landscapes, architecture). No personally identifiable information (PII), phone numbers, or private chat media may be shown.
3. **Trademark Neutrality:** Screenshots must not display WhatsApp branding, trademarked logos, or green chat bubble iconography.

---

## 2. Google Play Store Visual Asset Requirements

### 2.1 App Icon
- **Dimensions:** 512 x 512 pixels
- **Format:** 32-bit PNG (with alpha)
- **Max File Size:** 1024 KB
- **Design:** Official Keeva gradient brand mark on dark surface (`assets/icon/app_icon_512.png`).

### 2.2 Feature Graphic (Mandatory for Play Store)
- **Dimensions:** 1024 x 500 pixels
- **Format:** JPEG or 24-bit PNG (no alpha)
- **Max File Size:** 15 MB
- **Design:** Centered Keeva wordmark and emblem on dark gradient backdrop (`assets/store/feature_graphic/feature_graphic.png`).

### 2.3 Phone Screenshots (Minimum 4, Recommended 6–8)
- **Minimum Dimensions:** 1080 x 1920 pixels (9:16 portrait) or 1080 x 2400 pixels (20:9 portrait).
- **Format:** 24-bit PNG or JPEG (no alpha).
- **Aspect Ratio:** 16:9 or 9:16 portrait orientation.
- **Minimum Upload Count:** 2 screenshots required; 6–8 recommended for conversion optimization.
- **Required Shot Sequence:**
  1. **Moments Tab:** Demonstrating active chronological status discovery cards, freshness tags, and clean grid.
  2. **Full-Screen Photo Inspection:** High-resolution zoom view with contextual bottom actions (Keep, Share).
  3. **Full-Screen Video Playback:** Immersive playback interface with timeline scrubber and pause controls.
  4. **Kept Vault:** Organized library of permanently saved media items with search and filter tabs.
  5. **Folder Access Consent:** Transparent Storage Access Framework explanation screen detailing privacy model.
  6. **Theme Customization:** Displaying Light, Dark, and AMOLED themes alongside privacy safeguards.

---

## 3. Apple App Store Visual Asset Requirements

### 3.1 App Store Icon
- **Dimensions:** 1024 x 1024 pixels
- **Format:** PNG (no transparency / alpha channel prohibited by Apple).
- **Color Profile:** sRGB or Display P3.
- **Source:** `assets/icon/keeva-icon-1024.png`.

### 3.2 iPhone Screenshots (Required Sizes)
Apple enforces specific resolution tiers based on physical display sizes:

| Display Size | Device Target | Required Resolution (Portrait) | Notes |
|---|---|---|---|
| **6.9" Display** | iPhone 16 Pro Max | **1320 x 2868 pixels** | Primary flagship display requirement |
| **6.7" / 6.5" Display** | iPhone 15 Pro Max / 14 Pro Max / 11 Pro Max | **1290 x 2796 pixels** or **1242 x 2688 pixels** | Standard modern iPhone format |
| **5.5" Display** | iPhone 8 Plus / 7 Plus / 6s Plus | **1242 x 2208 pixels** | Required if supporting legacy home-button form factors |

### 3.3 iPad Screenshots
- **Status:** **NOT REQUIRED / OMITTED**
- Keeva is configured as an iPhone-first mobile application. iPad-specific screenshots are not required unless an iPad-optimized layout target is enabled.

### 3.4 Screenshot Frame & Typography Specifications
- **Header Banners:** Crisp, concise proposition titles set in Plus Jakarta Sans SemiBold (e.g., *"Private by Design"*, *"Permanent Offline Vault"*, *"Immersive Media Viewer"*).
- **Localization:** Screenshot text must match the store listing locale (`en-US`).
