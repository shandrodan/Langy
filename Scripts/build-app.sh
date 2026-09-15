#!/bin/zsh
# Build a light .app bundle from the SwiftPM release binary.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release

APP="Langy.app"
ICONSET=".build/Langy.iconset"
ICON=".build/Langy.icns"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# Render the vector mark at every size macOS uses for Finder and Launchpad.
rm -rf "$ICONSET" "$ICON"
mkdir -p "$ICONSET"
qlmanage -t -s 1024 -o "$ICONSET" "Resources/LangyIcon.svg" >/dev/null
mv "$ICONSET/LangyIcon.svg.png" "$ICONSET/icon_512x512@2x.png"
sips -z 512 512 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_512x512.png" >/dev/null
sips -z 512 512 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 256 256 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_256x256.png" >/dev/null
sips -z 256 256 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 128 128 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_128x128.png" >/dev/null
sips -z 64 64 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
sips -z 32 32 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_32x32.png" >/dev/null
sips -z 32 32 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
sips -z 16 16 "$ICONSET/icon_512x512@2x.png" --out "$ICONSET/icon_16x16.png" >/dev/null
iconutil --convert icns --output "$ICON" "$ICONSET"

cp ".build/release/Langy" "$APP/Contents/MacOS/Langy"
cp "Resources/Info.plist" "$APP/Contents/Info.plist"
cp "$ICON" "$APP/Contents/Resources/Langy.icns"

# Ad-hoc sign so the system recognises the bundle (Privacy & Security approval
# sticks to this build instead of flapping on an unsigned binary).
codesign --force --deep --sign - "$APP"

# Optional icon placeholder (⌘ drawn at runtime, so no asset needed)
echo "Built $APP — copy it to /Applications to use. First launch asks for Accessibility permission."
echo "Enable: System Settings → Privacy & Security → Accessibility → Langy,"
echo "then quit and reopen Langy so the grant takes effect."
