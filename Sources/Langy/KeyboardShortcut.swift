import AppKit
import Carbon

struct KeyboardShortcut: Codable, Equatable {
    let keyCode: UInt32
    let modifiers: UInt32

    private static let modifierMask = UInt32(cmdKey | controlKey | shiftKey | optionKey)

    init(keyCode: UInt32, modifiers: UInt32) {
        self.keyCode = keyCode
        self.modifiers = modifiers & Self.modifierMask
    }

    init(event: NSEvent) {
        var modifiers: UInt32 = 0
        if event.modifierFlags.contains(.command) { modifiers |= UInt32(cmdKey) }
        if event.modifierFlags.contains(.control) { modifiers |= UInt32(controlKey) }
        if event.modifierFlags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        if event.modifierFlags.contains(.option) { modifiers |= UInt32(optionKey) }
        self.init(keyCode: UInt32(event.keyCode), modifiers: modifiers)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyCode = try container.decode(UInt32.self, forKey: .keyCode)
        let modifiers = try container.decode(UInt32.self, forKey: .modifiers)
        guard modifiers & ~Self.modifierMask == 0 else {
            throw DecodingError.dataCorruptedError(
                forKey: .modifiers, in: container,
                debugDescription: "Shortcut modifiers must be Carbon Command, Control, Shift, or Option flags."
            )
        }
        self.init(keyCode: keyCode, modifiers: modifiers)
    }

    var displayString: String {
        var result = ""
        if modifiers & UInt32(controlKey) != 0 { result += "\u{2303}" }
        if modifiers & UInt32(cmdKey) != 0 { result += "\u{2318}" }
        if modifiers & UInt32(shiftKey) != 0 { result += "\u{21E7}" }
        if modifiers & UInt32(optionKey) != 0 { result += "\u{2325}" }
        return result + (Self.keyLabels[Int(keyCode)] ?? "Unsupported key (\(keyCode))")
    }

    var validationError: String? {
        guard Self.keyLabels[Int(keyCode)] != nil else {
            return "Choose a supported key with Command, Control, or Option. Modifier keys alone cannot be shortcuts."
        }
        guard modifiers & UInt32(cmdKey | controlKey | optionKey) != 0 else {
            return "Include at least one of Command, Control, or Option. Shift may be added, but bare keys and Shift-only shortcuts are not allowed."
        }
        guard keyCode != UInt32(kVK_ANSI_A) || modifiers != UInt32(cmdKey) else {
            return "Command+A is reserved for Langy's text-selection fallback. Choose another key or add Control, Option, or Shift."
        }
        return nil
    }

    // Physical ANSI labels deliberately ignore the current layout and Option-produced characters.
    private static let keyLabels: [Int: String] = [
        kVK_ANSI_A: "A",
        kVK_ANSI_B: "B",
        kVK_ANSI_C: "C",
        kVK_ANSI_D: "D",
        kVK_ANSI_E: "E",
        kVK_ANSI_F: "F",
        kVK_ANSI_G: "G",
        kVK_ANSI_H: "H",
        kVK_ANSI_I: "I",
        kVK_ANSI_J: "J",
        kVK_ANSI_K: "K",
        kVK_ANSI_L: "L",
        kVK_ANSI_M: "M",
        kVK_ANSI_N: "N",
        kVK_ANSI_O: "O",
        kVK_ANSI_P: "P",
        kVK_ANSI_Q: "Q",
        kVK_ANSI_R: "R",
        kVK_ANSI_S: "S",
        kVK_ANSI_T: "T",
        kVK_ANSI_U: "U",
        kVK_ANSI_V: "V",
        kVK_ANSI_W: "W",
        kVK_ANSI_X: "X",
        kVK_ANSI_Y: "Y",
        kVK_ANSI_Z: "Z",
        kVK_ANSI_0: "0",
        kVK_ANSI_1: "1",
        kVK_ANSI_2: "2",
        kVK_ANSI_3: "3",
        kVK_ANSI_4: "4",
        kVK_ANSI_5: "5",
        kVK_ANSI_6: "6",
        kVK_ANSI_7: "7",
        kVK_ANSI_8: "8",
        kVK_ANSI_9: "9",
        kVK_ANSI_Equal: "=",
        kVK_ANSI_Minus: "-",
        kVK_ANSI_LeftBracket: "[",
        kVK_ANSI_RightBracket: "]",
        kVK_ANSI_Quote: "'",
        kVK_ANSI_Semicolon: ";",
        kVK_ANSI_Backslash: "\\",
        kVK_ANSI_Comma: ",",
        kVK_ANSI_Period: ".",
        kVK_ANSI_Slash: "/",
        kVK_ANSI_Grave: "`",
        kVK_ANSI_Keypad0: "Keypad 0",
        kVK_ANSI_Keypad1: "Keypad 1",
        kVK_ANSI_Keypad2: "Keypad 2",
        kVK_ANSI_Keypad3: "Keypad 3",
        kVK_ANSI_Keypad4: "Keypad 4",
        kVK_ANSI_Keypad5: "Keypad 5",
        kVK_ANSI_Keypad6: "Keypad 6",
        kVK_ANSI_Keypad7: "Keypad 7",
        kVK_ANSI_Keypad8: "Keypad 8",
        kVK_ANSI_Keypad9: "Keypad 9",
        kVK_ANSI_KeypadDecimal: "Keypad .",
        kVK_ANSI_KeypadMultiply: "Keypad *",
        kVK_ANSI_KeypadPlus: "Keypad +",
        kVK_ANSI_KeypadClear: "Keypad Clear",
        kVK_ANSI_KeypadDivide: "Keypad /",
        kVK_ANSI_KeypadEnter: "Keypad Enter",
        kVK_ANSI_KeypadMinus: "Keypad -",
        kVK_ANSI_KeypadEquals: "Keypad =",
        kVK_Return: "Return",
        kVK_Tab: "Tab",
        kVK_Space: "Space",
        kVK_Delete: "Delete",
        kVK_ForwardDelete: "Forward Delete",
        kVK_Escape: "Escape",
        kVK_Help: "Help",
        kVK_Home: "Home",
        kVK_End: "End",
        kVK_PageUp: "Page Up",
        kVK_PageDown: "Page Down",
        kVK_LeftArrow: "\u{2190}",
        kVK_RightArrow: "\u{2192}",
        kVK_DownArrow: "\u{2193}",
        kVK_UpArrow: "\u{2191}",
        kVK_F1: "F1",
        kVK_F2: "F2",
        kVK_F3: "F3",
        kVK_F4: "F4",
        kVK_F5: "F5",
        kVK_F6: "F6",
        kVK_F7: "F7",
        kVK_F8: "F8",
        kVK_F9: "F9",
        kVK_F10: "F10",
        kVK_F11: "F11",
        kVK_F12: "F12",
        kVK_F13: "F13",
        kVK_F14: "F14",
        kVK_F15: "F15",
        kVK_F16: "F16",
        kVK_F17: "F17",
        kVK_F18: "F18",
        kVK_F19: "F19",
        kVK_F20: "F20"
    ]
}
