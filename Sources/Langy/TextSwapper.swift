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

        // 1. Explicit selection wins.
        if let selected = axString(element, NSAccessibility.Attribute.selectedText.rawValue), !selected.isEmpty {
            return convert(source: selected) { [element] converted in
                axSetString(element, NSAccessibility.Attribute.selectedText.rawValue, converted)
            }
        }

        // 2. Plain caret → whole field.
        guard let full = axString(element, NSAccessibility.Attribute.value.rawValue), !full.isEmpty else {
            return .failure
        }
        let caret = axRange(element)?.location ?? 0
        return convert(source: full) { [element] converted in
            // Select all, replace, then collapse the caret back (clamped).
            guard axSetRange(element, CFRange(location: 0, length: (full as NSString).length)),
                  axSetString(element, NSAccessibility.Attribute.selectedText.rawValue, converted)
            else { return false }
            let at = min(caret, (converted as NSString).length)
            _ = axSetRange(element, CFRange(location: at, length: 0))
            return true
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
