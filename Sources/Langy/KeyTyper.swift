import AppKit

/// Types text through the key pipeline (layout-independent unicode events).
/// Used only when an app accepts an Accessibility write but never commits it
/// (framework-controlled inputs, e.g. Electron editors). Never touches the
/// clipboard — this is keystroke injection, not copy/paste.
enum KeyTyper {
    /// Deletes the current selection (or char before caret) in the focused app.
    static func deleteBackward() {
        keyPress(keyCode: 51, flags: []) // kVK_Delete
    }

    /// Select-all in the focused app. Plain key event, no clipboard involved.
    static func selectAll() {
        keyPress(keyCode: 0, flags: .maskCommand) // ⌘A
    }

    /// Types exact characters regardless of the active keyboard layout.
    static func typeText(_ text: String) {
        guard !text.isEmpty,
              let src = CGEventSource(stateID: .hidSystemState) else { return }
        let units = Array(text.utf16)
        var i = 0
        while i < units.count {
            let n = min(200, units.count - i)
            if let down = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: true) {
                units[i ..< (i + n)].withUnsafeBufferPointer { buf in
                    if let base = buf.baseAddress {
                        down.keyboardSetUnicodeString(stringLength: n, unicodeString: base)
                    }
                }
                down.post(tap: .cghidEventTap)
            }
            CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: false)?
                .post(tap: .cghidEventTap)
            i += n
            if i < units.count { usleep(5_000) }
        }
    }

    private static func keyPress(keyCode: CGKeyCode, flags: CGEventFlags) {
        guard let src = CGEventSource(stateID: .hidSystemState) else { return }
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        down?.flags = flags
        up?.flags = flags
        down?.post(tap: .cghidEventTap)
        usleep(25_000)
        up?.post(tap: .cghidEventTap)
        usleep(25_000)
    }
}
