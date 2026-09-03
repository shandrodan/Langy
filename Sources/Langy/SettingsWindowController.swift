import AppKit

/// Native-looking translucent settings window (⌃⌘⌥L).
/// Liquid Glass on macOS 26+, sidebar vibrancy below that.
final class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    private var useSystemBox: NSButton!
    private var descLabel: NSTextField!
    private var searchField: NSSearchField!
    private var table: NSTableView!
    private var countLabel: NSTextField!
    private var launchBox: NSButton!
    private var permissionLabel: NSTextField!

    private var allRows: [KeyboardLayout] = []
    private var filter: String = ""
    private var rows: [KeyboardLayout] {
        guard !filter.isEmpty else { return allRows }
        return allRows.filter { $0.name.localizedCaseInsensitiveContains(filter) }
    }

    private static let width: CGFloat = 480
    private static let pad: CGFloat = 20

    init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: Self.width, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        win.title = "Langy"
        win.titlebarAppearsTransparent = true
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = true
        win.isReleasedWhenClosed = false
        super.init(window: win)
        buildContent()
        reload()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func show() {
        LayoutStore.shared.refreshSystemLayouts()
        reload()
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Build

    private func buildContent() {
        guard let win = window else { return }
        let root = NSView(frame: win.contentView!.bounds)
        root.autoresizingMask = [.width, .height]
        win.contentView = root

        let bg = makeBackground()
        bg.frame = root.bounds
        root.addSubview(bg)

        var y = root.bounds.height - 64 // below traffic lights

        // MARK: Layouts section
        y = addSectionHeader("Keyboard Layouts", at: y, in: root)
        descLabel = NSTextField(wrappingLabelWithString: "")
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabelColor
        y = add(descLabel, height: 32, topGap: 4, at: y, in: root)
        useSystemBox = NSButton(checkboxWithTitle: "Use system layouts", target: self, action: #selector(toggleUseSystem(_:)))
        useSystemBox.font = .systemFont(ofSize: 13)
        y = add(useSystemBox, height: 20, topGap: 10, at: y, in: root)

        searchField = NSSearchField()
        searchField.placeholderString = "Search layouts"
        searchField.target = self
        searchField.action = #selector(filterChanged(_:))
        searchField.sendsSearchStringImmediately = true
        y = add(searchField, height: 26, topGap: 10, at: y, in: root)

        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.borderType = .bezelBorder
        scroll.drawsBackground = false
        table = NSTableView()
        let enabledCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("enabled"))
        enabledCol.title = ""
        enabledCol.width = 32
        let checkCell = NSButtonCell()
        checkCell.setButtonType(.switch)
        checkCell.title = ""
        enabledCol.dataCell = checkCell
        let nameCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
        nameCol.title = "Layout"
        nameCol.width = Self.width - Self.pad * 2 - 34
        table.addTableColumn(enabledCol)
        table.addTableColumn(nameCol)
        table.delegate = self
        table.dataSource = self
        table.headerView = nil
        table.backgroundColor = .clear
        table.usesAlternatingRowBackgroundColors = true
        table.rowHeight = 22
        scroll.documentView = table
        y = add(scroll, height: 236, topGap: 8, at: y, in: root)

        let btnRow = NSView()
        let addBtn = NSButton(title: "Add…", target: self, action: #selector(addCustom(_:)))
        addBtn.bezelStyle = .rounded
        addBtn.frame = NSRect(x: 0, y: 0, width: 72, height: 26)
        let delBtn = NSButton(title: "Remove", target: self, action: #selector(removeSelected(_:)))
        delBtn.bezelStyle = .rounded
        delBtn.frame = NSRect(x: 80, y: 0, width: 84, height: 26)
        countLabel = NSTextField(labelWithString: "")
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .secondaryLabelColor
        countLabel.alignment = .right
        countLabel.frame = NSRect(x: 172, y: 3, width: Self.width - Self.pad * 2 - 172, height: 20)
        btnRow.addSubview(addBtn)
        btnRow.addSubview(delBtn)
        btnRow.addSubview(countLabel)
        y = add(btnRow, height: 26, topGap: 10, at: y, in: root)

        y = addSeparator(at: y, in: root)

        // MARK: General section
        y = addSectionHeader("General", at: y, in: root)
        launchBox = NSButton(checkboxWithTitle: "Launch on startup", target: self, action: #selector(toggleLaunch(_:)))
        launchBox.font = .systemFont(ofSize: 13)
        y = add(launchBox, height: 20, topGap: 10, at: y, in: root)

        permissionLabel = NSTextField(wrappingLabelWithString: "")
        permissionLabel.font = .systemFont(ofSize: 12)
        y = add(permissionLabel, height: 32, topGap: 10, at: y, in: root)

        let permRow = NSView()
        let permBtn = NSButton(title: "Open Accessibility Settings…", target: self, action: #selector(openAccessibility(_:)))
        permBtn.bezelStyle = .rounded
        permBtn.frame = NSRect(x: 0, y: 0, width: 220, height: 26)
        let relaunchBtn = NSButton(title: "Quit & Reopen", target: self, action: #selector(relaunch(_:)))
        relaunchBtn.bezelStyle = .rounded
        relaunchBtn.toolTip = "Needed after flipping the Accessibility switch"
        relaunchBtn.frame = NSRect(x: 228, y: 0, width: 120, height: 26)
        permRow.addSubview(permBtn)
        permRow.addSubview(relaunchBtn)
        y = add(permRow, height: 26, topGap: 8, at: y, in: root)

        let quitBtn = NSButton(title: "Quit Langy Completely", target: self, action: #selector(quitApp(_:)))
        quitBtn.bezelStyle = .rounded
        y = add(quitBtn, height: 28, topGap: 10, at: y, in: root, fullWidth: false, width: 190)

        // MARK: Footer
        let footer = NSButton(title: "made by dan", target: self, action: #selector(openSite(_:)))
        footer.isBordered = false
        footer.font = .systemFont(ofSize: 12)
        footer.alignment = .center
        let attr = NSMutableAttributedString(string: "made by dan")
        attr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attr.length))
        attr.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: NSRange(location: 0, length: attr.length))
        footer.attributedTitle = attr
        y = add(footer, height: 20, topGap: 14, at: y, in: root)

        let version = NSTextField(labelWithString: "v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?")")
        version.font = .systemFont(ofSize: 11)
        version.textColor = .tertiaryLabelColor
        version.alignment = .center
        y = add(version, height: 15, topGap: 2, at: y, in: root)

        // Shrink window to fit content exactly.
        if let win = window {
            let used = root.bounds.height - y
            let targetH = used + 16
            var frame = win.frame
            frame.size.height = targetH
            frame.origin.y += win.frame.height - targetH
            win.setFrame(frame, display: true)
        }
    }

    private func makeBackground() -> NSView {
        if #available(macOS 26, *) {
            let glass = NSGlassEffectView()
            glass.style = .regular
            glass.cornerRadius = 0
            glass.autoresizingMask = [.width, .height]
            return glass
        } else {
            let vev = NSVisualEffectView()
            vev.material = .sidebar
            vev.blendingMode = .behindWindow
            vev.state = .active
            vev.autoresizingMask = [.width, .height]
            return vev
        }
    }

    // MARK: - Layout helpers (coordinates measured from top)

    @discardableResult
    private func add(_ view: NSView, height: CGFloat, topGap: CGFloat, at y: CGFloat, in root: NSView, fullWidth: Bool = true, width: CGFloat = 0) -> CGFloat {
        let ny = y - height - topGap
        let w = fullWidth ? Self.width - Self.pad * 2 : width
        view.frame = NSRect(x: Self.pad, y: ny, width: w, height: height)
        view.autoresizingMask = [.width, .maxYMargin]
        root.addSubview(view)
        return ny
    }

    private func addSectionHeader(_ text: String, at y: CGFloat, in root: NSView) -> CGFloat {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return add(label, height: 18, topGap: y == root.bounds.height - 64 ? 0 : 16, at: y, in: root)
    }

    private func addSeparator(at y: CGFloat, in root: NSView) -> CGFloat {
        let box = NSBox()
        box.boxType = .separator
        return add(box, height: 5, topGap: 14, at: y, in: root)
    }

    // MARK: - Data

    private func isCustom(_ layout: KeyboardLayout) -> Bool {
        !layout.isSystem && !layout.id.hasPrefix("builtin.")
    }

    private func displayName(_ layout: KeyboardLayout) -> String {
        isCustom(layout) ? "\(layout.name) (Custom)" : layout.name
    }

    private func reload() {
        allRows = LayoutStore.shared.allKnownLayouts()
        let useSystem = LayoutStore.shared.useSystemLayouts
        useSystemBox?.state = useSystem ? .on : .off
        descLabel?.stringValue = useSystem
            ? "With text selected, ⇧⌥L retypes the selection; with a plain caret, the whole field. Press again for the next of your installed keyboards."
            : "With text selected, ⇧⌥L retypes the selection; with a plain caret, the whole field. Press again for the next built-in or custom layout."
        launchBox?.state = StartupManager.isEnabled ? .on : .off
        table?.reloadData()
        let enabled = LayoutStore.shared.effectiveLayouts().count
        countLabel?.stringValue = "\(enabled) of \(allRows.count) enabled"
        refreshPermissionRow()
    }

    private func refreshPermissionRow() {
        guard let permissionLabel else { return }
        if TextSwapper.shared.isTrusted {
            permissionLabel.textColor = .secondaryLabelColor
            permissionLabel.stringValue = "Accessibility: allowed — text swapping works."
        } else {
            permissionLabel.textColor = .systemOrange
            permissionLabel.stringValue = "Accessibility: not allowed — Langy can't swap text yet. " +
                "Flip the switch, then Quit & Reopen."
        }
    }

    // MARK: - Actions

    @objc private func toggleUseSystem(_ sender: NSButton) {
        LayoutStore.shared.useSystemLayouts = sender.state == .on
        reload()
    }

    @objc private func toggleLaunch(_ sender: NSButton) {
        StartupManager.setEnabled(sender.state == .on)
        sender.state = StartupManager.isEnabled ? .on : .off
    }

    @objc private func openAccessibility(_ sender: NSButton) {
        TextSwapper.shared.openAccessibilitySettings()
    }

    @objc private func relaunch(_ sender: NSButton) {
        let appURL = Bundle.main.bundleURL
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = [appURL.path]
        try? task.run()
        NSApp.terminate(nil)
    }

    @objc private func quitApp(_ sender: NSButton) {
        NSApp.terminate(nil)
    }

    @objc private func openSite(_ sender: NSButton) {
        if let url = URL(string: "https://danshandro.com") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func filterChanged(_ sender: NSSearchField) {
        filter = sender.stringValue.trimmingCharacters(in: .whitespaces)
        table.reloadData()
    }

    @objc private func removeSelected(_ sender: NSButton) {
        let sel = table.selectedRow
        guard sel >= 0, sel < rows.count else { return }
        let layout = rows[sel]
        guard isCustom(layout) else { return } // system & built-in rows toggle via checkbox
        LayoutStore.shared.removeCustom(id: layout.id)
        var disabled = LayoutStore.shared.disabledIDs
        disabled.remove(layout.id)
        LayoutStore.shared.disabledIDs = disabled
        reload()
    }

    @objc private func addCustom(_ sender: NSButton) {
        guard let win = window else { return }
        let sheet = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 220),
            styleMask: [.titled], backing: .buffered, defer: false
        )
        sheet.title = "Extra layout"
        let nameField = NSTextField(string: "")
        nameField.placeholderString = "Name"
        nameField.frame = NSRect(x: 20, y: 160, width: 340, height: 24)
        let enField = NSTextField(string: "")
        enField.placeholderString = "Home chars, e.g. qwerty…"
        enField.frame = NSRect(x: 20, y: 120, width: 340, height: 24)
        let mapField = NSTextField(string: "")
        mapField.placeholderString = "Mapped chars, same length"
        mapField.frame = NSRect(x: 20, y: 80, width: 340, height: 24)
        let hint = NSTextField(wrappingLabelWithString: "Both rows must be the same length — position 1 maps to position 1, etc.")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .secondaryLabelColor
        hint.frame = NSRect(x: 20, y: 44, width: 340, height: 28)
        let ok = NSButton(title: "Add", target: self, action: #selector(endAddSheet(_:)))
        ok.bezelStyle = .rounded
        ok.keyEquivalent = "\r"
        ok.frame = NSRect(x: 280, y: 10, width: 80, height: 28)
        for v in [nameField, enField, mapField, hint, ok] as [NSView] {
            sheet.contentView?.addSubview(v)
        }
        win.beginSheet(sheet) { [weak self] _ in
            let name = nameField.stringValue.trimmingCharacters(in: .whitespaces)
            let en = Array(enField.stringValue)
            let mp = Array(mapField.stringValue)
            guard !name.isEmpty, !en.isEmpty, en.count == mp.count else {
                return
            }
            var map: [String: String] = [:]
            for (a, b) in zip(en, mp) { map[String(a).lowercased()] = String(b) }
            LayoutStore.shared.addCustom(KeyboardLayout(
                id: "custom.\(UUID().uuidString)",
                name: name, map: map, isSystem: false
            ))
            self?.reload()
        }
    }

    @objc private func endAddSheet(_ sender: NSButton) {
        if let sheet = sender.window {
            window?.endSheet(sheet)
            sheet.orderOut(nil)
        }
    }
}

// MARK: - Table

extension SettingsWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int { rows.count }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < rows.count else { return nil }
        let layout = rows[row]
        if tableColumn?.identifier.rawValue == "enabled" {
            return LayoutStore.shared.disabledIDs.contains(layout.id) ? NSControl.StateValue.off.rawValue : NSControl.StateValue.on.rawValue
        }
        return displayName(layout)
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard row < rows.count, tableColumn?.identifier.rawValue == "enabled" else { return }
        var disabled = LayoutStore.shared.disabledIDs
        let on: Bool = {
            if let n = object as? NSNumber { return n.intValue == 1 }
            if let s = object as? Int { return s == 1 }
            return true
        }()
        if on { disabled.remove(rows[row].id) } else { disabled.insert(rows[row].id) }
        LayoutStore.shared.disabledIDs = disabled
        let enabled = LayoutStore.shared.effectiveLayouts().count
        countLabel?.stringValue = "\(enabled) of \(allRows.count) enabled"
    }
}
