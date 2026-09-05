import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var flashGeneration = 0
    private var fadeTimer: Timer?
    private var currentIconColor: NSColor = .white
    /// Serial so rapid presses queue instead of overlapping swaps.
    private let workQueue = DispatchQueue(label: "langy.convert", qos: .userInitiated)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar icon — light footprint, always reachable.
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

        HotKeyManager.shared.onConvert = { [weak self] in self?.convertNow() }
        HotKeyManager.shared.onSettings = { [weak self] in self?.openSettings() }
        HotKeyManager.shared.register()

        // Launch signal: gentle green breath, then back to white.
        flashGeneration += 1
        let launchGen = flashGeneration
        fadeIcon(to: .systemGreen, duration: 0.25) { [weak self] in
            self?.fadeBackToWhite(gen: launchGen, after: 0.35)
        }

        // Ask for Accessibility once (needed to swap the selection).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            TextSwapper.shared.requestAccessIfNeeded()
        }
    }

    // MARK: - Menu-bar indicator

    // The icon is a live signal, not a fixed blink: it fades in green the
    // moment a swap starts, holds exactly while the operation runs, and fades
    // out the instant the text lands. All transitions ease — nothing snaps.

    private func setIconColor(_ color: NSColor) {
        currentIconColor = color
        guard let button = statusItem?.button else { return }
        let font = button.font ?? .systemFont(ofSize: 16, weight: .medium)
        button.attributedTitle = NSAttributedString(
            string: "⌘",
            attributes: [.foregroundColor: color, .font: font]
        )
    }

    /// Eased fade to a color (smoothstep, 60fps). Cancels any fade in flight.
    private func fadeIcon(to target: NSColor, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        let start = currentIconColor
        let steps = max(1, Int(duration * 60))
        var i = 0
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            i += 1
            let f = min(1.0, Double(i) / Double(steps))
            let eased = f * f * (3 - 2 * f)
            self.setIconColor(start.blended(withFraction: eased, of: target) ?? target)
            if f >= 1.0 { timer.invalidate(); completion?() }
        }
    }

    private func fadeBackToWhite(gen: Int, after hold: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + hold) { [weak self] in
            guard let self, gen == self.flashGeneration else { return }
            self.fadeIcon(to: .white, duration: 0.35)
        }
    }

    @objc private func convertNow() {
        flashGeneration += 1
        let gen = flashGeneration
        fadeIcon(to: .systemGreen, duration: 0.15) // fade in: swap starting
        workQueue.async { [weak self] in
            let outcome = TextSwapper.shared.convertSelection()
            DispatchQueue.main.async { [weak self] in
                guard let self, gen == self.flashGeneration else { return }
                switch outcome {
                case .success:
                    // Landed — green goes away now.
                    self.fadeIcon(to: .white, duration: 0.35)
                case .permissionMissing:
                    self.fadeIcon(to: .systemOrange, duration: 0.15) {
                        self.fadeBackToWhite(gen: gen, after: 0.5)
                    }
                case .failure:
                    self.fadeIcon(to: .systemRed, duration: 0.15) {
                        self.fadeBackToWhite(gen: gen, after: 0.5)
                    }
                }
            }
        }
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.show()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}
