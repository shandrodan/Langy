#!/bin/zsh
# Build a light .app bundle from the SwiftPM release binary.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release

APP="Langy.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/Langy" "$APP/Contents/MacOS/Langy"
cp "Resources/Info.plist" "$APP/Contents/Info.plist"

# Ad-hoc sign so the system recognises the bundle (Privacy & Security approval
# sticks to this build instead of flapping on an unsigned binary).
codesign --force --deep --sign - "$APP"

# Optional icon placeholder (⌘ drawn at runtime, so no asset needed)
echo "Built $APP — copy it to /Applications to use. First launch asks for Accessibility permission."
echo "Enable: System Settings → Privacy & Security → Accessibility → Langy,"
echo "then quit and reopen Langy so the grant takes effect."
