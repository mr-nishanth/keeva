# Keeva & Nishvanta Labs Master Asset Catalog

This directory houses all canonical brand marks, launcher icons, store graphics, and vector illustrations for **Keeva** and **Nishvanta Labs**.

---

## Directory Hierarchy

```text
assets/
├── brand/
│   ├── keeva/                  # Canonical Keeva product visual identity
│   │   ├── logo-mark.svg       # Master 512×512 product mark
│   │   ├── logo-mark-mono.svg  # Single-color dark monochrome
│   │   ├── logo-mark-white.svg # Single-color reversed white
│   │   ├── wordmark.svg        # Typographic wordmark
│   │   ├── lockup-horizontal.svg # Horizontal lockup
│   │   ├── lockup-stacked.svg    # Stacked lockup
│   │   └── README.md           # Product brand manual
│   │
│   └── nishvanta/              # Canonical Nishvanta Labs company identity
│       ├── logo-mark.svg       # Master 512×512 geometric "N" monogram
│       ├── logo-mark-mono.svg  # Single-color dark monochrome
│       ├── logo-mark-white.svg # Single-color reversed white
│       ├── wordmark.svg        # Typographic wordmark & tagline
│       ├── lockup-horizontal.svg # Horizontal lockup
│       ├── lockup-stacked.svg    # Stacked lockup
│       └── README.md           # Organization brand manual
│
├── icon/                       # Canonical application icons
│   ├── keeva-icon-512.png      # 512×512 high-resolution icon
│   ├── keeva-icon-1024.png     # 1024×1024 master store & iOS icon
│   ├── adaptive_foreground.svg # Android adaptive icon foreground layer
│   └── adaptive_background.svg # Android adaptive icon background layer
│
├── store/                      # Play Store / distribution artwork
│   ├── feature_graphic/        # 1024×500 promotional banner
│   └── screenshots/            # Verified physical-device captures
│
├── onboarding/                 # First-run flow illustrations
├── illustrations/              # Scenario & success vector graphics
├── empty/                      # Empty state vectors and fallbacks
└── fonts/                      # Embedded Plus Jakarta Sans typeface
```

---

## Architectural Rules

1. **No Duplicate Assets:** Do not duplicate identical assets across unrelated folders.
2. **Canonical Sources:** Vector SVG files under `assets/brand/` serve as the ultimate source of truth.
3. **Android Isolation:** Android adaptive launcher drawables (`android/app/src/main/res/drawable/`) use pure VectorDrawables derived from the canonical 512×512 mark.
4. **Offline & Privacy:** All assets are bundled on-device. Zero external CDNs or network fetches are permitted.
