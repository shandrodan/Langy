#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
CHECK_DIR="$(mktemp -d "${TMPDIR:-/tmp/}langy-checks.XXXXXX")"
trap 'rm -rf "$CHECK_DIR"' EXIT
sources=("$ROOT"/Sources/Langy/*.swift)
sources=("${(@)sources:#*/main.swift}")

swiftc -module-name LangySettingsChecks "${sources[@]}" "$ROOT/Tests/SettingsChecks.swift" -o "$CHECK_DIR/check-settings"
"$CHECK_DIR/check-settings"
