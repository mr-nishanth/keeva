# Keeva & Nishvanta Labs Brand Asset Inventory

Comprehensive registry of all visual brand assets across source repositories, Android native layers, iOS bundles, Flutter application widgets, and public documentation.

---

## 1. Asset Source-of-Truth Hierarchy

```text
SOURCE
  ↓
Canonical Vector Master (SVG)
  ├── assets/brand/keeva/*.svg
  └── assets/brand/nishvanta/*.svg
  ↓
Platform Native Implementations
  ├── Android: VectorDrawable (XML)
  └── Flutter: Pure Vector CustomPainter (KeevaLogo)
  ↓
Derived Raster & Documentation Deliverables
  ├── Public Documentation: docs/assets/branding/*.png
  ├── Store & App Icons: assets/icon/*.png
  └── iOS App Bundle: ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png
```

Generated PNG files are **never** treated as canonical design masters. Every raster image is deterministically derived from canonical SVGs via the repository-relative script in `tooling/generate_brand_assets/generate_assets.sh`.

---

## 2. Canonical Vector Assets (`assets/brand/`)

| Asset Path | Canvas / ViewBox | Role | Description / Construct | Status |
| :--- | :--- | :--- | :--- | :--- |
| `assets/brand/keeva/logo-mark.svg` | 512×512 | **Canonical Master** | Full-color mark with Quiet Obsidian squircle (`#181D26` → `#0E1117`), Aurora Mint to Indigo aperture ribbon (`#34D399` → `#10B981` → `#6366F1`), and preserved spark beacon (`#A7F3D0` glow, `#FFFFFF` core). | **Verified Canonical** |
| `assets/brand/keeva/logo-mark-mono.svg` | 512×512 | Derived Master | Single-ink dark monochrome mark (`#090B0E`) for light-paper printing, invoices, and monochrome documents. | **Verified Canonical** |
| `assets/brand/keeva/logo-mark-white.svg` | 512×512 | Derived Master | Reversed white monochrome mark (`#FFFFFF`) for dark watermarks, contrast overlays, and themed icon layers. | **Verified Canonical** |
| `assets/brand/keeva/wordmark.svg` | 600×180 | **Canonical Master** | Typographic wordmark ("Keeva") with specular gradient and mint accent dot (`#10B981`). | **Verified Canonical** |
| `assets/brand/keeva/lockup-horizontal.svg` | 800×240 | **Canonical Master** | Horizontal master lockup combining the 180×180 mark container with typography. | **Verified Canonical** |
| `assets/brand/keeva/lockup-stacked.svg` | 400×520 | **Canonical Master** | Vertically stacked centered lockup with 240×240 mark container over centered typography. | **Verified Canonical** |
| `assets/brand/nishvanta/logo-mark.svg` | 512×512 | **Canonical Master** | Full-color geometric "N" monogram in indigo to deep cobalt (`#818CF8` → `#6366F1` → `#4338CA`) with forward momentum beacon (`#10B981` / `#FFFFFF`). | **Verified Canonical** |
| `assets/brand/nishvanta/logo-mark-mono.svg` | 512×512 | Derived Master | Single-ink dark monochrome mark (`#090B0E`) for light documents. | **Verified Canonical** |
| `assets/brand/nishvanta/logo-mark-white.svg` | 512×512 | Derived Master | Reversed white monochrome mark (`#FFFFFF`) for CLI watermarks and dark mode backgrounds. | **Verified Canonical** |
| `assets/brand/nishvanta/wordmark.svg` | 720×180 | **Canonical Master** | Organization wordmark ("NISHVANTA LABS") and official tagline ("Technology You Can Trust."). | **Verified Canonical** |
| `assets/brand/nishvanta/lockup-horizontal.svg`| 920×240 | **Canonical Master** | Horizontal corporate lockup for releases, documentation headers, and press materials. | **Verified Canonical** |
| `assets/brand/nishvanta/lockup-stacked.svg` | 440×540 | **Canonical Master** | Vertically stacked corporate lockup for square avatars and organization covers. | **Verified Canonical** |

---

## 3. Public Documentation & Derived PNG Assets

Every PNG listed below maps directly to a canonical vector source and is validated for exact pixel dimensions and zero personal metadata.

| File Path | Dimensions | Canonical Source SVG | Derivation Method | Role |
| :--- | :--- | :--- | :--- | :--- |
| `docs/assets/branding/keeva-logo.png` | 512×512 | `assets/brand/keeva/logo-mark.svg` | Headless Chrome render (512×512) | GitHub README product avatar |
| `docs/assets/branding/keeva-wordmark.png` | 600×180 | `assets/brand/keeva/wordmark.svg` | Headless Chrome render (600×180) | GitHub README product title |
| `docs/assets/branding/nishvanta-labs-logo.png` | 512×512 | `assets/brand/nishvanta/logo-mark.svg` | Headless Chrome render (512×512) | Organization avatar / profile |
| `docs/assets/branding/nishvanta-labs-wordmark.png` | 720×180 | `assets/brand/nishvanta/wordmark.svg` | Headless Chrome render (720×180) | Organization header banner |
| `docs/assets/branding/keeva-nishvanta-lockup.png` | 960×260 | `assets/brand/keeva/logo-mark.svg` + `assets/brand/nishvanta/wordmark.svg` | Composite vector render | Universal co-brand hero header |
| `docs/assets/branding/keeva-github-social-preview.png` | 1280×640 | `assets/brand/keeva/logo-mark.svg` + `assets/brand/nishvanta/logo-mark.svg` | OpenGraph layout vector render | GitHub social preview card |
| `assets/icon/keeva-icon-1024.png` | 1024×1024 | `assets/brand/keeva/logo-mark.svg` | Headless Chrome render (1024×1024) | High-resolution master icon |
| `assets/icon/keeva-icon-512.png` | 512×512 | `assets/brand/keeva/logo-mark.svg` | Headless Chrome render (512×512) | Play Store raster asset |
| `assets/icon/app_icon_512.png` | 512×512 | `assets/brand/keeva/logo-mark.svg` | Headless Chrome render (512×512) | Play Store raster fallback |
| `assets/icon/app_icon_round_512.png` | 512×512 | `assets/brand/keeva/logo-mark.svg` | Masked round render (512×512) | Legacy round launcher asset |

---

## 4. Native Android Launcher & Splash Assets

Android implementation strictly avoids fragile AAPT2 inline gradients, utilizing pure solid and alpha `VectorDrawable` layers matching modern Android Adaptive Icon standards.

| File Path | Format | Canvas / Safe Zone | Implementation Detail | Status |
| :--- | :--- | :--- | :--- | :--- |
| `android/app/src/main/res/drawable/ic_launcher_background.xml` | VectorDrawable | 108×108dp | Solid `#090B0E` (Quiet Obsidian) background plate | **Verified Safe** |
| `android/app/src/main/res/drawable/ic_launcher_foreground.xml` | VectorDrawable | 108×108dp (66dp safe zone) | Pure vector aperture ribbon and spark halo, centered | **Verified Safe** |
| `android/app/src/main/res/drawable/ic_launcher_monochrome.xml` | VectorDrawable | 108×108dp (66dp safe zone) | Tintable white silhouette (`#FFFFFF`) for Android 13+ Themed Icons | **Verified Safe** |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | Adaptive XML | AnyDPI | Connects background, foreground, and monochrome vectors | **Active** |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` | Adaptive XML | AnyDPI | Round adaptive launcher resource | **Active** |
| `android/app/src/main/res/drawable/splash_icon.xml` | VectorDrawable | 160×160dp | Centered vector aperture icon for Android 12+ SplashScreen API | **Verified Zero-Flash** |
| `android/app/src/main/res/drawable/launch_background.xml` | LayerList | AnyDPI | Layer list with `#090B0E` and `@drawable/splash_icon` for pre-Android 12 | **Verified Zero-Flash** |

---

## 5. Flutter Presentation Components

| Component | Source Path | Implementation Method | Relationship to Canonical Source |
| :--- | :--- | :--- | :--- |
| `KeevaLogo` | `lib/presentation/common/brand/keeva_logo.dart` | Flutter `CustomPainter` vector drawing | **1:1 Mathematical Parity:** Identical cubic Béziers, radii, stroke widths, and gradient stops as `assets/brand/keeva/logo-mark.svg`. Zero external SVG runtime dependencies. |
| Settings Attribution | `lib/presentation/settings/settings_screen.dart` | Native Text widgets | Subtly displays "Built by Nishvanta Labs" and "Technology You Can Trust." in About Keeva card. |

---

## 6. iOS AppIcon Bundle

All iOS raster icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` are deterministically downscaled from the canonical 1024×1024 Keeva master icon (`assets/icon/keeva-icon-1024.png`):

| File Name | Intended Size | Density | Actual Pixels | Source Asset |
| :--- | :--- | :--- | :--- | :--- |
| `Icon-App-1024x1024@1x.png` | 1024×1024 | 1x | 1024×1024 | `assets/icon/keeva-icon-1024.png` |
| `Icon-App-20x20@1x.png` | 20×20 | 1x | 20×20 | Derived via sips |
| `Icon-App-20x20@2x.png` | 20×20 | 2x | 40×40 | Derived via sips |
| `Icon-App-20x20@3x.png` | 20×20 | 3x | 60×60 | Derived via sips |
| `Icon-App-29x29@1x.png` | 29×29 | 1x | 29×29 | Derived via sips |
| `Icon-App-29x29@2x.png` | 29×29 | 2x | 58×58 | Derived via sips |
| `Icon-App-29x29@3x.png` | 29×29 | 3x | 87×87 | Derived via sips |
| `Icon-App-40x40@1x.png` | 40×40 | 1x | 40×40 | Derived via sips |
| `Icon-App-40x40@2x.png` | 40×40 | 2x | 80×80 | Derived via sips |
| `Icon-App-40x40@3x.png` | 40×40 | 3x | 120×120 | Derived via sips |
| `Icon-App-60x60@2x.png` | 60×60 | 2x | 120×120 | Derived via sips |
| `Icon-App-60x60@3x.png` | 60×60 | 3x | 180×180 | Derived via sips |
| `Icon-App-76x76@1x.png` | 76×76 | 1x | 76×76 | Derived via sips |
| `Icon-App-76x76@2x.png` | 76×76 | 2x | 152×152 | Derived via sips |
| `Icon-App-83.5x83.5@2x.png` | 83.5×83.5 | 2x | 167×167 | Derived via sips |

---

## 7. Derivation Script & Reproducibility

Derived assets are generated using:

```bash
./tooling/generate_brand_assets/generate_assets.sh
```

- **Environment-Agnostic**: Contains zero local username or absolute machine paths.
- **Offline**: Zero network dependencies.
- **Sanitized**: Zero EXIF metadata, timestamps, or toolchain identifiers retained.
