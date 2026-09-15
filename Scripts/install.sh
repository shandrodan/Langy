#!/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly REPOSITORY="${LANGY_REPOSITORY:-shandrodan/Langy}"
readonly RELEASE_TAG="${LANGY_RELEASE_TAG:-latest}"
readonly ZIP_NAME="${LANGY_ASSET_NAME:-Langy.zip}"
readonly CHECKSUM_NAME="${ZIP_NAME}.sha256"
readonly INSTALL_DIR="/Applications"
readonly INSTALL_PATH="${INSTALL_DIR}/Langy.app"

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

on_error() {
    local status=$?
    printf 'error: installation failed at line %s (status %s)\n' "${BASH_LINENO[0]}" "$status" >&2
    exit "$status"
}

trap on_error ERR

[[ "$(uname -s)" == "Darwin" ]] || die "this installer must run on macOS"
[[ "$REPOSITORY" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "invalid GitHub repository: $REPOSITORY"
[[ "$ZIP_NAME" != /* && "$ZIP_NAME" != */* && "$ZIP_NAME" != *..* ]] || die "invalid release asset name: $ZIP_NAME"
if [[ "$RELEASE_TAG" != "latest" ]]; then
    [[ "$RELEASE_TAG" =~ ^[A-Za-z0-9._/-]+$ ]] || die "invalid release tag: $RELEASE_TAG"
    case "$RELEASE_TAG" in
        /*|*/|*..*|*//*)
            die "invalid release tag: $RELEASE_TAG"
            ;;
    esac
fi

for command_name in curl shasum ditto codesign plutil unzip mktemp awk grep find; do
    command -v "$command_name" >/dev/null 2>&1 || die "required command not found: $command_name"
done

if [[ "$RELEASE_TAG" == "latest" ]]; then
    readonly RELEASE_BASE="https://github.com/${REPOSITORY}/releases/latest/download"
else
    readonly RELEASE_BASE="https://github.com/${REPOSITORY}/releases/download/${RELEASE_TAG}"
fi

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/langy-install.XXXXXXXX")"
cleanup() {
    rm -rf -- "$WORK_DIR"
}
trap cleanup EXIT

readonly ZIP_PATH="${WORK_DIR}/${ZIP_NAME}"
readonly CHECKSUM_PATH="${WORK_DIR}/${CHECKSUM_NAME}"
readonly ENTRY_LIST="${WORK_DIR}/entries.txt"
readonly EXTRACT_DIR="${WORK_DIR}/extracted"
readonly ZIP_URL="${RELEASE_BASE}/${ZIP_NAME}"
readonly CHECKSUM_URL="${RELEASE_BASE}/${CHECKSUM_NAME}"

printf '%s\n' "==> Downloading ${ZIP_NAME} from GitHub Releases"
curl --fail --location --silent --show-error --retry 3 --retry-delay 1 \
    --connect-timeout 15 --max-time 300 --proto '=https' --tlsv1.2 \
    --output "$ZIP_PATH" "$ZIP_URL"
curl --fail --location --silent --show-error --retry 3 --retry-delay 1 \
    --connect-timeout 15 --max-time 60 --proto '=https' --tlsv1.2 \
    --output "$CHECKSUM_PATH" "$CHECKSUM_URL"

printf '%s\n' '==> Verifying SHA-256 checksum'
EXPECTED_HASH="$(awk -v target="$ZIP_NAME" '
    {
        candidate = $2
        sub(/^\*/, "", candidate)
        if (candidate == target && length($1) == 64) {
            print tolower($1)
            exit
        }
    }
' "$CHECKSUM_PATH")"
[[ "$EXPECTED_HASH" =~ ^[0-9a-f]{64}$ ]] || die "checksum file does not contain a SHA-256 entry for ${ZIP_NAME}"
ACTUAL_HASH="$(shasum -a 256 "$ZIP_PATH" | awk '{print tolower($1)}')"
[[ "$ACTUAL_HASH" == "$EXPECTED_HASH" ]] || die "checksum mismatch for ${ZIP_NAME}"
printf '    checksum: %s\n' "$ACTUAL_HASH"

printf '%s\n' '==> Validating archive paths before extraction'
unzip -Z1 "$ZIP_PATH" > "$ENTRY_LIST"
while IFS= read -r entry || [[ -n "$entry" ]]; do
    [[ -n "$entry" ]] || continue
    case "$entry" in
        /*|../*|*/../*|..)
            die "unsafe path in release archive: $entry"
            ;;
    esac
    [[ "$entry" == *\\* ]] && die "backslash path in release archive: $entry"
done < "$ENTRY_LIST"

printf '%s\n' '==> Extracting the app with ditto'
mkdir -p "$EXTRACT_DIR"
ditto -x -k "$ZIP_PATH" "$EXTRACT_DIR"
readonly EXTRACTED_APP="${EXTRACT_DIR}/Langy.app"
[[ -d "$EXTRACTED_APP" && ! -L "$EXTRACTED_APP" ]] || die 'release archive did not contain a top-level Langy.app directory'
[[ -z "$(find "$EXTRACT_DIR" -type l -print -quit)" ]] || die 'release archive contains symlinks and was not installed'
[[ -x "$EXTRACTED_APP/Contents/MacOS/Langy" ]] || die 'extracted app executable is missing'
plutil -lint "$EXTRACTED_APP/Contents/Info.plist" >/dev/null
codesign --verify --deep --strict --verbose=2 "$EXTRACTED_APP"

printf '%s\n' '==> Installing Langy.app into /Applications'
if [[ -L "$INSTALL_PATH" ]]; then
    die '/Applications/Langy.app is a symlink; refusing to replace it'
fi
if [[ -e "$INSTALL_PATH" ]]; then
    printf '%s\n' '    replacing the existing /Applications/Langy.app'
fi

if [[ -w "$INSTALL_DIR" ]]; then
    rm -rf -- "$INSTALL_PATH"
    ditto --norsrc "$EXTRACTED_APP" "$INSTALL_PATH"
else
    printf '%s\n' '    administrator permission is required for /Applications'
    sudo rm -rf -- "$INSTALL_PATH"
    sudo ditto --norsrc "$EXTRACTED_APP" "$INSTALL_PATH"
fi

codesign --verify --deep --strict --verbose=2 "$INSTALL_PATH"
printf '%s\n' '==> Installation complete'
printf '    app: %s\n' "$INSTALL_PATH"
printf '%s\n' '    signing: ad-hoc (not Developer ID signed or notarized)'
printf '%s\n' '    macOS security protections were not disabled'
