# Keeva + Nishvanta Labs Brand Guidelines

Comprehensive visual identity, typography, color palette, and asset usage standards for **Keeva** and **Nishvanta Labs**.

---

## 1. Brand Hierarchy & Philosophy

```text
NISHVANTA LABS
Technology You Can Trust.
    │
    └── KEEVA
        Private, local-first Android application for viewing and saving WhatsApp status media.
```

### Brand Separation
- **Keeva** is the primary consumer-facing product identity. It represents an offline, calm, private media keeper.
- **Nishvanta Labs** is the parent engineering laboratory and creator brand. It represents engineering rigor, privacy-first system design, and technological trust.
- **Relationship Rule:** *"Nishvanta Labs builds Keeva"*, not *"Keeva is a feature of Nishvanta Labs"*. The product brand remains prominent in user-facing mobile interfaces, app stores, and notifications. Nishvanta Labs attribution appears thoughtfully in About screens, repository headers, and technical documentation.

---

## 2. Brand Personality & Design Language

| Attribute | Meaning in Keeva & Nishvanta Labs |
| :--- | :--- |
| **Trustworthy** | Transparent system interactions, zero telemetry, local-first on-device operations. |
| **Private** | No cloud sync, no tracking, strict directory isolation via Storage Access Framework (SAF). |
| **Modern & Technical** | Clean mathematical curves, 120Hz frame budget, pure vector rendering. |
| **Calm & Minimal** | Deep obsidian backgrounds, restrained neon/gradient usage, zero flashing badges. |
| **Premium** | Balanced typography, specular highlights, subtle 1px translucent borders. |

### Prohibited Visual Tropes (Anti-Patterns)
- **NO** generic AI imagery (no glowing brains, circuit lines, robotic arms, neural networks).
- **NO** generic security icons (no padlocks, security badges, keyholes, sheriff shields).
- **NO** WhatsApp trademark green (`#25D366`), chat bubbles, or phone icons.
- **NO** cryptocurrency-style gradients, isometric cubes, or Web3 visuals.
- **NO** childish or cartoonish app-store graphics.

---

## 3. The Keeva Logo System

The Keeva symbol is built upon the **Inward Aperture Ribbon** framing a luminous **Preserved Spark**.

### 3.1 Anatomical Elements
1. **Base Squircle Plate:** 448×448 container with 112px border radius, filled with deep obsidian gradient (`#181D26` → `#0E1117`) and a subtle 1px specular stroke.
2. **Inward Aperture Ribbon:** A continuous folding path curling inward with rounded terminals (`stroke-width: 32`), styled with the Aurora Mint to Indigo gradient (`#34D399` → `#10B981` → `#6366F1`).
3. **Secondary Memory Envelope Arc:** An offset protective curve (`stroke-width: 24`, `#6366F1` at 70% opacity) reinforcing the feeling of preservation.
4. **Preserved Spark:** An ambient emerald glow (`#10B981`, radius 44) centered on a gleaming beacon (`#FFFFFF`, radius 16) at coordinate `(280, 200)`.

### 3.2 Canonical Keeva Variants

| Variant | File Path | Format | Optimal Context |
| :--- | :--- | :--- | :--- |
| **Full Color Mark** | `assets/brand/keeva/logo-mark.svg` | SVG | Default product symbol, app stores, launcher icons |
| **Monochrome Dark** | `assets/brand/keeva/logo-mark-mono.svg` | SVG | Single-ink light paper printing, black-and-white docs |
| **Monochrome White** | `assets/brand/keeva/logo-mark-white.svg` | SVG | Android themed icons, dark watermark, high-contrast dark |
| **Wordmark** | `assets/brand/keeva/wordmark.svg` | SVG | Headers, web navigation bars, minimal footer credits |
| **Horizontal Lockup** | `assets/brand/keeva/lockup-horizontal.svg` | SVG | Documentation banners, website hero, press kits |
| **Stacked Lockup** | `assets/brand/keeva/lockup-stacked.svg` | SVG | Centered covers, splash screens, square social graphics |

---

## 4. The Nishvanta Labs Logo System

The Nishvanta Labs symbol is an architectural, continuous geometric **"N"** monogram representing trust, continuity, precision, and forward movement.

### 4.1 Anatomical Elements
1. **Pillars of Trust:** Two parallel vertical uprights anchored in stability and engineering reliability.
2. **Dynamic Continuity Bridge:** A continuous 45-degree diagonal bridging the left and right uprights without breaking.
3. **Forward Momentum Beacon:** A luminous spark accent (`#10B981` glow with `#FFFFFF` core) positioned at the forward terminal, linking Nishvanta Labs to the Aurora Mint of the Keeva ecosystem.

### 4.2 Canonical Nishvanta Labs Variants

| Variant | File Path | Format | Optimal Context |
| :--- | :--- | :--- | :--- |
| **Full Color Mark** | `assets/brand/nishvanta/logo-mark.svg` | SVG | Organization avatar, company headers, developer profiles |
| **Monochrome Dark** | `assets/brand/nishvanta/logo-mark-mono.svg` | SVG | Single-color light documentation, invoices, letters |
| **Monochrome White** | `assets/brand/nishvanta/logo-mark-white.svg` | SVG | Reversed white on dark backgrounds, CLI watermarks |
| **Wordmark** | `assets/brand/nishvanta/wordmark.svg` | SVG | Company headers, legal entity notices, GitHub footers |
| **Horizontal Lockup** | `assets/brand/nishvanta/lockup-horizontal.svg` | SVG | Corporate headers, press releases, reports |
| **Stacked Lockup** | `assets/brand/nishvanta/lockup-stacked.svg` | SVG | Developer organization profiles, square avatars |

---

## 5. Master Color Palettes

### 5.1 Keeva Product Palette

```text
QUIET OBSIDIAN         AURORA MINT            AURORA INDIGO          CLEAN WHITE
#090B0E                #10B981                #6366F1                #FFFFFF
Canvas Base            Primary CTA            Secondary Accent       Primary Text
```

| Token | Hex | RGB | Purpose | WCAG Contrast |
| :--- | :--- | :--- | :--- | :--- |
| `background` | `#090B0E` | `9, 11, 14` | Deep obsidian canvas; behind all screens | Base Canvas |
| `surfaceLevel1` | `#161A22` | `22, 26, 34` | Cards, list containers, squircle plate background | 1.6:1 vs Base |
| `primary` | `#10B981` | `16, 185, 129` | Aurora Mint; Keep button, active indicators | **8.4:1 vs Base (AAA)** |
| `accent` | `#6366F1` | `99, 102, 241` | Aurora Indigo; multi-selection ring, focus rings | **5.2:1 vs Base (AA)** |
| `textPrimary` | `#FFFFFF` | `255, 255, 255`| High-emphasis headlines and gleaming sparks | **21:1 vs Base (AAA)** |
| `textSecondary` | `#9CA3AF` | `156, 163, 175`| Subtitles, timestamps, technical annotations | **6.5:1 vs Base (AAA)** |

### 5.2 Nishvanta Labs Extended Palette

| Token | Hex | RGB | Purpose |
| :--- | :--- | :--- | :--- |
| `nlObsidian` | `#090B0E` | `9, 11, 14` | Company canvas background |
| `nlIndigo` | `#6366F1` | `99, 102, 241` | Monogram gradient start |
| `nlCobalt` | `#4338CA` | `67, 56, 202` | Monogram gradient end / foundation |
| `nlWhite` | `#FFFFFF` | `255, 255, 255`| Primary wordmark text |
| `nlMuted` | `#9CA3AF` | `156, 163, 175`| Tagline: "Technology You Can Trust." |
| `nlBeacon` | `#10B981` | `16, 185, 129` | Ecosystem linkage spark |

---

## 6. Typography

Keeva and Nishvanta Labs standardize on **Plus Jakarta Sans** (clean geometric sans-serif):

- **Headlines & Wordmarks:** `Plus Jakarta Sans Bold` (700 / 800) with `-1.5px` to `-2px` letter-spacing.
- **Company Wordmark (`NISHVANTA LABS`):** `Plus Jakarta Sans ExtraBold` (800) uppercase with `+5px` letter-spacing.
- **Taglines & Subtitles:** `Plus Jakarta Sans Medium` (500) or `SemiBold` (600).
- **Tabular Figures (`tnum`):** All numeric data (timestamps, durations, file sizes, counts) must use `FontFeature.tabularFigures()` for optical alignment.

---

## 7. Scaling, Minimum Sizing & Clear Space

### 7.1 Clear Space
Maintain a mandatory clear space perimeter equal to **0.5H** (half the height of the symbol) around all edges of both Keeva and Nishvanta Labs marks.

### 7.2 Minimum Digital Sizes
- `16 × 16 px`: Favicons, status bar icons (use monochrome silhouette).
- `24 × 24 px`: In-app navigation icons, list item trailing icons.
- `32 × 32 px`: Dialog badges, attribution marks.
- `48 × 48 px`: App bar branding, card headers.
- `64 × 64 px`: Onboarding hero badge.
- `128 × 128 px`: Dialog hero, feature banners.
- `512 × 512 px`: Play Store launcher icon, master asset canvas.

---

## 8. Incorrect Usage (Misuse Rules)

1. **Do NOT stretch or squish:** Always preserve the 1:1 aspect ratio of the symbols.
2. **Do NOT rotate:** Never display the aperture or geometric "N" tilted or inverted.
3. **Do NOT recolor arbitrarily:** Never apply unapproved colors (especially WhatsApp green `#25D366` or neon magenta).
4. **Do NOT add heavy raster drop shadows:** Use tonal elevation levels and 1px borders instead of blurred raster shadows.
5. **Do NOT alter geometry:** Never detach the central spark from the aperture ribbon or modify the stroke paths.
6. **Do NOT combine into a hybrid logo:** Never merge the Keeva aperture and the Nishvanta Labs monogram into a single hybrid icon.
7. **Do NOT place on low-contrast backgrounds:** Always ensure compliance with WCAG AAA contrast ratios.

---

## 9. Co-Branding & Attribution Standards

When Keeva and Nishvanta Labs appear together:

```text
[Keeva Mark]  Keeva •
              BUILT BY NISHVANTA LABS • Technology You Can Trust.
```

- **Prominence:** "Keeva" is always the hero wordmark.
- **Attribution:** "Built by Nishvanta Labs" appears beneath in medium weight with `+1px` tracking.
- **Placement:** About screen, GitHub repository headers, release notes, documentation footers, and official website footers.
