import AppKit
import Carbon

/// Standalone AppKit regression checks; no XCTest or full Xcode installation needed.
@main
final class SettingsChecks {
    private var controllers: [SettingsWindowController] = []

    static func main() throws {
        precondition(Thread.isMainThread)
        _ = NSApplication.shared
        setbuf(stdout, nil)
        let delegate = AppDelegate()
        NSApp.delegate = delegate
        let keys = ["langy.useSystemLayouts", "langy.customLayouts", "langy.disabledLayoutIDs", "langy.showMenuBarIcon"] +
            HotKeyManager.Action.allCases.map(\.defaultsKey)
        let saved = Dictionary(uniqueKeysWithValues: keys.map { ($0, UserDefaults.standard.object(forKey: $0)) })
        defer { for key in keys { UserDefaults.standard.set(saved[key] ?? nil, forKey: key) } }
        let checks = SettingsChecks()
        let cases: [(String, () throws -> Void)] = [
            ("Both settings modes and window bounds", checks.checkModes),
            ("System layout switch and custom preservation", checks.checkSystemSwitch),
            ("Search, enable/disable, and selected custom removal", checks.checkLayoutManagement),
            ("Built-in protection and empty search", checks.checkEmptySearch),
            ("Custom layout sheet and positional mapping", checks.checkAddSheet),
            ("Menu-bar visibility persistence", checks.checkMenuBar),
            ("Shortcut defaults and validation", checks.checkShortcutDefaults),
            ("Live shortcut registration, persistence, and conflict rollback", checks.checkShortcutRegistration),
            ("Shortcut recorder save, cancel, and defaults", checks.checkShortcutRecorder),
            ("Light and dark rendering", checks.renderSnapshots),
            ("Live menu-bar visibility and hidden-icon recovery", checks.checkMenuBarRuntime)
        ]
        for (name, run) in cases {
            for key in keys { UserDefaults.standard.removeObject(forKey: key) }
            try autoreleasepool {
                try run()
                checks.controllers.forEach { $0.close() }
                checks.controllers.removeAll()
            }
            print("PASS: \(name)")
        }
        print("All \(cases.count) settings checks passed.")
    }

    private func require<T>(_ value: T?, file: StaticString = #file, line: UInt = #line) -> T {
        guard let value else { fatalError("Required UI element is missing", file: file, line: line) }
        return value
    }

    private func settings(system: Bool, hotkeys: HotKeyManager = .shared) -> SettingsWindowController {
        LayoutStore.shared.useSystemLayouts = system
        let controller = SettingsWindowController(hotkeys: hotkeys)
        controllers.append(controller)
        return controller
    }

    private func descendants(of view: NSView) -> [NSView] {
        [view] + view.subviews.flatMap { descendants(of: $0) }
    }

    private func button(_ title: String, in controller: SettingsWindowController) -> NSButton {
        require(descendants(of: controller.window!.contentView!).compactMap { $0 as? NSButton }.first { $0.title == title })
    }

    private func switchHost(_ title: String, in controller: SettingsWindowController) -> SettingsSwitch {
        let root = require(controller.window?.contentView)
        root.layoutSubtreeIfNeeded()
        return require(descendants(of: root).compactMap { $0 as? SettingsSwitch }.first { $0.accessibilityLabel() == title })
    }

    private func toggle(_ title: String, in controller: SettingsWindowController) -> SettingsSwitch {
        switchHost(title, in: controller)
    }

    private func table(in controller: SettingsWindowController) -> NSTableView {
        require(descendants(of: controller.window!.contentView!).compactMap { $0 as? NSTableView }.first)
    }

    private func search(_ query: String, in controller: SettingsWindowController) {
        let field = require(descendants(of: controller.window!.contentView!).compactMap { $0 as? NSSearchField }.first)
        field.stringValue = query
        precondition(field.sendAction(field.action!, to: field.target))
    }

    private func checkModes() {
        for system in [true, false] {
            let controller = settings(system: system)
            let window = require(controller.window)
            let background = require(window.contentView)
            background.layoutSubtreeIfNeeded()
            let root = require(descendants(of: background).first { $0.identifier?.rawValue == "settings.content" })
            precondition(root.bounds.width == 400)
            precondition(root.convert(root.bounds, to: background).maxY == background.bounds.maxY, "Settings content is not aligned with the glass background")
            precondition(window.frame.height <= 730)
            precondition(!window.isOpaque && window.backgroundColor == .clear)
            if #available(macOS 26, *) {
                let glass = require(descendants(of: background).compactMap { $0 as? NSGlassEffectView }.first)
                precondition(glass.superview === background)
                precondition(glass.contentView == nil)
            } else {
                precondition(background is NSVisualEffectView)
            }
            for view in root.subviews { precondition(root.bounds.contains(view.frame), "Clipped view: \(view)") }
            for title in ["Use system keyboard layouts", "Show icon in menu bar", "Launch on startup"] {
                let host = toggle(title, in: controller)
                precondition(host.accessibilityLabel() == title)
                precondition(host.state == .on || host.state == .off)
            }
            for title in ["Open Accessibility Settings...", "Quit & Reopen", "Quit Completely", "made by dan"] {
                precondition(button(title, in: controller).action != nil)
            }
            for action in HotKeyManager.Action.allCases {
                precondition(button(action.rewriteTitle, in: controller).action != nil)
                let label = require(descendants(of: root).compactMap { $0 as? NSTextField }.first { $0.identifier?.rawValue == "shortcut.\(action.rawValue).label" })
                precondition(label.stringValue == "\(action.title): \(action.defaultShortcut.displayString)")
            }
            precondition(descendants(of: root).contains { $0 is NSSearchField } == !system)
            precondition(descendants(of: root).contains { $0 is NSTableView } == !system)
            if !system {
                let layouts = table(in: controller)
                layouts.layoutSubtreeIfNeeded()
                let cell = require(layouts.view(atColumn: 1, row: 3, makeIfNecessary: true))
                cell.layoutSubtreeIfNeeded()
                let toggle = require(cell.subviews.first as? SettingsSwitch)
                precondition(cell.bounds.contains(toggle.frame), "Layout toggle overflows its cell")
                precondition(layouts.visibleRect.contains(toggle.convert(toggle.bounds, to: layouts)), "The fourth layout toggle is clipped")
                precondition(toggle.bounds.width == 36 && toggle.bounds.height == 16, "Small switch has unexpected bounds \(toggle.bounds)")
            }
        }
    }

    private func checkSystemSwitch() {
        let custom = KeyboardLayout(id: "custom.test", name: "Test", map: ["q": "x"], isSystem: false)
        LayoutStore.shared.addCustom(custom)
        let controller = settings(system: true)
        let compactHeight = controller.window!.frame.height
        let toggle = toggle("Use system keyboard layouts", in: controller)
        precondition(toggle.state == .on)
        toggle.performClick(nil)
        precondition(!LayoutStore.shared.useSystemLayouts)
        precondition(controller.window!.frame.height > compactHeight)
        precondition(table(in: controller).numberOfRows > 0)
        self.toggle("Use system keyboard layouts", in: controller).performClick(nil)
        precondition(LayoutStore.shared.useSystemLayouts)
        precondition(controller.window!.frame.height == compactHeight)
        precondition(LayoutStore.shared.effectiveLayouts().contains { $0.id == custom.id })
    }

    private func checkLayoutManagement() {
        let custom = KeyboardLayout(id: "custom.test", name: "Test layout", map: ["q": "x"], isSystem: false)
        LayoutStore.shared.addCustom(custom)
        let controller = settings(system: false)
        precondition(!button("Remove", in: controller).isEnabled)
        search("  TEST LAYOUT  ", in: controller)
        let table = table(in: controller)
        precondition(table.numberOfRows == 1)
        let cell = require(table.view(atColumn: 1, row: 0, makeIfNecessary: true))
        cell.layoutSubtreeIfNeeded()
        let toggle = require(descendants(of: cell).compactMap { $0 as? SettingsSwitch }.first)
        toggle.performClick(nil)
        precondition(LayoutStore.shared.disabledIDs.contains(custom.id))
        precondition(!LayoutStore.shared.effectiveLayouts().contains { $0.id == custom.id })
        table.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        let remove = button("Remove", in: controller)
        precondition(remove.isEnabled)
        remove.performClick(nil)
        precondition(LayoutStore.shared.customLayouts.isEmpty)
        precondition(!LayoutStore.shared.disabledIDs.contains(custom.id))
        let field = require(descendants(of: controller.window!.contentView!).compactMap { $0 as? NSSearchField }.first)
        precondition(field.stringValue == "TEST LAYOUT")
        precondition(!button("Remove", in: controller).isEnabled)
    }

    private func checkEmptySearch() {
        let controller = settings(system: false)
        let table = table(in: controller)
        table.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        precondition(!button("Remove", in: controller).isEnabled)
        search("no-such-layout", in: controller)
        precondition(table.numberOfRows == 1)
        precondition(!controller.tableView(table, shouldSelectRow: 0))
        let label = require(controller.tableView(table, viewFor: table.tableColumns[0], row: 0) as? NSTextField)
        precondition(label.stringValue.contains("No layouts match"))
        search("", in: controller)
        precondition(table.numberOfRows == BuiltinLayouts.all.count)
    }

    private func checkAddSheet() {
        let controller = settings(system: false)
        button("Add", in: controller).performClick(nil)
        let sheet = require(controller.window?.attachedSheet)
        let views = descendants(of: require(sheet.contentView))
        let fields = views.compactMap { $0 as? NSTextField }.filter(\.isEditable)
        precondition(fields.count == 3)
        fields[0].stringValue = "  Sample  "
        fields[1].stringValue = "Qw"
        fields[2].stringValue = "xy"
        let add = require(views.compactMap { $0 as? NSButton }.first { $0.title == "Add" })
        add.performClick(nil)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        let layout = require(LayoutStore.shared.customLayouts.first)
        precondition(layout.name == "Sample")
        precondition(layout.map == ["q": "x", "w": "y"])
        precondition(layout.id.hasPrefix("custom."))
    }

    private func checkMenuBar() {
        let delegate = require(NSApp.delegate as? AppDelegate)
        precondition(delegate.showsMenuBarIcon)
        let controller = settings(system: true)
        toggle("Show icon in menu bar", in: controller).performClick(nil)
        precondition(!delegate.showsMenuBarIcon)
        precondition(!AppDelegate().showsMenuBarIcon)
        let reopened = settings(system: true)
        let toggle = toggle("Show icon in menu bar", in: reopened)
        precondition(toggle.state == .off)
        precondition(switchHost("Show icon in menu bar", in: reopened).accessibilityHelp()?.contains("hidden") == true)
        toggle.performClick(nil)
        precondition(delegate.showsMenuBarIcon)
    }

    private func expectShortcutFailure(_ operation: () throws -> Void) {
        do {
            try operation()
            preconditionFailure("An invalid or conflicting shortcut was accepted")
        } catch { }
    }

    private func checkShortcutDefaults() throws {
        let suite = "LangyShortcutChecks.\(UUID().uuidString)"
        let defaults = require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = HotKeyManager(defaults: defaults)
        precondition(manager.shortcut(for: .convert).displayString == "⇧⌥L")
        precondition(manager.shortcut(for: .settings).displayString == "⌃⌘⌥L")
        for modifiers in [UInt32(0), UInt32(shiftKey)] {
            expectShortcutFailure { try manager.validate(KeyboardShortcut(keyCode: UInt32(kVK_ANSI_K), modifiers: modifiers), for: .convert) }
        }
        expectShortcutFailure { try manager.validate(.init(keyCode: UInt32(kVK_ANSI_A), modifiers: UInt32(cmdKey)), for: .convert) }
        expectShortcutFailure { try manager.validate(.init(keyCode: UInt32(kVK_Shift), modifiers: UInt32(optionKey)), for: .convert) }
        expectShortcutFailure { try manager.validate(.init(keyCode: 999, modifiers: UInt32(optionKey)), for: .convert) }
        expectShortcutFailure { try manager.validate(HotKeyManager.Action.settings.defaultShortcut, for: .convert) }
        var symbolicKeys: Unmanaged<CFArray>?
        precondition(CopySymbolicHotKeys(&symbolicKeys) == noErr)
        let systemKeys = require(symbolicKeys?.takeRetainedValue() as? [[String: Any]])
        for key in systemKeys where (key[kHISymbolicHotKeyEnabled as String] as? Bool) == true {
            guard let code = key[kHISymbolicHotKeyCode as String] as? NSNumber,
                  let modifiers = key[kHISymbolicHotKeyModifiers as String] as? NSNumber else { continue }
            let shortcut = KeyboardShortcut(keyCode: code.uint32Value, modifiers: modifiers.uint32Value)
            if shortcut.validationError == nil, shortcut.modifiers == modifiers.uint32Value {
                expectShortcutFailure { try manager.validate(shortcut, for: .convert) }
            }
        }
        defaults.set(Data("not-json".utf8), forKey: HotKeyManager.Action.convert.defaultsKey)
        precondition(manager.shortcut(for: .convert) == HotKeyManager.Action.convert.defaultShortcut)
        let custom = KeyboardShortcut(keyCode: UInt32(kVK_F17), modifiers: UInt32(controlKey | optionKey))
        defaults.set(try JSONEncoder().encode(custom), forKey: HotKeyManager.Action.convert.defaultsKey)
        precondition(HotKeyManager(defaults: defaults).shortcut(for: .convert) == custom)
    }

    private func claim(_ shortcut: KeyboardShortcut) -> (OSStatus, EventHotKeyRef?) {
        var reference: EventHotKeyRef?
        let status = RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers,
            EventHotKeyID(signature: OSType(0x54455354), id: 99), GetApplicationEventTarget(),
            OptionBits(kEventHotKeyExclusive), &reference)
        return (status, reference)
    }

    private func checkShortcutRegistration() throws {
        let suite = "LangyShortcutChecks.\(UUID().uuidString)"
        let defaults = require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = HotKeyManager(defaults: defaults)
        let modifiers = UInt32(controlKey | optionKey | cmdKey | shiftKey)
        let original = KeyboardShortcut(keyCode: UInt32(kVK_F17), modifiers: modifiers)
        let settings = KeyboardShortcut(keyCode: UInt32(kVK_F18), modifiers: modifiers)
        let replacement = KeyboardShortcut(keyCode: UInt32(kVK_F19), modifiers: modifiers)
        let conflict = KeyboardShortcut(keyCode: UInt32(kVK_F20), modifiers: modifiers)
        defaults.set(try JSONEncoder().encode(original), forKey: HotKeyManager.Action.convert.defaultsKey)
        defaults.set(try JSONEncoder().encode(settings), forKey: HotKeyManager.Action.settings.defaultsKey)
        precondition(manager.register().isEmpty)
        precondition(manager.register().isEmpty)
        precondition(claim(original).0 == OSStatus(eventHotKeyExistsErr))
        try manager.setShortcut(replacement, for: .convert)
        precondition(manager.shortcut(for: .convert) == replacement)
        precondition(HotKeyManager(defaults: defaults).shortcut(for: .convert) == replacement)
        let released = claim(original)
        precondition(released.0 == noErr)
        UnregisterEventHotKey(require(released.1))
        precondition(claim(replacement).0 == OSStatus(eventHotKeyExistsErr))
        let occupied = claim(conflict)
        precondition(occupied.0 == noErr)
        defer { UnregisterEventHotKey(require(occupied.1)) }
        expectShortcutFailure { try manager.setShortcut(conflict, for: .convert) }
        expectShortcutFailure { try manager.setShortcut(settings, for: .convert) }
        precondition(manager.shortcut(for: .convert) == replacement)
        precondition(claim(replacement).0 == OSStatus(eventHotKeyExistsErr))
        manager.beginRecording()
        precondition(manager.isRecording)
        for shortcut in [replacement, settings] {
            let paused = claim(shortcut)
            precondition(paused.0 == noErr, "Recording did not release an existing hotkey")
            UnregisterEventHotKey(require(paused.1))
        }
        precondition(manager.endRecording().isEmpty)
        precondition(!manager.isRecording)
        precondition(claim(replacement).0 == OSStatus(eventHotKeyExistsErr))
    }

    private func checkShortcutRecorder() throws {
        let suite = "LangyRecorderChecks.\(UUID().uuidString)"
        let defaults = require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let manager = HotKeyManager(defaults: defaults)
        let modifiers = UInt32(controlKey | optionKey | cmdKey | shiftKey)
        let original = KeyboardShortcut(keyCode: UInt32(kVK_F17), modifiers: modifiers)
        let settingsKey = KeyboardShortcut(keyCode: UInt32(kVK_F18), modifiers: modifiers)
        defaults.set(try JSONEncoder().encode(original), forKey: HotKeyManager.Action.convert.defaultsKey)
        defaults.set(try JSONEncoder().encode(settingsKey), forKey: HotKeyManager.Action.settings.defaultsKey)
        precondition(manager.register().isEmpty)
        let controller = settings(system: true, hotkeys: manager)

        func sheetButton(_ title: String) -> NSButton {
            let sheet = require(controller.window?.attachedSheet)
            return require(descendants(of: require(sheet.contentView)).compactMap { $0 as? NSButton }.first { $0.title == title })
        }
        func press(_ code: Int, flags: NSEvent.ModifierFlags) {
            let sheet = require(controller.window?.attachedSheet)
            let event = require(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: flags,
                timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: sheet.windowNumber,
                context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: UInt16(code)))
            precondition(event.keyCode == UInt16(code))
            NSApp.sendEvent(event)
        }
        func finish() {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            precondition(!manager.isRecording)
            precondition(controller.window?.attachedSheet == nil)
        }

        button("Rewrite Switch Hotkey", in: controller).performClick(nil)
        precondition(manager.isRecording)
        press(kVK_ANSI_K, flags: [])
        precondition(!sheetButton("Save").isEnabled)
        press(kVK_F18, flags: [.control, .option, .command, .shift])
        precondition(!sheetButton("Save").isEnabled)
        precondition(manager.shortcut(for: .settings) == settingsKey)
        try manager.validate(KeyboardShortcut(keyCode: UInt32(kVK_F19), modifiers: modifiers), for: .convert)
        press(kVK_F19, flags: [.control, .option, .command, .shift])
        let recordingHint = require(descendants(of: require(controller.window?.attachedSheet?.contentView)).compactMap { $0 as? NSTextField }.first { $0.identifier?.rawValue == "hotkey.hint" })
        precondition(sheetButton("Save").isEnabled, recordingHint.stringValue)
        press(kVK_Tab, flags: [])
        press(kVK_Tab, flags: .shift)
        precondition(sheetButton("Save").isEnabled, "Keyboard navigation erased the recorded shortcut")
        sheetButton("Save").performClick(nil)
        finish()
        let saved = KeyboardShortcut(keyCode: UInt32(kVK_F19), modifiers: modifiers)
        precondition(manager.shortcut(for: .convert) == saved)
        let label = require(descendants(of: require(controller.window?.contentView)).compactMap { $0 as? NSTextField }.first { $0.identifier?.rawValue == "shortcut.0.label" })
        precondition(label.stringValue == "Switch: \(saved.displayString)")

        button("Rewrite Switch Hotkey", in: controller).performClick(nil)
        press(kVK_F20, flags: [.control, .option, .command, .shift])
        press(kVK_Escape, flags: [])
        finish()
        precondition(manager.shortcut(for: .convert) == saved)

        button("Rewrite Settings Hotkey", in: controller).performClick(nil)
        NotificationCenter.default.post(name: NSApplication.didResignActiveNotification, object: NSApp)
        finish()
        precondition(manager.shortcut(for: .settings) == settingsKey)

        button("Rewrite Settings Hotkey", in: controller).performClick(nil)
        press(kVK_F20, flags: [.control, .option, .command, .shift])
        sheetButton("Save").performClick(nil)
        finish()
        let newSettings = KeyboardShortcut(keyCode: UInt32(kVK_F20), modifiers: modifiers)
        precondition(manager.shortcut(for: .settings) == newSettings)
        precondition(switchHost("Show icon in menu bar", in: controller).accessibilityHelp()?.contains(newSettings.displayString) == true)

        let defaultClaim = claim(HotKeyManager.Action.convert.defaultShortcut)
        if defaultClaim.0 == noErr {
            UnregisterEventHotKey(require(defaultClaim.1))
            button("Rewrite Switch Hotkey", in: controller).performClick(nil)
            sheetButton("Use Default").performClick(nil)
            finish()
            precondition(manager.shortcut(for: .convert) == HotKeyManager.Action.convert.defaultShortcut)
        } else {
            print("NOTE: Default-reset registration check skipped; another app owns the default shortcut.")
        }
    }

    private func renderSnapshots() throws {
        let directory = ProcessInfo.processInfo.environment["LANGY_SNAPSHOT_DIR"]
        for system in [true, false] {
            let controller = settings(system: system)
            let window = require(controller.window)
            for appearance in [NSAppearance.Name.aqua, .darkAqua] {
                window.appearance = NSAppearance(named: appearance)
                let root = require(descendants(of: require(window.contentView)).first { $0.identifier?.rawValue == "settings.content" })
                root.layoutSubtreeIfNeeded()
                root.display()
                let image = require(root.bitmapImageRepForCachingDisplay(in: root.bounds))
                root.cacheDisplay(in: root.bounds, to: image)
                // Window-server glass is not captured by cacheDisplay; use a neutral matte for layout previews.
                let context = require(CGContext(
                    data: nil, width: image.pixelsWide, height: image.pixelsHigh,
                    bitsPerComponent: 8, bytesPerRow: 0,
                    space: require(CGColorSpace(name: CGColorSpace.sRGB)),
                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
                ))
                let pixels = CGRect(x: 0, y: 0, width: image.pixelsWide, height: image.pixelsHigh)
                window.effectiveAppearance.performAsCurrentDrawingAppearance {
                    context.setFillColor(NSColor.windowBackgroundColor.cgColor)
                    context.fill(pixels)
                }
                context.draw(require(image.cgImage), in: pixels)
                let bitmap = NSBitmapImageRep(cgImage: require(context.makeImage()))
                let png = require(bitmap.representation(using: .png, properties: [:]))
                let mode = system ? "system" : "manual"
                precondition(!png.isEmpty)
                if let directory {
                    try png.write(to: URL(fileURLWithPath: directory).appendingPathComponent("settings-\(mode)-\(appearance.rawValue).png"))
                }
            }
        }
    }

    private func checkMenuBarRuntime() throws {
        let delegate = require(NSApp.delegate as? AppDelegate)
        delegate.showsMenuBarIcon = false
        delegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        let item = require(Mirror(reflecting: delegate).children.first { $0.label == "statusItem" }?.value as? NSStatusItem)
        precondition(!item.isVisible)
        delegate.showsMenuBarIcon = true
        precondition(item.isVisible)
        delegate.showsMenuBarIcon = false
        precondition(!item.isVisible)
        precondition(HotKeyManager.shared.onConvert != nil)
        precondition(item.menu?.items[0].title == "Switch: ⇧⌥L")
        precondition(item.menu?.items[1].title == "Open Settings: ⌃⌘⌥L")
        precondition(item.menu?.items[2].identifier?.rawValue == "langy.status")
        precondition(["Ready", "Shortcut unavailable"].contains(item.menu?.items[2].title))
        delegate.showConversionResult(.success)
        precondition(item.menu?.items[2].title == "Layout switched")
        delegate.showConversionResult(.permissionMissing)
        precondition(item.menu?.items[2].title == "Accessibility permission required")
        delegate.showConversionResult(.failure)
        precondition(item.menu?.items[2].title == "Couldn't switch layout")
        let custom = KeyboardShortcut(keyCode: UInt32(kVK_F20), modifiers: UInt32(controlKey | optionKey | cmdKey | shiftKey))
        try HotKeyManager.shared.setShortcut(custom, for: .convert)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        precondition(item.menu?.items[0].title == "Switch: \(custom.displayString)")
        precondition(item.button?.toolTip?.contains(custom.displayString) == true)
        require(HotKeyManager.shared.onSettings)()
        precondition(SettingsWindowController.shared.window?.isVisible == true)
        SettingsWindowController.shared.close()
        precondition(delegate.applicationShouldHandleReopen(NSApp, hasVisibleWindows: false))
        precondition(SettingsWindowController.shared.window?.isVisible == true)
        SettingsWindowController.shared.close()
        NSStatusBar.system.removeStatusItem(item)
    }
}
