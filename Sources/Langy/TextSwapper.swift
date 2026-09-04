import AppKit
import ApplicationServices

/// Swaps text in place through the Accessibility API only — the clipboard is
/// never touched in any path.
///
/// - Non-empty selection → converts just the selection.
/// - Empty selection (plain caret) → converts the whole field.
/// The old text is deleted and the converted text takes its place in one write.

/// Outcome of a conversion attempt, mapped by the caller to the
/// menu-bar indicator color. No popups, no sounds — ever.
enum ConversionOutcome {
    case success // green flash
    case permissionMissing // orange flash
    case failure // red flash
}

final class TextSwapper {
    static let shared = TextSwapper()
    private let transliterator = Transliterator()

    // MARK: - Accessibility

    var isTrusted: Bool { AXIsProcessTrusted() }
    private var promptedThisLaunch = false

    /// Shows the system prompt at most once per launch — after that we only
    /// hint, so the shortcut never nag-loops while the user is fixing settings.
    func requestAccessIfNeeded() {
        guard !AXIsProcessTrusted(), !promptedThisLaunch else { return }
        promptedThisLaunch = true
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(opts)
    }

    /// Opens the exact Accessibility pane (used by the Settings permission row).
    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Convert

    func convertSelection() -> ConversionOutcome {
        requestAccessIfNeeded()
        guard isTrusted else {
            // The classic trap: the switch is ON but this process started
            // before it was flipped — macOS only trusts a fresh launch.
            return .permissionMissing
        }
        transliterator.layouts = LayoutStore.shared.effectiveLayouts()
        guard !transliterator.layouts.isEmpty else {
            return .failure
        }
        guard let element = focusedElement() else {
            return .failure
        }
        let app = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "?"

        // 1. Explicit selection wins.
        if let selected = axString(element, NSAccessibility.Attribute.selectedText.rawValue), !selected.isEmpty {
            return convert(source: selected) { [element] converted in
                writeSelection(element: element, original: selected, converted: converted, app: app)
            }
        }

        // 2. Plain caret → whole field.
        guard let full = axString(element, NSAccessibility.Attribute.value.rawValue), !full.isEmpty else {
            return .failure
        }
        let caret = axRange(element)?.location ?? 0
        return convert(source: full) { [element] converted in
            writeField(element: element, original: full, caret: caret, converted: converted, app: app)
        }
    }

    /// Runs one conversion step and reports the outcome.
    /// `write` performs the replacement, returning whether it landed.
    private func convert(source: String, write: (String) -> Bool) -> ConversionOutcome {
        guard let (text, _) = transliterator.next(for: source) else {
            return .failure
        }
        return write(text) ? .success : .failure
    }

    // MARK: - Write strategies

    // Every write is verified by re-reading: some apps (notably Electron
    // editors with framework-controlled inputs) report success but never
    // commit the change. On mismatch we fall back to retyping through the
    // key pipeline — still no clipboard, ever. Each step is logged; fetch
    // with: log show --predicate 'process == "Langy"' --last 10m

    private func writeSelection(element: AXUIElement, original: String, converted: String, app: String) -> Bool {
        let attr = NSAccessibility.Attribute.selectedText.rawValue
        let originalRange = axRange(element)
        if isSettable(element, attr) {
            let res = axSetString(element, attr, converted)
            NSLog("Langy: AXSelectedText set %@ in %@", res ? "ok" : "ERR", app)
            if res, verifySelection(element, converted: converted) { return true }
            NSLog("Langy: AXSelectedText not committed in %@, keystroke fallback", app)
        } else {
            NSLog("Langy: AXSelectedText not settable in %@, keystroke fallback", app)
        }
        // Fallback only if the original text is still where we left it —
        // never blind-delete an unknown selection.
        guard confirmSelected(element: element, original: original, range: originalRange) else {
            NSLog("Langy: fallback aborted, selection moved in %@", app)
            return false
        }
        KeyTyper.deleteBackward()
        KeyTyper.typeText(converted)
        let ok = verifySelection(element, converted: converted)
        NSLog("Langy: keystroke fallback %@ in %@", ok ? "ok" : "FAIL", app)
        return ok
    }

    private func writeField(element: AXUIElement, original: String, caret: Int, converted: String, app: String) -> Bool {
        let selAttr = NSAccessibility.Attribute.selectedText.rawValue
        let fullLen = (original as NSString).length
        selectAll(element: element, length: fullLen)
        // Electron/Chromium applies selection asynchronously — poll for it
        // instead of trusting a single immediate read-back (that race used
        // to cost users a whole extra press: select first, swap second).
        guard waitForRange(element, location: 0, length: fullLen) else {
            NSLog("Langy: cannot select field in %@, aborting (no partial write)", app)
            return false
        }
        if isSettable(element, selAttr),
           axSetString(element, selAttr, converted),
           verifyField(element, converted: converted) {
            restoreCaret(element: element, caret: caret, converted: converted)
            return true
        }
        // Some custom fields honor a direct value write but not selection ops.
        if isSettable(element, NSAccessibility.Attribute.value.rawValue),
           axSetString(element, NSAccessibility.Attribute.value.rawValue, converted),
           verifyField(element, converted: converted) {
            restoreCaret(element: element, caret: caret, converted: converted)
            return true
        }
        NSLog("Langy: field AX path failed in %@, keystroke fallback", app)
        selectAll(element: element, length: fullLen)
        // Never delete blind: only proceed once the full selection is confirmed.
        guard waitForRange(element, location: 0, length: fullLen) else {
            NSLog("Langy: keystroke fallback aborted, no selection in %@", app)
            return false
        }
        KeyTyper.deleteBackward()
        KeyTyper.typeText(converted)
        guard verifyField(element, converted: converted) else {
            NSLog("Langy: keystroke fallback FAIL in %@", app)
            return false
        }
        restoreCaret(element: element, caret: caret, converted: converted)
        return true
    }

    /// Selects the whole field: AX range first, ⌘A key event as backup.
    private func selectAll(element: AXUIElement, length: Int) {
        if axSetRange(element, CFRange(location: 0, length: length)) { return }
        KeyTyper.selectAll()
        usleep(30_000)
    }

    private func restoreCaret(element: AXUIElement, caret: Int, converted: String) {
        let at = min(caret, (converted as NSString).length)
        _ = axSetRange(element, CFRange(location: at, length: 0))
    }

    /// True only if `original` is currently selected (re-selecting first,
    /// polling because async apps lag behind the request).
    private func confirmSelected(element: AXUIElement, original: String, range: CFRange?) -> Bool {
        let attr = NSAccessibility.Attribute.selectedText.rawValue
        if let r = range { _ = axSetRange(element, r) }
        return waitForSelectedText(element, original)
    }

    /// Polls until the selected range matches (async apps need a beat).
    private func waitForRange(_ element: AXUIElement, location: Int, length: Int, attempts: Int = 12) -> Bool {
        for i in 0 ..< attempts {
            if i > 0 { usleep(25_000) }
            if let r = axRange(element), r.location == location, r.length == length { return true }
        }
        return false
    }

    /// Polls until the selected text reads back as expected.
    private func waitForSelectedText(_ element: AXUIElement, _ expected: String, attempts: Int = 12) -> Bool {
        let attr = NSAccessibility.Attribute.selectedText.rawValue
        for i in 0 ..< attempts {
            if i > 0 { usleep(25_000) }
            if axString(element, attr) == expected { return true }
        }
        return false
    }

    /// Selection landed if it reads back, or the field now contains it
    /// (some apps collapse the selection on write).
    private func verifySelection(_ element: AXUIElement, converted: String) -> Bool {
        for i in 0 ..< 6 {
            if i > 0 { usleep(25_000) }
            if axString(element, NSAccessibility.Attribute.selectedText.rawValue) == converted { return true }
            if let full = axString(element, NSAccessibility.Attribute.value.rawValue),
               full.contains(converted) { return true }
        }
        return false
    }

    private func verifyField(_ element: AXUIElement, converted: String) -> Bool {
        for i in 0 ..< 5 {
            if i > 0 { usleep(25_000) }
            if axString(element, NSAccessibility.Attribute.value.rawValue) == converted { return true }
        }
        return false
    }

    // MARK: - AX helpers

    private func focusedElement() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var focused: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appElement, NSAccessibility.Attribute.focusedUIElement.rawValue as CFString, &focused) == .success,
              let raw = focused, CFGetTypeID(raw) == AXUIElementGetTypeID()
        else { return nil }
        return raw as! AXUIElement
    }

    private func axString(_ element: AXUIElement, _ attribute: String) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success,
              let string = value as? String
        else { return nil }
        return string
    }

    private func axSetString(_ element: AXUIElement, _ attribute: String, _ text: String) -> Bool {
        AXUIElementSetAttributeValue(element, attribute as CFString, text as CFTypeRef) == .success
    }

    private func isSettable(_ element: AXUIElement, _ attribute: String) -> Bool {
        var settable: DarwinBoolean = false
        guard AXUIElementIsAttributeSettable(element, attribute as CFString, &settable) == .success else { return false }
        return settable.boolValue
    }

    private func axRange(_ element: AXUIElement) -> CFRange? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, NSAccessibility.Attribute.selectedTextRange.rawValue as CFString, &value) == .success,
              let raw = value, CFGetTypeID(raw) == AXValueGetTypeID()
        else { return nil }
        let axValue = raw as! AXValue
        var range = CFRange(location: 0, length: 0)
        guard AXValueGetValue(axValue, .cfRange, &range) else { return nil }
        return range
    }

    private func axSetRange(_ element: AXUIElement, _ range: CFRange) -> Bool {
        var mutable = range
        guard let axValue = AXValueCreate(.cfRange, &mutable) else { return false }
        return AXUIElementSetAttributeValue(
            element, NSAccessibility.Attribute.selectedTextRange.rawValue as CFString, axValue
        ) == .success
    }
}
