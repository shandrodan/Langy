import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var flashGeneration = 0
    private var fadeTimer: Timer?
    private var fadeTarget: NSColor?
    private var fadeCompletion: (() -> Void)?
    private var currentIconColor: NSColor = .labelColor
    private var appearanceObservation: NSKeyValueObservation?
    private var displayOptionsObserver: NSObjectProtocol?
    private var statusText = "Ready"
    private var shortcutErrors: [String] = []
    /// Serial so rapid presses queue instead of overlapping swaps.
    private let workQueue = DispatchQueue(label: "langy.convert", qos: .userInitiated)

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
        // Adaptive idle color; green on launch/switch, orange for missing
        // permission, red for failure. Outcome text persists after each fade.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        setIconColor(.labelColor)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Switch", action: #selector(convertNow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open Settings", action: #selector(openSettings), keyEquivalent: ""))
        let status = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        status.identifier = NSUserInterfaceItemIdentifier("langy.status")
        status.isEnabled = false
        menu.addItem(status)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Langy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
        statusItem?.isVisible = showsMenuBarIcon

        displayOptionsObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.settleIconAppearance()
        }
        appearanceObservation = statusItem?.button?.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
            self?.settleIconAppearance()
        }

        HotKeyManager.shared.onConvert = { [weak self] in self?.convertNow() }
        HotKeyManager.shared.onSettings = { [weak self] in self?.openSettings() }
        HotKeyManager.shared.onShortcutsChanged = { [weak self] in self?.refreshShortcuts() }
        refreshShortcuts()

        // Keep the infrequent launch breath only when shortcuts and motion are available.
        if shortcutErrors.isEmpty && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            flashGeneration += 1
            let launchGen = flashGeneration
            fadeIcon(to: .systemGreen, duration: 0.25) { [weak self] in
                self?.fadeBackToIdle(gen: launchGen, after: 0.35, duration: 0.35)
            }
        }

        // Ask for Accessibility once (needed to swap the selection).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            TextSwapper.shared.requestAccessIfNeeded()
        }
    }

    // MARK: - Menu-bar indicator

    private func refreshShortcuts() {
        let manager = HotKeyManager.shared
        shortcutErrors = manager.register()
        for (action, selector) in [(HotKeyManager.Action.convert, #selector(convertNow)), (.settings, #selector(openSettings))] {
            statusItem?.menu?.items.first { $0.action == selector }?.title =
                "\(action.title): \(manager.shortcut(for: action).displayString)"
        }
        if shortcutErrors.isEmpty {
            setStatus(statusText == "Shortcut unavailable" ? "Ready" : statusText)
        } else {
            setStatus("Shortcut unavailable")
        }
    }

    private func setStatus(_ text: String) {
        statusText = text
        statusItem?.menu?.items.first { $0.identifier?.rawValue == "langy.status" }?.title = text
        let shortcut = HotKeyManager.shared.shortcut(for: .convert).displayString
        var tooltip = "Langy — \(shortcut) fixes layout\n\(text)"
        if !shortcutErrors.isEmpty {
            if text != "Shortcut unavailable" { tooltip += "\nShortcut unavailable" }
            tooltip += "\n" + shortcutErrors.joined(separator: "\n")
        }
        statusItem?.button?.toolTip = tooltip
        statusItem?.button?.setAccessibilityLabel("Langy: \(text)")
        statusItem?.button?.setAccessibilityValue(text)
        statusItem?.button?.setAccessibilityHelp(tooltip)
    }

    private func setIconColor(_ color: NSColor) {
        currentIconColor = color
        guard let button = statusItem?.button else { return }
        let font = button.font ?? .systemFont(ofSize: 16, weight: .medium)
        button.attributedTitle = NSAttributedString(
            string: "⌘",
            attributes: [.foregroundColor: color, .font: font]
        )
    }

    /// Smoothstep by monotonic elapsed time; superseded completions are discarded.
    private func fadeIcon(to target: NSColor, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        fadeTimer = nil
        fadeTarget = target
        fadeCompletion = completion
        guard duration > 0, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            finishFade()
            return
        }

        var start = currentIconColor
        var end = target
        statusItem?.button?.effectiveAppearance.performAsCurrentDrawingAppearance {
            start = start.usingColorSpace(.sRGB) ?? start
            end = end.usingColorSpace(.sRGB) ?? end
        }
        let startedAt = ProcessInfo.processInfo.systemUptime
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            guard let self, self.fadeTimer === timer else { timer.invalidate(); return }
            let f = min(1.0, (ProcessInfo.processInfo.systemUptime - startedAt) / duration)
            if f >= 1.0 {
                self.finishFade()
                return
            }
            let eased = f * f * (3 - 2 * f)
            self.setIconColor(start.blended(withFraction: eased, of: end) ?? end)
        }
        fadeTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func finishFade() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        let target = fadeTarget
        let completion = fadeCompletion
        fadeTarget = nil
        fadeCompletion = nil
        if let target { setIconColor(target) }
        completion?()
    }

    private func settleIconAppearance() {
        // Snap to the semantic endpoint in the new appearance, without invalidating queued work.
        if fadeTarget != nil {
            finishFade()
        } else {
            setIconColor(currentIconColor)
        }
    }

    private func fadeBackToIdle(gen: Int, after hold: TimeInterval, duration: TimeInterval = 0.15) {
        guard gen == flashGeneration else { return }
        fadeTimer?.invalidate()
        let timer = Timer(timeInterval: hold, repeats: false) { [weak self] timer in
            guard let self, self.fadeTimer === timer, gen == self.flashGeneration else { timer.invalidate(); return }
            self.fadeIcon(to: .labelColor, duration: duration)
        }
        fadeTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc private func convertNow() {
        flashGeneration += 1
        let gen = flashGeneration
        setStatus("Switching layout…")
        fadeIcon(to: .systemGreen, duration: 0.15) // fade in: swap starting
        workQueue.async { [weak self] in
            let outcome = TextSwapper.shared.convertSelection()
            DispatchQueue.main.async { [weak self] in
                guard let self, gen == self.flashGeneration else { return }
                self.showConversionResult(outcome)
            }
        }
    }

    func showConversionResult(_ outcome: ConversionOutcome) {
        // Direct result presentation also supersedes pending resets and stale UI results.
        flashGeneration += 1
        let gen = flashGeneration
        switch outcome {
        case .success:
            setStatus("Layout switched")
            fadeIcon(to: .labelColor, duration: 0.15)
        case .permissionMissing:
            setStatus("Accessibility permission required")
            fadeIcon(to: .systemOrange, duration: 0.15) { [weak self] in
                self?.fadeBackToIdle(gen: gen, after: 0.5)
            }
        case .failure:
            setStatus("Couldn't switch layout")
            fadeIcon(to: .systemRed, duration: 0.15) { [weak self] in
                self?.fadeBackToIdle(gen: gen, after: 0.5)
            }
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

    deinit {
        fadeTimer?.invalidate()
        appearanceObservation?.invalidate()
        if let displayOptionsObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(displayOptionsObserver)
        }
    }
}
