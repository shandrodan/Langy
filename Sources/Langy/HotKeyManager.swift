import AppKit
import Carbon

/// System-wide hotkeys via Carbon RegisterEventHotKey.
/// Event-driven (no polling) — the cheapest possible global shortcut.
final class HotKeyManager {
    static let shared = HotKeyManager()

    var onConvert: (() -> Void)?
    var onSettings: (() -> Void)?

    private var convertRef: EventHotKeyRef?
    private var settingsRef: EventHotKeyRef?
    private var installed = false

    private let convertID = EventHotKeyID(signature: OSType(0x4C595431), id: 1) // 'LYT1'
    private let settingsID = EventHotKeyID(signature: OSType(0x4C595431), id: 2)

    func register() {
        if !installed {
            var spec = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )
            let selfPtr = Unmanaged.passUnretained(self).toOpaque()
            let handler: EventHandlerUPP = { _, event, userData -> OSStatus in
                guard let event, let userData else { return OSStatus(eventNotHandledErr) }
                let mgr = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                var hotID = EventHotKeyID()
                let st = GetEventParameter(
                    event, UInt32(kEventParamDirectObject), UInt32(typeEventHotKeyID),
                    nil, MemoryLayout<EventHotKeyID>.size, nil, &hotID
                )
                guard st == noErr else { return OSStatus(eventNotHandledErr) }
                DispatchQueue.main.async {
                    if hotID.id == mgr.convertID.id { mgr.onConvert?() }
                    else if hotID.id == mgr.settingsID.id { mgr.onSettings?() }
                }
                return noErr
            }
            InstallEventHandler(GetApplicationEventTarget(), handler, 1, &spec, selfPtr, nil)
            installed = true
        }

        // ⇧⌥L — fix / cycle layout
        var cRef: EventHotKeyRef?
        RegisterEventHotKey(
            UInt32(kVK_ANSI_L),
            UInt32(shiftKey | optionKey),
            convertID,
            GetApplicationEventTarget(),
            0,
            &cRef
        )
        convertRef = cRef

        // ⌃⌘⌥L — settings
        var sRef: EventHotKeyRef?
        RegisterEventHotKey(
            UInt32(kVK_ANSI_L),
            UInt32(controlKey | cmdKey | optionKey),
            settingsID,
            GetApplicationEventTarget(),
            0,
            &sRef
        )
        settingsRef = sRef
    }
}
