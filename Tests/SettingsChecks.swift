import AppKit

/// Standalone AppKit regression checks; no XCTest or full Xcode installation needed.
@main
final class SettingsChecks {
    private var controllers: [SettingsWindowController] = []

    static func main() throws {
        precondition(Thread.isMainThread)
        _ = NSApplication.shared
        let delegate = AppDelegate()
        NSApp.delegate = delegate
        let keys = ["langy.useSystemLayouts", "langy.customLayouts", "langy.disabledLayoutIDs", "langy.showMenuBarIcon"]
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
            ("Light and dark rendering", checks.renderSnapshots),
            ("Live menu-bar visibility and hidden-icon recovery", checks.checkMenuBarRuntime)
        ]
        for (name, run) in cases {
            for key in keys { UserDefaults.standard.removeObject(forKey: key) }
            try run()
            checks.controllers.forEach { $0.close() }
            checks.controllers.removeAll()
            print("PASS: \(name)")
        }
        print("All \(cases.count) settings checks passed.")
    }

    private func require<T>(_ value: T?, file: StaticString = #file, line: UInt = #line) -> T {
        guard let value else { fatalError("Required UI element is missing", file: file, line: line) }
        return value
    }

    private func settings(system: Bool) -> SettingsWindowController {
        LayoutStore.shared.useSystemLayouts = system
        let controller = SettingsWindowController()
        controllers.append(controller)
        return controller
    }

    private func descendants(of view: NSView) -> [NSView] {
        [view] + view.subviews.flatMap { descendants(of: $0) }
    }

    private func button(_ title: String, in controller: SettingsWindowController) -> NSButton {
        require(descendants(of: controller.window!.contentView!).compactMap { $0 as? NSButton }.first { $0.title == title })
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
            let root = require(window.contentView)
            precondition(root.bounds.width == 400)
            precondition(window.frame.height <= 650)
            for view in root.subviews { precondition(root.bounds.contains(view.frame), "Clipped view: \(view)") }
            for title in ["Use system keyboard layouts", "Show icon in menu bar", "Launch on startup",
                          "Open Accessibility Settings...", "Quit & Reopen", "Quit Completely", "made by dan"] {
                precondition(button(title, in: controller).action != nil)
            }
            precondition(descendants(of: root).contains { $0 is NSSearchField } == !system)
            precondition(descendants(of: root).contains { $0 is NSTableView } == !system)
            if !system {
                let layouts = table(in: controller)
                layouts.layoutSubtreeIfNeeded()
                let cell = require(layouts.view(atColumn: 1, row: 3, makeIfNecessary: true))
                let toggle = require(cell.subviews.first)
                precondition(cell.bounds.contains(toggle.frame), "Layout toggle overflows its cell")
                precondition(layouts.visibleRect.contains(toggle.convert(toggle.bounds, to: layouts)), "The fourth layout toggle is clipped")
            }
        }
    }

    private func checkSystemSwitch() {
        let custom = KeyboardLayout(id: "custom.test", name: "Test", map: ["q": "x"], isSystem: false)
        LayoutStore.shared.addCustom(custom)
        let controller = settings(system: true)
        let compactHeight = controller.window!.frame.height
        let toggle = button("Use system keyboard layouts", in: controller)
        precondition(toggle.accessibilityValue() as? Int == 1)
        toggle.performClick(nil)
        precondition(!LayoutStore.shared.useSystemLayouts)
        precondition(controller.window!.frame.height > compactHeight)
        precondition(table(in: controller).numberOfRows > 0)
        button("Use system keyboard layouts", in: controller).performClick(nil)
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
        let cell = require(controller.tableView(table, viewFor: table.tableColumns[1], row: 0))
        let toggle = require(cell.subviews.first as? NSButton)
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
        button("Show icon in menu bar", in: controller).performClick(nil)
        precondition(!delegate.showsMenuBarIcon)
        precondition(!AppDelegate().showsMenuBarIcon)
        let reopened = settings(system: true)
        let toggle = button("Show icon in menu bar", in: reopened)
        precondition(toggle.state == .off)
        precondition(toggle.accessibilityHelp()?.contains("hidden") == true)
        toggle.performClick(nil)
        precondition(delegate.showsMenuBarIcon)
    }

    private func renderSnapshots() throws {
        let directory = ProcessInfo.processInfo.environment["LANGY_SNAPSHOT_DIR"]
        for system in [true, false] {
            let controller = settings(system: system)
            let window = require(controller.window)
            for appearance in [NSAppearance.Name.aqua, .darkAqua] {
                window.appearance = NSAppearance(named: appearance)
                let root = require(window.contentView?.superview)
                root.layoutSubtreeIfNeeded()
                root.display()
                let image = require(root.bitmapImageRepForCachingDisplay(in: root.bounds))
                root.cacheDisplay(in: root.bounds, to: image)
                // cacheDisplay excludes NSWindow's backing surface; composite it for a faithful preview.
                let composite = NSImage(size: root.bounds.size)
                composite.lockFocus()
                window.effectiveAppearance.performAsCurrentDrawingAppearance {
                    window.backgroundColor.setFill()
                    root.bounds.fill()
                }
                image.draw(in: root.bounds)
                composite.unlockFocus()
                let bitmap = require(NSBitmapImageRep(data: require(composite.tiffRepresentation)))
                let png = require(bitmap.representation(using: .png, properties: [:]))
                let mode = system ? "system" : "manual"
                precondition(!png.isEmpty)
                if let directory {
                    try png.write(to: URL(fileURLWithPath: directory).appendingPathComponent("settings-\(mode)-\(appearance.rawValue).png"))
                }
            }
        }
    }

    private func checkMenuBarRuntime() {
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
        require(HotKeyManager.shared.onSettings)()
        precondition(SettingsWindowController.shared.window?.isVisible == true)
        SettingsWindowController.shared.close()
        precondition(delegate.applicationShouldHandleReopen(NSApp, hasVisibleWindows: false))
        precondition(SettingsWindowController.shared.window?.isVisible == true)
        SettingsWindowController.shared.close()
        NSStatusBar.system.removeStatusItem(item)
    }
}
