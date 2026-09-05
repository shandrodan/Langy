import AppKit
import Carbon

/// Event-driven system-wide shortcuts. Use on the main thread: Carbon hotkey APIs are not thread-safe.
final class HotKeyManager {
    static let shared = HotKeyManager()

    enum Action: Int, CaseIterable {
        case convert = 0
        case settings = 1

        var title: String {
            switch self {
            case .convert: return "Switch"
            case .settings: return "Open Settings"
            }
        }

        var rewriteTitle: String {
            switch self {
            case .convert: return "Rewrite Switch Hotkey"
            case .settings: return "Rewrite Settings Hotkey"
            }
        }

        var defaultShortcut: KeyboardShortcut {
            switch self {
            case .convert:
                return KeyboardShortcut(keyCode: UInt32(kVK_ANSI_L), modifiers: UInt32(shiftKey | optionKey))
            case .settings:
                return KeyboardShortcut(keyCode: UInt32(kVK_ANSI_L), modifiers: UInt32(controlKey | cmdKey | optionKey))
            }
        }

        var defaultsKey: String {
            switch self {
            case .convert: return "langy.shortcut.convert"
            case .settings: return "langy.shortcut.settings"
            }
        }
    }

    var onConvert: (() -> Void)?
    var onSettings: (() -> Void)?
    var onShortcutsChanged: (() -> Void)?
    private(set) var isRecording = false

    private struct Registration {
        let shortcut: KeyboardShortcut
        let reference: EventHotKeyRef
        let id: UInt32
    }

    private struct ShortcutError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    private let defaults: UserDefaults
    private var registrations: [Action: Registration] = [:]
    private var handlerRef: EventHandlerRef?
    private var callbacksEnabledAfter: EventTime = 0
    private var pendingUnregistrations: [EventHotKeyRef] = []

    private static let signature = OSType(0x4C595431) // 'LYT1'
    // Never reuse an action's ID on replacement/resume, including across manager instances.
    private static var nextRegistrationID: UInt32 = 0

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func shortcut(for action: Action) -> KeyboardShortcut {
        guard let data = defaults.data(forKey: action.defaultsKey),
              let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data),
              shortcut.validationError == nil else {
            return action.defaultShortcut
        }
        return shortcut
    }

    func validate(_ shortcut: KeyboardShortcut, for action: Action) throws {
        if let message = shortcut.validationError {
            throw ShortcutError(message: message)
        }
        for other in Action.allCases where other != action {
            let saved = self.shortcut(for: other)
            let matchesActive: Bool
            if let registration = registrations[other] {
                matchesActive = registration.shortcut == shortcut
            } else {
                matchesActive = false
            }
            if shortcut == saved || matchesActive {
                throw ShortcutError(message: "\(shortcut.displayString) is already assigned to \(other.title). Choose a different shortcut.")
            }
        }
        // Some enabled macOS shortcuts do not report a conflict through RegisterEventHotKey.
        var symbolicKeys: Unmanaged<CFArray>?
        let status = CopySymbolicHotKeys(&symbolicKeys)
        guard status == noErr, let keys = symbolicKeys?.takeRetainedValue() as? [[String: Any]] else {
            throw ShortcutError(message: "Could not check macOS keyboard shortcuts (macOS error \(status)). Try again.")
        }
        if keys.contains(where: {
            ($0[kHISymbolicHotKeyEnabled as String] as? Bool) == true &&
            ($0[kHISymbolicHotKeyCode as String] as? NSNumber)?.uint32Value == shortcut.keyCode &&
            ($0[kHISymbolicHotKeyModifiers as String] as? NSNumber)?.uint32Value == shortcut.modifiers
        }) {
            throw ShortcutError(message: "\(shortcut.displayString) is used by an enabled macOS keyboard shortcut. Choose another combination or change it in System Settings first.")
        }
    }

    func setShortcut(_ shortcut: KeyboardShortcut, for action: Action) throws {
        try validate(shortcut, for: action)
        if let registration = registrations[action], registration.shortcut == shortcut { return }

        let data = try JSONEncoder().encode(shortcut)
        try activate(shortcut, for: action)
        defaults.set(data, forKey: action.defaultsKey)
        DispatchQueue.main.async { [weak self] in
            self?.onShortcutsChanged?()
        }
    }

    @discardableResult
    func register() -> [String] {
        guard !isRecording else { return [] }
        do {
            try installHandler()
        } catch {
            NSLog("Langy: %@", error.localizedDescription)
            return [error.localizedDescription]
        }

        var errors: [String] = []
        for action in Action.allCases {
            do {
                let shortcut = shortcut(for: action)
                try validate(shortcut, for: action)
                try activate(shortcut, for: action)
            } catch {
                let message = "\(action.title): \(error.localizedDescription)"
                errors.append(message)
                NSLog("Langy: %@", message)
            }
        }
        return errors
    }

    /// Recording is single-owner, not nested. The UI must check isRecording before opening another recorder.
    func beginRecording() {
        guard !isRecording else { return }
        isRecording = true
        callbacksEnabledAfter = GetCurrentEventTime()
        for (action, registration) in registrations {
            let status = UnregisterEventHotKey(registration.reference)
            if status == noErr {
                registrations.removeValue(forKey: action)
            } else {
                NSLog("Langy: could not pause %@ shortcut (macOS error %d)", action.title, status)
            }
        }
        pendingUnregistrations.removeAll { reference in
            UnregisterEventHotKey(reference) == noErr
        }
    }

    @discardableResult
    func endRecording() -> [String] {
        if isRecording {
            // Also reject Carbon events queued during recording, not just dispatched closures.
            callbacksEnabledAfter = GetCurrentEventTime()
            isRecording = false
        }
        return register()
    }

    private func installHandler() throws {
        guard handlerRef == nil else { return }
        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let handler: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let event, let userData else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            var hotID = EventHotKeyID()
            let status = GetEventParameter(
                event, UInt32(kEventParamDirectObject), UInt32(typeEventHotKeyID),
                nil, MemoryLayout<EventHotKeyID>.size, nil, &hotID
            )
            guard status == noErr, hotID.signature == HotKeyManager.signature,
                  let action = manager.registrations.first(where: { $0.value.id == hotID.id })?.key else {
                return OSStatus(eventNotHandledErr)
            }
            guard !manager.isRecording, GetEventTime(event) >= manager.callbacksEnabledAfter else { return noErr }
            let enabledAfter = manager.callbacksEnabledAfter
            let id = hotID.id
            DispatchQueue.main.async { [weak manager] in
                guard let manager, !manager.isRecording,
                      manager.callbacksEnabledAfter == enabledAfter,
                      manager.registrations[action]?.id == id else { return }
                switch action {
                case .convert: manager.onConvert?()
                case .settings: manager.onSettings?()
                }
            }
            return noErr
        }
        var reference: EventHandlerRef?
        let status = InstallEventHandler(
            GetApplicationEventTarget(), handler, 1, &spec,
            Unmanaged.passUnretained(self).toOpaque(), &reference
        )
        guard status == noErr, let reference else {
            if let reference { RemoveEventHandler(reference) }
            throw ShortcutError(message: "Could not install the global shortcut handler (macOS error \(status)).")
        }
        handlerRef = reference
    }

    private func activate(_ shortcut: KeyboardShortcut, for action: Action) throws {
        if let registration = registrations[action], registration.shortcut == shortcut { return }
        try installHandler()

        Self.nextRegistrationID &+= 1
        let id = Self.nextRegistrationID
        var reference: EventHotKeyRef?
        let status = RegisterEventHotKey(
            shortcut.keyCode, shortcut.modifiers,
            EventHotKeyID(signature: Self.signature, id: id),
            GetApplicationEventTarget(), OptionBits(kEventHotKeyExclusive), &reference
        )
        guard status == noErr, let reference else {
            if let reference { discardRegistration(reference) }
            let reason = status == OSStatus(eventHotKeyExistsErr)
                ? "That combination is already in use by another app or a system shortcut."
                : "macOS error \(status). Try a different combination."
            throw ShortcutError(message: "Could not register \(shortcut.displayString). \(reason)")
        }

        // Keep the old binding until the candidate is live. Roll back if releasing the old one fails.
        if let previous = registrations[action] {
            let status = UnregisterEventHotKey(previous.reference)
            guard status == noErr else {
                discardRegistration(reference)
                throw ShortcutError(message: "Could not replace \(previous.shortcut.displayString) (macOS error \(status)). The previous shortcut was kept.")
            }
        }
        registrations[action] = Registration(shortcut: shortcut, reference: reference, id: id)
    }

    private func discardRegistration(_ reference: EventHotKeyRef) {
        let status = UnregisterEventHotKey(reference)
        if status != noErr {
            // Retain failed cleanup references so recording/deinit can retry; they never dispatch actions.
            pendingUnregistrations.append(reference)
            NSLog("Langy: could not release a shortcut registration (macOS error %d)", status)
        }
    }

    deinit {
        for reference in registrations.values.map(\.reference) + pendingUnregistrations {
            let status = UnregisterEventHotKey(reference)
            if status != noErr {
                NSLog("Langy: could not unregister a shortcut (macOS error %d)", status)
            }
        }
        if let handlerRef {
            let status = RemoveEventHandler(handlerRef)
            if status != noErr {
                NSLog("Langy: could not remove the shortcut handler (macOS error %d)", status)
            }
        }
    }
}
