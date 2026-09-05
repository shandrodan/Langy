# Langy — light layout fixer for macOS

Typed a sentence in the wrong keyboard layout? Just press **⇧⌥L** — no need to
select anything. Langy converts the whole field in place (or just the selection
if you made one) and swaps it back. Press again to step to the next layout —
every enabled layout gets its turn, wrapping around. Works from and to any
layout you have enabled in settings or add as custom. The clipboard is never
touched; everything happens through the Accessibility API. If an app accepts
the direct swap but never commits it (some Electron editors with
framework-controlled inputs do), Langy verifies the write and retypes the text
through the key pipeline instead — still no clipboard. Selection state is
polled, not assumed: async apps (Electron) that apply selection a beat later
no longer cost an extra press.

- Event-driven, no polling: global hotkeys + `LSUIElement` (no Dock icon), ~zero idle CPU.
- Ships positional maps for **50 European languages** as fallback; with system layouts ON (default) only your installed keyboards are listed and used — whatever you have enabled is read live and takes precedence.
- **⌃⌘⌥L** opens native Liquid Glass settings: use-system toggle, searchable per-layout on/off list, add/remove extra maps, menu-bar visibility, launch on startup, quit completely. Turn off system layouts to manage built-in and custom layouts.
- Menu-bar `⌘`: white when idle, green for 0.6s on launch and on each fix; fades green the moment a fix starts and fades out the instant the text lands, mirroring the operation. Orange = Accessibility missing, red = couldn't convert. Hide it with **Show icon in menu bar**; both global shortcuts still work, and the choice is remembered across launches. No center-screen popups, no sounds.
- Footer: *made by dan* → [danshandro.com](https://danshandro.com).

## Build (no full Xcode needed)

```sh
./Scripts/build-app.sh
open Langy.app
```

Or run in place: `swift run -c release`.

Run native settings regression checks with `zsh Scripts/check-settings.sh`.
Optionally set `LANGY_SNAPSHOT_DIR` to an existing directory to export light/dark
settings previews. These checks do not require XCTest or full Xcode.

First launch: System Settings → Privacy & Security → Accessibility → allow **Langy**,
then **quit and reopen Langy** (macOS only trusts a fresh launch after the switch is flipped).
Settings shows the permission status and has *Quit & Reopen* for exactly this.

## Troubleshooting permission

- *Switch is ON but ⇧⌥L still complains?* You enabled it while Langy was running. Press *Quit & Reopen* in settings (or quit from the menu-bar icon and start again).
- *Still not trusted?* In Accessibility select the Langy entry, press **–** to remove it, re-open Langy, allow again, then quit & reopen.
- *Two Langy entries?* You have two copies (e.g. project folder + /Applications). Keep one in /Applications and remove the other entry.
- *Updated/rebuilt the app?* Each build looks like a new app to the system — remove the old entry and re-allow.

## Reporting a broken app

Langy logs every swap attempt (target app, which write method landed). After a
failure, run this and send the lines:

```sh
log show --predicate 'process == "Langy"' --last 10m | grep Langy
```

## Use

1. Type with the wrong layout active — caret anywhere in the field, nothing selected.
2. Press **⇧⌥L** → the whole field is swapped in place (menu-bar `⌘` glows green while it works, then fades).
   With text selected, only the selection is converted.
3. Not it? Press **⇧⌥L** again → next layout, and so on, wrapping around.

## Extra layouts

Settings → turn off *Use system keyboard layouts* → *Add*: give a name plus two equal-length rows
(home chars → mapped chars, position by position). Stored locally, converted
to and from like the rest.

Select a custom layout and click *Remove* to delete it. Built-in layouts can be
disabled, but not deleted. The **?** button in Settings explains both shortcuts.
If the menu-bar icon is hidden and the settings shortcut is unavailable, open
Langy again from Finder or Spotlight to return to Settings.
