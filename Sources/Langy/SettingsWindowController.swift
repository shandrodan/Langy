import AppKit

/// Native settings, based on Figma frames 703:62 and 707:1057.
final class SettingsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    static let shared = SettingsWindowController()

    private static let width: CGFloat = 400
    private static let pad: CGFloat = 20
    private static let gap: CGFloat = 16
    private static let canvas: CGFloat = 1000
    private static let listHeight: CGFloat = 84 // Four rows, with room for the native cell inset.

    private var useSystemSwitch: SettingsSwitch!
    private var menuBarSwitch: SettingsSwitch!
    private var launchSwitch: SettingsSwitch!
    private var searchField: NSSearchField?
    private var layoutTable: NSTableView?
    private var removeButton: NSButton?
    private var countLabel: NSTextField?
    private var permissionLabel: NSTextField!

    private var allRows: [KeyboardLayout] = []
    private var filter = ""
    private var rows: [KeyboardLayout] {
        guard !filter.isEmpty else { return allRows }
        return allRows.filter { $0.name.localizedCaseInsensitiveContains(filter) }
    }

    private var layoutHelp: String {
        let layouts = LayoutStore.shared.useSystemLayouts
            ? "your installed keyboards" : "the built-in or custom layouts"
        return "With text selected, ⇧⌥L retypes the selection; with a plain caret, the whole field. " +
            "Press again for the next of \(layouts)."
    }

    init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: Self.width, height: 464),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        win.title = "Langy Settings"
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
        win.backgroundColor = .textBackgroundColor
        win.isMovableByWindowBackground = true
        win.hasShadow = true
        win.isReleasedWhenClosed = false
        super.init(window: win)
        buildContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func show() {
        LayoutStore.shared.refreshSystemLayouts()
        filter = ""
        buildContent()
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Build

    private func buildContent() {
        guard let win = window else { return }
        let root = NSView(frame: NSRect(x: 0, y: 0, width: Self.width, height: Self.canvas))
        root.autoresizingMask = [.width, .height]
        win.contentView = root
        let contentWidth = Self.width - Self.pad * 2
        let useSystem = LayoutStore.shared.useSystemLayouts
        var y = Self.canvas - 50

        let heading = NSTextField(labelWithString: "Settings")
        heading.font = .systemFont(ofSize: 32, weight: .bold)
        y = add(heading, height: 38, topGap: 0, at: y, in: root)

        let help = NSButton(title: "", target: self, action: #selector(showHelp(_:)))
        help.bezelStyle = .helpButton
        help.setAccessibilityLabel("Keyboard shortcuts and help")
        help.toolTip = "Keyboard shortcuts and help"
        help.frame = NSRect(x: Self.width - Self.pad - 24, y: y + 7, width: 24, height: 24)
        root.addSubview(help)

        useSystemSwitch = SettingsSwitch(title: "Use system keyboard layouts", target: self, action: #selector(toggleUseSystem(_:)))
        useSystemSwitch.state = useSystem ? .on : .off
        useSystemSwitch.setAccessibilityHelp(layoutHelp)
        let systemRow = toggleRow("Use system keyboard layouts", control: useSystemSwitch)
        systemRow.toolTip = layoutHelp
        y = add(systemRow, height: 47, at: y, in: root)

        searchField = nil
        layoutTable = nil
        removeButton = nil
        countLabel = nil

        if !useSystem {
            let field = NSSearchField()
            field.placeholderString = "Search layouts"
            field.setAccessibilityLabel("Search layouts")
            field.font = .systemFont(ofSize: 14)
            field.stringValue = filter
            field.target = self
            field.action = #selector(filterChanged(_:))
            field.sendsSearchStringImmediately = true
            searchField = field
            y = add(field, height: 24, at: y, in: root)

            let scroll = NSScrollView()
            scroll.hasVerticalScroller = true
            scroll.autohidesScrollers = true
            scroll.borderType = .noBorder
            scroll.drawsBackground = false
            let table = NSTableView()
            table.headerView = nil
            table.style = .inset
            table.rowHeight = 20
            table.intercellSpacing = .zero
            table.usesAlternatingRowBackgroundColors = true
            table.allowsMultipleSelection = false
            table.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
            table.setAccessibilityLabel("Keyboard layouts")
            let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
            nameColumn.title = "Layout"
            nameColumn.width = contentWidth - 76
            let enabledColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("enabled"))
            enabledColumn.title = "Enabled"
            enabledColumn.width = 40
            enabledColumn.minWidth = 40
            enabledColumn.maxWidth = 40
            table.addTableColumn(nameColumn)
            table.addTableColumn(enabledColumn)
            table.delegate = self
            table.dataSource = self
            scroll.documentView = table
            layoutTable = table
            y = add(scroll, height: Self.listHeight, at: y, in: root)

            let controls = NSView()
            let addButton = SettingsButton(title: "Add", target: self, action: #selector(addCustom(_:)))
            addButton.toolTip = "Add a custom keyboard layout"
            addButton.frame = NSRect(x: 0, y: 0, width: 57, height: 24)
            controls.addSubview(addButton)
            let remove = SettingsButton(title: "Remove", target: self, action: #selector(removeCustomRow(_:)))
            remove.toolTip = "Remove the selected custom layout"
            remove.frame = NSRect(x: 73, y: 0, width: 82, height: 24)
            controls.addSubview(remove)
            removeButton = remove
            let count = NSTextField(labelWithString: "")
            count.font = .systemFont(ofSize: 12)
            count.textColor = .secondaryLabelColor
            count.alignment = .right
            count.frame = NSRect(x: 171, y: 4, width: contentWidth - 171, height: 16)
            controls.addSubview(count)
            countLabel = count
            y = add(controls, height: 24, at: y, in: root)
        }

        menuBarSwitch = SettingsSwitch(title: "Show icon in menu bar", target: self, action: #selector(toggleMenuBar(_:)))
        menuBarSwitch.state = (NSApp.delegate as? AppDelegate)?.showsMenuBarIcon == false ? .off : .on
        let menuBarHelp = "⌃⌘⌥L opens Settings, even when the menu-bar icon is hidden."
        menuBarSwitch.setAccessibilityHelp(menuBarHelp)
        let menuRow = toggleRow("Show icon in menu bar", control: menuBarSwitch)
        menuRow.toolTip = menuBarHelp
        y = add(menuRow, height: 47, at: y, in: root)

        let divider = NSBox()
        divider.boxType = .separator
        y = add(divider, height: 1, at: y, in: root)

        launchSwitch = SettingsSwitch(title: "Launch on startup", target: self, action: #selector(toggleLaunch(_:)))
        launchSwitch.state = StartupManager.isEnabled ? .on : .off
        y = add(toggleRow("Launch on startup", control: launchSwitch), height: 47, at: y, in: root)

        let permissionText = TextSwapper.shared.isTrusted
            ? "Accessibility: allowed — text swapping works."
            : "Accessibility: not allowed — Langy can't swap text yet. Flip the switch, then Quit & Reopen."
        permissionLabel = NSTextField(wrappingLabelWithString: permissionText)
        permissionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        permissionLabel.textColor = TextSwapper.shared.isTrusted ? .secondaryLabelColor : SettingsColors.warning
        let permissionHeight = max(28, ceil((permissionText as NSString).boundingRect(
            with: NSSize(width: contentWidth, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: permissionLabel.font!]
        ).height))
        y = add(permissionLabel, height: permissionHeight, at: y, in: root)

        let permissionButton = SettingsButton(title: "Open Accessibility Settings...", target: self, action: #selector(openAccessibility(_:)))
        y = add(permissionButton, height: 24, at: y, in: root, width: 217)

        let quitRow = NSView()
        let relaunchButton = SettingsButton(title: "Quit & Reopen", target: self, action: #selector(relaunch(_:)))
        relaunchButton.toolTip = "Needed after flipping the Accessibility switch"
        relaunchButton.frame = NSRect(x: 0, y: 0, width: 123, height: 24)
        quitRow.addSubview(relaunchButton)
        let quitButton = SettingsButton(title: "Quit Completely", target: self, action: #selector(quitApp(_:)))
        quitButton.setAccessibilityLabel("Quit Langy completely")
        quitButton.frame = NSRect(x: 139, y: 0, width: 134, height: 24)
        quitRow.addSubview(quitButton)
        y = add(quitRow, height: 24, at: y, in: root)

        // Keep the existing attribution and version in the design's bottom margin.
        let footer = NSView()
        let site = NSButton(title: "made by dan", target: self, action: #selector(openSite(_:)))
        site.isBordered = false
        site.alignment = .left
        site.attributedTitle = NSAttributedString(string: site.title, attributes: [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.secondaryLabelColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        site.frame = NSRect(x: 0, y: 0, width: 90, height: 16)
        footer.addSubview(site)
        let version = NSTextField(labelWithString: "v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?")")
        version.font = .systemFont(ofSize: 11)
        version.textColor = .secondaryLabelColor
        version.alignment = .right
        version.frame = NSRect(x: contentWidth - 80, y: 0, width: 80, height: 16)
        footer.addSubview(version)
        y = add(footer, height: 16, at: y, in: root)

        allRows = LayoutStore.shared.allKnownLayouts()
        rebuildList()

        let targetHeight = Self.canvas - y + 14
        for view in root.subviews { view.frame.origin.y -= Self.canvas - targetHeight }
        var frame = win.frame
        frame.origin.y = frame.maxY - targetHeight
        frame.size.height = targetHeight
        if let visibleFrame = win.screen?.visibleFrame {
            frame.origin.y = max(visibleFrame.minY, min(frame.origin.y, visibleFrame.maxY - targetHeight))
        }
        win.setFrame(frame, display: true)

        // Retain real window controls, aligned to the Figma title-bar inset.
        for (index, kind) in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton].enumerated() {
            guard let button = win.standardWindowButton(kind), let parent = button.superview else { continue }
            button.setFrameOrigin(root.convert(NSPoint(x: Self.pad + CGFloat(index) * 23, y: targetHeight - 34), to: parent))
        }
        win.initialFirstResponder = searchField ?? useSystemSwitch
        win.recalculateKeyViewLoop()
    }

    @discardableResult
    private func add(_ view: NSView, height: CGFloat, topGap: CGFloat = gap, at y: CGFloat, in root: NSView, width: CGFloat = 0) -> CGFloat {
        let nextY = y - topGap - height
        view.frame = NSRect(x: Self.pad, y: nextY, width: width > 0 ? width : Self.width - Self.pad * 2, height: height)
        root.addSubview(view)
        return nextY
    }

    private func toggleRow(_ title: String, control: SettingsSwitch) -> NSView {
        let row = RoundedBox(radius: 12, fill: .clear)
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.frame = NSRect(x: 14, y: 14, width: 268, height: 19)
        row.addSubview(label)
        control.frame = NSRect(x: 292, y: 11.5, width: 54, height: 24)
        row.addSubview(control)
        return row
    }

    // MARK: - Layout list

    private func isCustom(_ layout: KeyboardLayout) -> Bool {
        !layout.isSystem && !layout.id.hasPrefix("builtin.")
    }

    private func rebuildList() {
        layoutTable?.reloadData()
        if let table = layoutTable, table.numberOfRows > 0 { table.scrollRowToVisible(0) }
        updateListControls()
    }

    private func updateListControls() {
        countLabel?.stringValue = "\(LayoutStore.shared.effectiveLayouts().count) of \(allRows.count) enabled"
        let selected = layoutTable?.selectedRow ?? -1
        removeButton?.isEnabled = rows.indices.contains(selected) && isCustom(rows[selected])
    }

    func numberOfRows(in tableView: NSTableView) -> Int { max(1, rows.count) }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool { !rows.isEmpty }

    func tableViewSelectionDidChange(_ notification: Notification) { updateListControls() }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let list = rows
        if list.isEmpty {
            guard tableColumn?.identifier.rawValue == "name" else { return nil }
            let message = filter.isEmpty ? "No layouts." : "No layouts match “\(filter)”."
            let label = NSTextField(labelWithString: message)
            label.font = .systemFont(ofSize: 12)
            label.textColor = .secondaryLabelColor
            label.lineBreakMode = .byTruncatingTail
            label.toolTip = message
            return label
        }
        let layout = list[row]
        if tableColumn?.identifier.rawValue == "enabled" {
            let cell = NSView(frame: NSRect(x: 0, y: 0, width: 40, height: 20))
            let toggle = SettingsSwitch(title: "Enable \(layout.name)", target: self, action: #selector(toggleLayout(_:)))
            toggle.identifier = NSUserInterfaceItemIdentifier(layout.id)
            toggle.state = LayoutStore.shared.disabledIDs.contains(layout.id) ? .off : .on
            toggle.frame = NSRect(x: 3, y: 2, width: 34, height: 16)
            toggle.autoresizingMask = [.minYMargin, .maxYMargin]
            cell.addSubview(toggle)
            return cell
        }
        let name = isCustom(layout) ? "\(layout.name) (Custom)" : layout.name
        let label = NSTextField(labelWithString: name)
        label.font = .systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        label.toolTip = name
        return label
    }

    // MARK: - Actions

    @objc private func toggleUseSystem(_ sender: NSButton) {
        LayoutStore.shared.useSystemLayouts = sender.state == .on
        buildContent()
        window?.makeFirstResponder(useSystemSwitch)
    }

    @objc private func toggleLayout(_ sender: NSButton) {
        guard let id = sender.identifier?.rawValue, !id.isEmpty else { return }
        var disabled = LayoutStore.shared.disabledIDs
        if sender.state == .on { disabled.remove(id) } else { disabled.insert(id) }
        LayoutStore.shared.disabledIDs = disabled
        updateListControls()
    }

    @objc private func toggleMenuBar(_ sender: NSButton) {
        (NSApp.delegate as? AppDelegate)?.showsMenuBarIcon = sender.state == .on
    }

    @objc private func toggleLaunch(_ sender: NSButton) {
        StartupManager.setEnabled(sender.state == .on)
        sender.state = StartupManager.isEnabled ? .on : .off
    }

    @objc private func showHelp(_ sender: NSButton) {
        guard let window else { return }
        let help = NSAlert()
        help.messageText = "Keyboard shortcuts"
        help.informativeText = layoutHelp + "\n\n⌃⌘⌥L opens Settings, even when the menu-bar icon is hidden. " +
            "You can also open Langy again from Finder or Spotlight to return to Settings."
        help.addButton(withTitle: "Got it")
        help.beginSheetModal(for: window)
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

    @objc private func quitApp(_ sender: NSButton) { NSApp.terminate(nil) }

    @objc private func openSite(_ sender: NSButton) {
        if let url = URL(string: "https://danshandro.com") { NSWorkspace.shared.open(url) }
    }

    @objc private func filterChanged(_ sender: NSSearchField) {
        filter = sender.stringValue.trimmingCharacters(in: .whitespaces)
        layoutTable?.deselectAll(nil)
        rebuildList()
    }

    @objc private func removeCustomRow(_ sender: NSButton) {
        let selected = layoutTable?.selectedRow ?? -1
        guard rows.indices.contains(selected), isCustom(rows[selected]) else { return }
        let id = rows[selected].id
        LayoutStore.shared.removeCustom(id: id)
        var disabled = LayoutStore.shared.disabledIDs
        disabled.remove(id)
        LayoutStore.shared.disabledIDs = disabled
        buildContent()
    }

    @objc private func addCustom(_ sender: NSButton) {
        guard let win = window else { return }
        let sheet = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 220),
            styleMask: [.titled], backing: .buffered, defer: false
        )
        sheet.title = "Extra layout"
        sheet.backgroundColor = .textBackgroundColor
        let nameField = NSTextField(string: "")
        nameField.placeholderString = "Name"
        nameField.setAccessibilityLabel("Layout name")
        nameField.frame = NSRect(x: 20, y: 160, width: 340, height: 24)
        let enField = NSTextField(string: "")
        enField.placeholderString = "Home chars, e.g. qwerty…"
        enField.setAccessibilityLabel("Home characters")
        enField.frame = NSRect(x: 20, y: 120, width: 340, height: 24)
        let mapField = NSTextField(string: "")
        mapField.placeholderString = "Mapped chars, same length"
        mapField.setAccessibilityLabel("Mapped characters")
        mapField.frame = NSRect(x: 20, y: 80, width: 340, height: 24)
        let hint = NSTextField(wrappingLabelWithString: "Both rows must be the same length — position 1 maps to position 1, etc.")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .secondaryLabelColor
        hint.frame = NSRect(x: 20, y: 44, width: 340, height: 28)
        let ok = SettingsButton(title: "Add", target: self, action: #selector(endAddSheet(_:)))
        ok.keyEquivalent = "\r"
        ok.frame = NSRect(x: 280, y: 12, width: 80, height: 24)
        for view in [nameField, enField, mapField, hint, ok] as [NSView] {
            sheet.contentView?.addSubview(view)
        }
        win.beginSheet(sheet) { [weak self] _ in
            let name = nameField.stringValue.trimmingCharacters(in: .whitespaces)
            let en = Array(enField.stringValue)
            let mp = Array(mapField.stringValue)
            guard !name.isEmpty, !en.isEmpty, en.count == mp.count else { return }
            var map: [String: String] = [:]
            for (a, b) in zip(en, mp) { map[String(a).lowercased()] = String(b) }
            LayoutStore.shared.addCustom(KeyboardLayout(
                id: "custom.\(UUID().uuidString)", name: name, map: map, isSystem: false
            ))
            self?.buildContent()
        }
    }

    @objc private func endAddSheet(_ sender: NSButton) {
        if let sheet = sender.window {
            window?.endSheet(sheet)
            sheet.orderOut(nil)
        }
    }
}

// MARK: - Figma styling, with native control behavior and adaptive colors

private enum SettingsColors {
    static let accent = NSColor(srgbRed: 0, green: 0.74, blue: 0.87, alpha: 1)
    static let border = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(white: 1, alpha: 0.18) : NSColor(white: 0.91, alpha: 1)
    }
    static let button = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor(white: 0.24, alpha: 1) : NSColor(white: 0.92, alpha: 1)
    }
    // The reference's light orange is darkened to keep small warning text legible.
    static let warning = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? .systemOrange : NSColor(srgbRed: 0.7, green: 0.29, blue: 0, alpha: 1)
    }
}

private final class RoundedBox: NSView {
    private let radius: CGFloat
    private let fill: NSColor

    init(radius: CGFloat, fill: NSColor) {
        self.radius = radius
        self.fill = fill
        super.init(frame: .zero)
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        layer?.cornerRadius = radius
        layer?.backgroundColor = fill.cgColor
        layer?.borderWidth = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? 1 : 0.5
        layer?.borderColor = (NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? NSColor.labelColor : SettingsColors.border).cgColor
    }
}

private final class SettingsSwitch: NSButton {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setButtonType(.pushOnPushOff)
        isBordered = false
        focusRingType = .exterior
        setAccessibilityRole(.checkBox)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var state: NSControl.StateValue {
        didSet { needsDisplay = true }
    }

    override func accessibilityLabel() -> String? { title }
    override func accessibilityValue() -> Any? { state == .on ? 1 : 0 }

    override func draw(_ dirtyRect: NSRect) {
        let track = NSBezierPath(roundedRect: bounds, xRadius: bounds.height / 2, yRadius: bounds.height / 2)
        let color = state == .on ? SettingsColors.accent : SettingsColors.border
        (isHighlighted ? color.blended(withFraction: 0.12, of: .black)! : color).setFill()
        track.fill()
        let highContrast = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
        NSColor.labelColor.withAlphaComponent(highContrast ? 1 : 0.55).setStroke()
        track.lineWidth = highContrast ? 1 : 0.5
        track.stroke()
        let knobWidth = bounds.width * 32 / 54
        let knob = NSRect(x: state == .on ? bounds.width - knobWidth - 2 : 2, y: 2, width: knobWidth, height: bounds.height - 4)
        NSColor.white.setFill()
        let thumb = NSBezierPath(roundedRect: knob, xRadius: knob.height / 2, yRadius: knob.height / 2)
        thumb.fill()
        NSColor(white: 0.3, alpha: 1).setStroke()
        thumb.lineWidth = highContrast ? 1 : 0.5
        thumb.stroke()
    }

    override func drawFocusRingMask() {
        NSBezierPath(roundedRect: bounds, xRadius: bounds.height / 2, yRadius: bounds.height / 2).fill()
    }

    override var focusRingMaskBounds: NSRect { bounds }
}

private final class SettingsButton: NSButton {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        isBordered = false
        font = .systemFont(ofSize: 14, weight: .medium)
        focusRingType = .exterior
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        let color = SettingsColors.button
        (isHighlighted ? color.blended(withFraction: 0.12, of: .labelColor)! : color).setFill()
        let path = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6)
        path.fill()
        if NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast {
            NSColor.labelColor.setStroke()
            path.lineWidth = 1
            path.stroke()
        }
        let text = NSAttributedString(string: title, attributes: [
            .font: font ?? NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: isEnabled ? NSColor.labelColor : NSColor.disabledControlTextColor
        ])
        let size = text.size()
        text.draw(at: NSPoint(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2))
    }

    override func drawFocusRingMask() {
        NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6).fill()
    }

    override var focusRingMaskBounds: NSRect { bounds }
}
