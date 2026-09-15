#!/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly PROJECT_FILE="${PROJECT_ROOT}/Langy.xcodeproj"
readonly SCHEME="Langy"
readonly CONFIGURATION="Release"
readonly DERIVED_DATA_PATH="${PROJECT_ROOT}/.build/xcode-release"
readonly DIST_DIR="${PROJECT_ROOT}/dist"
readonly ARCHIVE_NAME="Langy.zip"
readonly CHECKSUM_NAME="${ARCHIVE_NAME}.sha256"
readonly ARCHIVE_PATH="${DIST_DIR}/${ARCHIVE_NAME}"
readonly CHECKSUM_PATH="${DIST_DIR}/${CHECKSUM_NAME}"
readonly FORBIDDEN_PATH_PATTERN='/Users/|/opt/homebrew|/usr/local|/private/var/|/var/folders/|/Applications/Xcode\.app'

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

on_error() {
    local status=$?
    printf 'error: release build failed at line %s (status %s)\n' "${BASH_LINENO[0]}" "$status" >&2
    exit "$status"
}

trap on_error ERR

[[ "$(uname -s)" == "Darwin" ]] || die "this release pipeline must run on macOS"
[[ -d "$PROJECT_FILE" ]] || die "missing Xcode project: $PROJECT_FILE"
[[ -f "$PROJECT_ROOT/Resources/Info.plist" ]] || die "missing Resources/Info.plist"
[[ -f "$PROJECT_ROOT/Resources/LangyIcon.svg" ]] || die "missing Resources/LangyIcon.svg"

for command_name in xcode-select mktemp ditto qlmanage sips iconutil codesign plutil lipo otool shasum file strings grep sed find; do
    command -v "$command_name" >/dev/null 2>&1 || die "required command not found: $command_name"
done

if [[ -n "${DEVELOPER_DIR:-}" ]]; then
    SELECTED_DEVELOPER_DIR="$DEVELOPER_DIR"
elif [[ -x "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
    SELECTED_DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
else
    SELECTED_DEVELOPER_DIR="$(xcode-select -p 2>/dev/null || true)"
fi

[[ -n "$SELECTED_DEVELOPER_DIR" ]] || die "Xcode is not selected; set DEVELOPER_DIR to an Xcode Developer directory"
readonly XCODEBUILD="${SELECTED_DEVELOPER_DIR}/usr/bin/xcodebuild"
[[ -x "$XCODEBUILD" ]] || die "xcodebuild not found under $SELECTED_DEVELOPER_DIR"

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/langy-release.XXXXXXXX")"
cleanup() {
    rm -rf -- "$WORK_DIR"
}
trap cleanup EXIT

printf '%s\n' "==> Validating Xcode project and scheme"
"$XCODEBUILD" -list -project "$PROJECT_FILE" -json > "$WORK_DIR/project-list.json"
grep -q '"Langy"' "$WORK_DIR/project-list.json" || die "Langy scheme/target was not found in the Xcode project"

printf '%s\n' "==> Cleaning release-only derived data"
rm -rf -- "$DERIVED_DATA_PATH"
mkdir -p "$DIST_DIR"
rm -f -- "$ARCHIVE_PATH" "$CHECKSUM_PATH"

printf '%s\n' "==> Building $SCHEME ($CONFIGURATION) with xcodebuild"
"$XCODEBUILD" \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk macosx \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
    build

readonly BUILT_APP="${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}/Langy.app"
[[ -d "$BUILT_APP" ]] || die "xcodebuild completed without producing $BUILT_APP"
[[ -x "$BUILT_APP/Contents/MacOS/Langy" ]] || die "release executable is missing or not executable"
[[ -f "$BUILT_APP/Contents/Info.plist" ]] || die "release Info.plist is missing"

readonly STAGED_APP="${WORK_DIR}/Langy.app"
readonly ICONSET_DIR="${WORK_DIR}/Langy.iconset"
readonly ICON_PATH="${WORK_DIR}/Langy.icns"
readonly EXECUTABLE="${STAGED_APP}/Contents/MacOS/Langy"
readonly DEPENDENCY_LIST="${WORK_DIR}/dependencies.txt"
readonly BUILD_SETTINGS="${WORK_DIR}/build-settings.txt"
readonly SOURCE_ENTITLEMENTS="${WORK_DIR}/source-entitlements.plist"

printf '%s\n' "==> Staging the Xcode product outside the source checkout"
ditto --norsrc --noextattr --noqtn "$BUILT_APP" "$STAGED_APP"
mkdir -p "$STAGED_APP/Contents/Resources" "$ICONSET_DIR"

printf '%s\n' "==> Converting the bundled SVG icon to ICNS"
qlmanage -t -s 1024 -o "$ICONSET_DIR" "$PROJECT_ROOT/Resources/LangyIcon.svg" >/dev/null
[[ -f "$ICONSET_DIR/LangyIcon.svg.png" ]] || die "Quick Look did not produce a PNG thumbnail for LangyIcon.svg"
mv -- "$ICONSET_DIR/LangyIcon.svg.png" "$ICONSET_DIR/icon_512x512@2x.png"
sips -z 512 512 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 512 512 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 256 256 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 256 256 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 128 128 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 64 64 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 32 32 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 32 32 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 16 16 "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
iconutil --convert icns --output "$ICON_PATH" "$ICONSET_DIR"
[[ -f "$ICON_PATH" ]] || die "iconutil did not produce Langy.icns"
cp -- "$ICON_PATH" "$STAGED_APP/Contents/Resources/Langy.icns"

readonly PLIST_PATH="${STAGED_APP}/Contents/Info.plist"
readonly BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$PLIST_PATH")"
readonly PRODUCT_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$PLIST_PATH")"
readonly VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST_PATH")"
readonly BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST_PATH")"
readonly DEPLOYMENT_TARGET="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$PLIST_PATH")"

[[ "$PRODUCT_NAME" == "Langy" ]] || die "unexpected product name in Info.plist: $PRODUCT_NAME"
[[ "$BUNDLE_ID" == "com.danshandro.langy" ]] || die "unexpected bundle identifier: $BUNDLE_ID"
[[ -n "$VERSION" && -n "$BUILD_NUMBER" && -n "$DEPLOYMENT_TARGET" ]] || die "version/build/deployment metadata is incomplete"
plutil -lint "$PLIST_PATH" >/dev/null

printf '%s\n' "==> Auditing Release settings and bundle dependencies"
"$XCODEBUILD" -showBuildSettings \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" > "$BUILD_SETTINGS"
grep -q 'CONFIGURATION = Release' "$BUILD_SETTINGS" || die "build settings are not Release"
grep -q 'SWIFT_OPTIMIZATION_LEVEL = -O' "$BUILD_SETTINGS" || die "Release optimization is not enabled"
grep -q 'DEBUG_INFORMATION_FORMAT = none' "$BUILD_SETTINGS" || die "debug information is enabled in Release settings"
if grep -E -q 'SWIFT_ACTIVE_COMPILATION_CONDITIONS = .*DEBUG|GCC_PREPROCESSOR_DEFINITIONS = .*DEBUG' "$BUILD_SETTINGS"; then
    die "debug compilation conditions were found in Release settings"
fi

ARCHS="$(lipo -archs "$EXECUTABLE")"
printf '    architectures: %s\n' "$ARCHS"
[[ " $ARCHS " == *" arm64 "* ]] || die "arm64 slice is missing"
[[ " $ARCHS " == *" x86_64 "* ]] || die "x86_64 slice is missing"

# A universal binary has one header per architecture. Select only indented
# dependency lines so a second architecture header cannot be misread as a
# library path.
otool -L "$EXECUTABLE" | sed -E -n 's/^[[:space:]]+(\/[^[:space:]]+|@[^[:space:]]+).*/\1/p' > "$DEPENDENCY_LIST"
while IFS= read -r dependency; do
    [[ -n "$dependency" ]] || continue
    case "$dependency" in
        /System/Library/*|/usr/lib/*|@rpath/*|@loader_path/*|@executable_path/*)
            ;;
        *)
            die "non-system or non-bundled dynamic dependency: $dependency"
            ;;
    esac
done < "$DEPENDENCY_LIST"
if grep -E -q "$FORBIDDEN_PATH_PATTERN" "$DEPENDENCY_LIST"; then
    die "machine-specific dynamic library path found"
fi
if strings -a "$EXECUTABLE" | grep -E "$FORBIDDEN_PATH_PATTERN" >/dev/null; then
    die "machine-specific absolute path found in the release executable"
fi
if grep -R -a -E -q "$FORBIDDEN_PATH_PATTERN" "$STAGED_APP"; then
    die "machine-specific absolute path found in the app bundle"
fi

if [[ -d "$STAGED_APP/Contents/Frameworks" ]]; then
    printf '%s\n' '    embedded frameworks/libraries:'
    find "$STAGED_APP/Contents/Frameworks" -mindepth 1 -maxdepth 2 -print
else
    printf '%s\n' '    embedded frameworks/libraries: none'
fi

printf '%s\n' "==> Preserving any existing Release entitlements"
set +e
if codesign -d --entitlements :- "$BUILT_APP" > "$SOURCE_ENTITLEMENTS" 2>/dev/null; then
    ENTITLEMENTS_STATUS=0
else
    ENTITLEMENTS_STATUS=$?
fi
set -e
SIGN_ARGS=()
if [[ "$ENTITLEMENTS_STATUS" -eq 0 ]] && grep -q '<dict' "$SOURCE_ENTITLEMENTS"; then
    plutil -lint "$SOURCE_ENTITLEMENTS" >/dev/null || die "Release entitlements are not valid plist data"
    SIGN_ARGS=(--entitlements "$SOURCE_ENTITLEMENTS")
    printf '%s\n' '    entitlements: preserved from Xcode product'
else
    printf '%s\n' '    entitlements: none embedded in the unsigned Release product'
fi

printf '%s\n' "==> Ad-hoc signing the final app"
if [[ "${#SIGN_ARGS[@]}" -gt 0 ]]; then
    codesign --force --deep --sign - "${SIGN_ARGS[@]}" "$STAGED_APP"
else
    codesign --force --deep --sign - "$STAGED_APP"
fi
codesign --verify --deep --strict --verbose=2 "$STAGED_APP"

if codesign -d --entitlements :- "$STAGED_APP" 2>&1 | grep -F 'com.apple.security.get-task-allow' >/dev/null; then
    die "debug get-task-allow entitlement is present in the final app"
fi

printf '%s\n' "==> Packaging with ditto"
(
    cd "$DIST_DIR"
    ditto -c -k --sequesterRsrc --keepParent "$STAGED_APP" "$ARCHIVE_NAME"
    shasum -a 256 "$ARCHIVE_NAME" > "$CHECKSUM_NAME"
)

[[ -s "$ARCHIVE_PATH" ]] || die "ZIP was not created"
[[ -s "$CHECKSUM_PATH" ]] || die "SHA-256 checksum was not created"
(
    cd "$DIST_DIR"
    shasum -a 256 -c "$CHECKSUM_NAME"
)
unzip -Z1 "$ARCHIVE_PATH" | grep -Fx 'Langy.app/Contents/MacOS/Langy' >/dev/null || die "ZIP does not contain the expected app bundle"

printf '%s\n' "==> Verifying the packaged ZIP"
readonly VERIFY_DIR="${WORK_DIR}/unpacked"
mkdir -p "$VERIFY_DIR"
ditto -x -k "$ARCHIVE_PATH" "$VERIFY_DIR"
codesign --verify --deep --strict --verbose=2 "$VERIFY_DIR/Langy.app"
[[ "$(lipo -archs "$VERIFY_DIR/Langy.app/Contents/MacOS/Langy")" == *"arm64"* ]] || die "packaged arm64 slice is missing"
[[ "$(lipo -archs "$VERIFY_DIR/Langy.app/Contents/MacOS/Langy")" == *"x86_64"* ]] || die "packaged x86_64 slice is missing"

printf '%s\n' '==> Release complete'
printf '    product: %s\n' "$PRODUCT_NAME"
printf '    bundle identifier: %s\n' "$BUNDLE_ID"
printf '    version/build: %s (%s)\n' "$VERSION" "$BUILD_NUMBER"
printf '    minimum macOS: %s\n' "$DEPLOYMENT_TARGET"
printf '    ZIP: %s\n' "$ARCHIVE_PATH"
printf '    SHA-256: %s\n' "$CHECKSUM_PATH"
