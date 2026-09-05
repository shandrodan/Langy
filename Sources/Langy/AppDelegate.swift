import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var flashGeneration = 0

    var showsMenuBarIcon: Bool {
        get {
            UserDefaults.standard.object(forKey: "langy.showMenuBarIcon") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "langy.showMenuBarIcon")
            statusItem?.isVisible = newValue
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar icon with persistent visibility.
        // Idle state is white; flashes green on launch/switch, orange for
        // missing permission, red for failure. Never any center-screen UI.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.toolTip = "Langy — ⇧⌥L fixes layout"
        }
        setIconColor(.white)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Fix layout  (⇧⌥L)", action: #selector(convertNow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Settings…  (⌃⌘⌥L)", action: #selector(openSettings), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Langy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
        statusItem?.isVisible = showsMenuBarIcon

        HotKeyManager.shared.onConvert = { [weak self] in self?.convertNow() }
        HotKeyManager.shared.onSettings = { [weak self] in self?.openSettings() }
        HotKeyManager.shared.register()

        // Launch signal: green briefly, then back to white.
        flash(.systemGreen, duration: 0.6)

        // Ask for Accessibility once (needed to swap the selection).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            TextSwapper.shared.requestAccessIfNeeded()
        }
    }

    // MARK: - Menu-bar indicator

    private func setIconColor(_ color: NSColor) {
        guard let button = statusItem?.button else { return }
        let font = button.font ?? .systemFont(ofSize: 16, weight: .medium)
        button.attributedTitle = NSAttributedString(
            string: "⌘",
            attributes: [.foregroundColor: color, .font: font]
        )
    }

    private func flash(_ color: NSColor, duration: TimeInterval = 0.6) {
        flashGeneration += 1
        let generation = flashGeneration
        setIconColor(color)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self, self.flashGeneration == generation else { return }
            self.setIconColor(.white)
        }
    }

    @objc private func convertNow() {
        switch TextSwapper.shared.convertSelection() {
        case .success:
            flash(.systemGreen, duration: 0.6)
        case .permissionMissing:
            flash(.systemOrange, duration: 0.6)
        case .failure:
            flash(.systemRed, duration: 0.6)
        }
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.show()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Reopening the app is a recovery path when the icon is hidden and a shortcut is unavailable.
        SettingsWindowController.shared.show()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}
