# Langy

Fix text typed with the wrong keyboard layout on macOS.

Langy is a lightweight menu-bar utility. It converts text in the focused field
in place: place the caret anywhere in a field to convert the whole field, or
select text to convert only that selection. If the first result is not right,
press the Switch hotkey again to try the next enabled layout.

Langy uses macOS Accessibility APIs to read and rewrite the focused text. It
does not use the clipboard.

## Features

- Global Switch hotkey, default `⇧⌥L`.
- Converts a whole field or the current selection.
- Tries enabled layouts in sequence and wraps around when it reaches the end.
- Reads installed system keyboard layouts live, with built-in and custom
  positional maps available as a fallback.
- Includes fallback maps for 50 languages.
- Runs from the menu bar and does not add an icon to the Dock.
- Shows status feedback for successful swaps, permission problems, and
  conversion failures.
- Provides settings for hotkeys, layout selection, menu-bar visibility, and
  launch on startup.

## Requirements

- macOS 13 or later.
- Accessibility permission for Langy.

On first launch, open System Settings → Privacy & Security → Accessibility and
allow Langy. Quit and reopen the app after changing the permission. Langy also
provides a **Quit & Reopen** action in Settings.

## Install

The installer downloads the latest release from [GitHub Releases](https://github.com/shandrodan/Langy/releases),
verifies its SHA-256 checksum, checks the archive contents and signature, and
installs `Langy.app` in `/Applications`.

Unauthenticated `curl` installation requires a public GitHub repository and
public release assets. It will not work for other people while this repository
is private.

Run it from Terminal:

```sh
curl --fail --location --silent --show-error \
  https://raw.githubusercontent.com/shandrodan/Langy/main/scripts/install.sh \
  | bash
```

To install a specific release, set its tag first:

```sh
export LANGY_RELEASE_TAG=v1.4
curl --fail --location --silent --show-error \
  https://raw.githubusercontent.com/shandrodan/Langy/main/scripts/install.sh \
  | bash
```

The distributed app is ad-hoc signed because it is not currently signed with a
Developer ID certificate or notarized. macOS may ask you to confirm the first
launch. Keep Gatekeeper, SIP, and other macOS security protections enabled.

## Use

1. Open Langy. It appears in the menu bar, not the Dock.
2. Place the caret in text typed with the wrong layout, or select the text you
   want to convert.
3. Press the Switch hotkey. By default, it is `⇧⌥L`.
4. If the result is not right, press the hotkey again to try the next enabled
   layout.

With no selection, Langy converts the whole focused field. With a selection, it
converts only that selection.

## Settings

Open Settings with the default `⌃⌘⌥L` hotkey, or use **Open Settings** from the
menu-bar menu.

- **Use system keyboard layouts** lists the layouts enabled in macOS and uses
  them as the source of truth. It is enabled by default.
- Turn that option off to manage Langy's built-in layouts and custom maps.
- Add a custom layout with a name and two equal-length rows: home characters and
  their mapped characters. Characters are paired by position.
- Use **Search layouts**, **Add**, and **Remove** to manage the list. Built-in
  layouts can be disabled but not deleted.
- **Show icon in menu bar** controls the menu-bar icon. Both global hotkeys
  continue to work when the icon is hidden.
- **Launch on startup** controls whether macOS opens Langy when you sign in.

To change a shortcut, choose **Rewrite Switch Hotkey** or **Rewrite Settings
Hotkey**, press the new combination, and select **Save**. **Use Default**
restores the original binding. Duplicate bindings and shortcuts already claimed
by macOS or another app are rejected without saving the change.

## Build and test from source

The Swift Package Manager helpers build a local app bundle without requiring
the release Xcode project:

```sh
./Scripts/build-app.sh
open Langy.app
```

Other useful development commands are:

```sh
swift run -c release
swift test
zsh Scripts/check-settings.sh
```

The settings checks do not require XCTest or the full Xcode application. Set
`LANGY_SNAPSHOT_DIR` to an existing directory if you also want light and dark
settings previews.

## Dependencies

Langy has no third-party package dependencies. It uses the macOS system
frameworks AppKit, Carbon, ServiceManagement, and ApplicationServices.

## Build a direct-distribution release

The release entry point is `Langy.xcodeproj` with the shared `Langy` scheme.
The pipeline builds a Release product with `xcodebuild`, validates the bundle,
ad-hoc signs it with `codesign --sign -`, packages it with `ditto`, and writes a
SHA-256 checksum.

From the repository root, run:

```sh
./scripts/build-release.sh
```

The generated files are:

```text
dist/Langy.zip
dist/Langy.zip.sha256
```

The release build targets macOS 13 or later and contains arm64 and x86_64
architectures. `dist/` and local build output are ignored by Git.

## Publish a GitHub release

Authenticate GitHub CLI once, if needed:

```sh
gh auth status
gh auth login -h github.com
```

After committing the source and release-pipeline changes, build the artifacts
and publish them with a new tag:

```sh
./scripts/build-release.sh
git tag v1.4
git push origin v1.4
gh release create v1.4 dist/Langy.zip dist/Langy.zip.sha256 \
  --title "Langy v1.4" --generate-notes
```

Use a new version tag for each release. Keep the asset names `Langy.zip` and
`Langy.zip.sha256`; the installer downloads those names from the latest
release.

## Project structure

```text
Langy.xcodeproj/              # command-line release project and shared scheme
Package.swift                 # Swift Package Manager development target
Resources/Info.plist          # bundle metadata
Resources/LangyIcon.svg       # source icon used by the release pipeline
Sources/Langy/                # application source
Tests/                        # XCTest and settings checks
Scripts/                      # existing development helpers
scripts/                      # release builder and installer
dist/                         # generated release artifacts (ignored)
```

## Troubleshooting

If the Switch hotkey reports that Accessibility is unavailable after you
enabled the permission, use **Quit & Reopen** in Settings. If that does not
help, remove Langy from System Settings → Privacy & Security → Accessibility,
open the app again, allow it, and quit and reopen it once more.

If two Langy entries appear in Accessibility, remove the entry for the copy you
no longer use. Keeping both a development copy and `/Applications/Langy.app`
can make macOS trust the wrong bundle.

For a failed swap, Langy records the target app and the write method it used.
View recent entries with:

```sh
log show --predicate 'process == "Langy"' --last 10m | grep Langy
```

## Privacy and permissions

Langy needs Accessibility permission to read and rewrite text in the focused
application. It does not use the clipboard for conversion. The app stores its
layout, shortcut, menu-bar, and startup preferences locally.

Made by [Dan Shandro](https://danshandro.com).
