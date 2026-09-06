# Keeva Brand Assets

This directory contains the canonical vector source assets for the **Keeva** product brand.

---

## 1. Product Identity

- **Product:** Keeva
- **Tagline:** Keep the moments that matter.
- **Role:** Private, local-first Android application for viewing and saving WhatsApp status media.
- **Design Metaphor:** Quiet Obsidian Media Vault

---

## 2. Master Palette

| Color Name | Hex | Role |
| :--- | :--- | :--- |
| **Quiet Obsidian** | `#090B0E` | Deep background canvas and app surface base |
| **Aurora Mint** | `#10B981` | Primary signature accent, Keep button, glowing spark |
| **Aurora Indigo** | `#6366F1` | Secondary accent arc, focus rings, subtle selection |
| **Pure White** | `#FFFFFF` | Primary text, glowing beacon core, high-contrast marks |
| **Surface Obsidian** | `#161A22` | Cards, containers, squircle plate background |

---

## 3. Asset Index

| File | Type | ViewBox | Description |
| :--- | :--- | :--- | :--- |
| `logo-mark.svg` | SVG | 512×512 | Canonical product symbol with Quiet Obsidian plate, Inward Aperture Ribbon, and glowing spark. |
| `logo-mark-mono.svg` | SVG | 512×512 | Single-color monochrome silhouette (Dark `#090B0E` on transparent canvas). |
| `logo-mark-white.svg` | SVG | 512×512 | Single-color reversed silhouette (White `#FFFFFF` on transparent canvas). |
| `wordmark.svg` | SVG | 600×180 | Typographic wordmark set in Plus Jakarta Sans Bold with Aurora Mint accent spark. |
| `lockup-horizontal.svg` | SVG | 800×240 | Horizontal lockup (Symbol + Wordmark + Tagline). Ideal for website headers and documentation. |
| `lockup-stacked.svg` | SVG | 400×520 | Vertical stacked lockup. Ideal for splash screens, app covers, and square cards. |

---

## 4. Scaling & Clear Space Guidelines

- **Clear Space:** Maintain a minimum clear perimeter of `0.5H` (half the mark's height) around all brand marks. No adjacent text, borders, or graphics may encroach upon this buffer.
- **Minimum Display Sizes:**
  - `16px`: Minimum favicon/system tray size (use `logo-mark-mono.svg` or `logo-mark-white.svg` without plate).
  - `24px`: Minimum mobile action icon / in-app brand mark.
  - `48px`: Standard mobile app bar mark.
  - `64px`: Standard onboarding hero badge.
  - `128px`: Dialog / sheet hero header.
  - `512px`: Master store icon / vector source canvas.
- **Incorrect Usage:**
  - Never rotate, shear, or distort the mark.
  - Never alter the gradient stops or replace Aurora Mint with generic WhatsApp green (`#25D366`).
  - Never separate the glowing spark from the aperture curve.
  - Never place the dark-plate logo on low-contrast mid-tone gray surfaces without verifying WCAG contrast.
