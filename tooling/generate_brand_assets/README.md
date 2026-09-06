# Brand Asset Generation Tooling

Deterministic derivation script to regenerate public PNG derivatives and icon assets from canonical SVG vectors.

## Overview

This directory contains `generate_assets.sh`, an offline, deterministic asset derivation script.

```text
CANONICAL SOURCE
├── assets/brand/keeva/*.svg
└── assets/brand/nishvanta/*.svg
         │
         ├── [generate_assets.sh] (Headless Chrome / Chromium)
         ↓
DERIVED OUTPUTS
├── docs/assets/branding/
│   ├── keeva-logo.png (512×512)
│   ├── keeva-wordmark.png (600×180)
│   ├── nishvanta-labs-logo.png (512×512)
│   └── nishvanta-labs-wordmark.png (720×180)
├── assets/icon/
│   ├── keeva-icon-1024.png (1024×1024)
│   └── keeva-icon-512.png (512×512)
└── ios/Runner/Assets.xcassets/AppIcon.appiconset/
    ├── Icon-App-1024x1024@1x.png (1024×1024)
    └── [All scaled raster variants: 20px, 29px, 40px, 60px, 76px, 83.5px]
```

## Requirements

1. **Google Chrome** or **Chromium** (for headless SVG-to-PNG rendering with CSS gradient & filter fidelity).
2. **sips** (standard macOS utility) OR **ImageMagick** `convert` (Linux) for high-fidelity raster downscaling.

## Usage

From the repository root:

```bash
./tooling/generate_brand_assets/generate_assets.sh
```

## Design Principles

- **Repository-Relative Paths**: No absolute machine paths, user names, or environment-specific locations.
- **Zero Network Access**: Completely offline execution.
- **Deterministic Output**: Bit-for-bit reproducible image geometry and dimensions.
- **Privacy Guaranteed**: Zero EXIF metadata, timestamps, author tags, or machine hostnames retained.
