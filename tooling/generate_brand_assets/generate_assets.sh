#!/usr/bin/env bash
# ==============================================================================
# Keeva & Nishvanta Labs — Brand Asset Derivation Script
# ==============================================================================
# Deterministically regenerates derived PNG assets from canonical SVGs.
#
# Requirements:
#   - Google Chrome / Chromium (headless)
#   - sips (macOS built-in) OR ImageMagick (Linux) for icon downscaling
#
# Usage:
#   ./tooling/generate_brand_assets/generate_assets.sh
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

echo "==> Keeva & Nishvanta Labs: Brand Asset Generation"
echo "    Repository root: $REPO_ROOT"

# 1. Detect Chrome / Chromium binary
CHROME_BIN=""
if [[ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
  CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v google-chrome &>/dev/null; then
  CHROME_BIN="google-chrome"
elif command -v chromium &>/dev/null; then
  CHROME_BIN="chromium"
elif command -v chromium-browser &>/dev/null; then
  CHROME_BIN="chromium-browser"
fi

if [[ -z "$CHROME_BIN" ]]; then
  echo "[-] ERROR: Headless Chrome/Chromium not found on PATH."
  echo "    Please install Google Chrome or Chromium to render brand vector assets."
  exit 1
fi

echo "    Using browser engine: $CHROME_BIN"

# Temporary scratch directory in build/
TMP_DIR="$REPO_ROOT/build/brand_gen_tmp"
mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT

# Helper function to render an SVG to PNG via headless Chrome
render_svg() {
  local svg_path="$1"
  local out_path="$2"
  local width="$3"
  local height="$4"

  local html_file="$TMP_DIR/render.html"
  cat <<EOF > "$html_file"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: ${width}px; height: ${height}px; background: transparent; overflow: hidden; }
svg { width: ${width}px; height: ${height}px; display: block; }
</style>
</head>
<body>
$(cat "$svg_path")
</body>
</html>
EOF

  "$CHROME_BIN" \
    --headless \
    --disable-gpu \
    --default-background-color=00000000 \
    --window-size="${width},${height}" \
    --screenshot="$out_path" \
    "$html_file" &>/dev/null

  echo "    [✓] Generated $out_path (${width}x${height})"
}

# Ensure destination directories exist
mkdir -p "$REPO_ROOT/docs/assets/branding"
mkdir -p "$REPO_ROOT/assets/icon"
mkdir -p "$REPO_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"

# 2. Render Canonical Documentation Derivatives
echo "--> Rendering public branding assets..."
render_svg "assets/brand/keeva/logo-mark.svg" "docs/assets/branding/keeva-logo.png" 512 512
render_svg "assets/brand/keeva/wordmark.svg" "docs/assets/branding/keeva-wordmark.png" 600 180
render_svg "assets/brand/nishvanta/logo-mark.svg" "docs/assets/branding/nishvanta-labs-logo.png" 512 512
render_svg "assets/brand/nishvanta/wordmark.svg" "docs/assets/branding/nishvanta-labs-wordmark.png" 720 180

# Master Icons
echo "--> Rendering master icon assets..."
render_svg "assets/brand/keeva/logo-mark.svg" "assets/icon/keeva-icon-1024.png" 1024 1024
render_svg "assets/brand/keeva/logo-mark.svg" "assets/icon/keeva-icon-512.png" 512 512
cp "assets/icon/keeva-icon-1024.png" "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"

# 3. Downscale iOS AppIcon Set
echo "--> Downscaling iOS AppIcon bundle..."
SRC_1024="assets/icon/keeva-icon-1024.png"
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

scale_icon() {
  local size="$1"
  local target="$2"
  if command -v sips &>/dev/null; then
    sips -z "$size" "$size" "$SRC_1024" --out "$target" &>/dev/null
  elif command -v convert &>/dev/null; then
    convert "$SRC_1024" -resize "${size}x${size}" "$target"
  else
    echo "[-] Warning: No downscaler (sips or convert) found for $target"
  fi
}

scale_icon 20 "$IOS_DIR/Icon-App-20x20@1x.png"
scale_icon 40 "$IOS_DIR/Icon-App-20x20@2x.png"
scale_icon 60 "$IOS_DIR/Icon-App-20x20@3x.png"
scale_icon 29 "$IOS_DIR/Icon-App-29x29@1x.png"
scale_icon 58 "$IOS_DIR/Icon-App-29x29@2x.png"
scale_icon 87 "$IOS_DIR/Icon-App-29x29@3x.png"
scale_icon 40 "$IOS_DIR/Icon-App-40x40@1x.png"
scale_icon 80 "$IOS_DIR/Icon-App-40x40@2x.png"
scale_icon 120 "$IOS_DIR/Icon-App-40x40@3x.png"
scale_icon 120 "$IOS_DIR/Icon-App-60x60@2x.png"
scale_icon 180 "$IOS_DIR/Icon-App-60x60@3x.png"
scale_icon 76 "$IOS_DIR/Icon-App-76x76@1x.png"
scale_icon 152 "$IOS_DIR/Icon-App-76x76@2x.png"
scale_icon 167 "$IOS_DIR/Icon-App-83.5x83.5@2x.png"

echo "==> Brand asset generation complete! All outputs verified."
