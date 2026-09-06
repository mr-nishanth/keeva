# Nishvanta Labs Brand Assets

This directory contains the canonical vector source assets for the **Nishvanta Labs** company and creator identity.

---

## 1. Company Identity

- **Organization:** Nishvanta Labs
- **Tagline:** Technology You Can Trust.
- **Role:** Independent software and systems laboratory building privacy-first, high-performance developer and consumer technologies.
- **Design Metaphor:** Geometric Precision & Continuity

---

## 2. Brand Relationship

```text
Nishvanta Labs (Parent / Creator Identity)
    │
    └── Keeva (Consumer Product Identity)
```

The relationship communicates: **"Nishvanta Labs builds Keeva"** (not *"Keeva is a feature of Nishvanta Labs"*). Keeva remains the prominent consumer-facing identity in app stores, launchers, and device notifications. Nishvanta Labs provides organizational attribution in About screens, repository headers, technical documentation, and open-source registries.

---

## 3. Master Palette

| Color Name | Hex | Role |
| :--- | :--- | :--- |
| **Quiet Obsidian** | `#090B0E` | Deep background canvas and plate surface |
| **Aurora Indigo** | `#6366F1` | Primary monogram accent, precision gradient start |
| **Deep Cobalt** | `#4338CA` | Geometric foundation, precision gradient end |
| **Clean White** | `#FFFFFF` | Wordmark primary text, high-contrast marks |
| **Muted Slate** | `#9CA3AF` | Tagline text and technical annotations |
| **Aurora Mint** | `#10B981` | Forward beacon spark (accent linking to the Keeva ecosystem) |

---

## 4. Asset Index

| File | Type | ViewBox | Description |
| :--- | :--- | :--- | :--- |
| `logo-mark.svg` | SVG | 512×512 | Canonical company symbol: Squircle plate, geometric continuous "N" ribbon, and forward beacon. |
| `logo-mark-mono.svg` | SVG | 512×512 | Single-color dark monochrome silhouette (Dark `#090B0E` on transparent canvas). |
| `logo-mark-white.svg` | SVG | 512×512 | Single-color reversed silhouette (White `#FFFFFF` on transparent canvas). |
| `wordmark.svg` | SVG | 720×180 | Typographic wordmark `NISHVANTA LABS` with tagline *"Technology You Can Trust."* |
| `lockup-horizontal.svg` | SVG | 920×240 | Horizontal lockup (Symbol + Wordmark + Tagline). For website navigation, documentation headers, and reports. |
| `lockup-stacked.svg` | SVG | 440×540 | Centered stacked lockup. For documentation covers, organizational avatars, and square cards. |

---

## 5. Scaling & Clear Space Guidelines

- **Clear Space:** Maintain a minimum clear perimeter of `0.5H` around all company marks.
- **Minimum Display Sizes:**
  - `16px`: Minimum favicon/system tray size (use `logo-mark-mono.svg` or `logo-mark-white.svg` without container plate).
  - `24px`: Minimum mobile action icon / in-app brand mark.
  - `48px`: Standard company attribution badge.
  - `64px`: Standard hero header mark.
  - `512px`: Master vector source canvas.
- **Incorrect Usage:**
  - Never rotate, warp, or skew the geometric "N".
  - Never substitute generic shield, padlock, circuit-board, or AI brain imagery.
  - Never combine Keeva's aperture and the Nishvanta Labs monogram into a single merged hybrid glyph.
  - Never place the dark-plate logo on low-contrast mid-tone gray surfaces without verifying WCAG contrast.
