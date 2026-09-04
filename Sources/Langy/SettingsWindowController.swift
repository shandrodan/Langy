import AppKit

/// Tahoe-style translucent settings window (⌃⌘⌥L).
/// Rounded grouped cards with toggle switches instead of a table:
/// when "Use system layouts" is on, the layouts card is just the
/// description + toggle — no search, no list, no buttons.
final class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    private static let width: CGFloat = 520
    private static let pad: CGFloat = 20
    private static let inset: CGFloat = 14
    private static let canvas: CGFloat = 1400
    private static let listHeight: CGFloat = 232
    private static let rowHeight: CGFloat = 32

    private var descLabel: NSTextField!
    private var useSystemSwitch: NSSwitch!
    private var searchField: NSSearchField?
    private var listScroll: NSScrollView?
    private var listDoc: NSView?
    private var countLabel: NSTextField?
    private var launchSwitch: NSSwitch!
    private var permissionLabel: NSTextField!

    private var allRows: [KeyboardLayout] = []
    private var filter: String = ""
    private var rows: [KeyboardLayout] {
        guard !filter.isEmpty else { return allRows }
        return allRows.filter { $0.name.localizedCaseInsensitiveContains(filter) }
    }

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
        let rootH = Self.canvas
        let root = NSView(frame: NSRect(x: 0, y: 0, width: Self.width, height: rootH))
        root.autoresizingMask = [.width, .height]
        win.contentView = root

        let bg = makeBackground()
        bg.frame = root.bounds
        root.addSubview(bg)

        let useSystem = LayoutStore.shared.useSystemLayouts
        var y = rootH - 56 // below traffic lights

        // MARK: Layouts section
        y = addSectionHeader("Keyboard Layouts", topGap: 0, at: y, in: root)

        let innerW = Self.width - Self.pad * 2 - Self.inset * 2
        let descFont = NSFont.systemFont(ofSize: 12)
        let descText = useSystem
            ? "With text selected, ⇧⌥L retypes the selection; with a plain caret, the whole field. Press again for the next of your installed keyboards."
            : "With text selected, ⇧⌥L retypes the selection; with a plain caret, the whole field. Press again for the next built-in or custom layout."
        let descH = wrappedHeight(descText, width: innerW, font: descFont)

        // When system layouts are on, that's it: description + toggle only.
        var cardH: CGFloat = 14 + descH + 10 + 26 + 14
        if !useSystem {
            cardH += 12 + 28 + 10 + Self.listHeight + 10 + 28
        }
        let card = RoundedBox(radius: 18, fill: NSColor.controlBackgroundColor.withAlphaComponent(0.55))
        y = add(card, height: cardH, topGap: 6, at: y, in: root)

        var cy = cardH
        descLabel = NSTextField(wrappingLabelWithString: descText)
        descLabel.font = descFont
        descLabel.textColor = .secondaryLabelColor
        cy = place(descLabel, height: descH, topGap: 14, at: cy, in: card)

        let sysRow = NSView()
        let sysLabel = NSTextField(labelWithString: "Use system layouts")
        sysLabel.font = .systemFont(ofSize: 13)
        sysLabel.frame = NSRect(x: 0, y: 4, width: innerW - 52, height: 18)
        useSystemSwitch = NSSwitch()
        useSystemSwitch.target = self
        useSystemSwitch.action = #selector(toggleUseSystem(_:))
        useSystemSwitch.frame = NSRect(x: innerW - 40, y: 2, width: 40, height: 22)
        sysRow.addSubview(sysLabel)
        sysRow.addSubview(useSystemSwitch)
        cy = place(sysRow, height: 26, topGap: 10, at: cy, in: card)

        if !useSystem {
            let field = NSSearchField()
            field.placeholderString = "Search layouts"
            field.target = self
            field.action = #selector(filterChanged(_:))
            field.sendsSearchStringImmediately = true
            searchField = field
            cy = place(field, height: 28, topGap: 12, at: cy, in: card)

            let listBox = RoundedBox(radius: 12, fill: NSColor.textBackgroundColor.withAlphaComponent(0.65))
            cy = place(listBox, height: Self.listHeight, topGap: 10, at: cy, in: card)
            let scroll = NSScrollView(frame: NSRect(x: 1, y: 1, width: listBox.bounds.width - 2, height: Self.listHeight - 2))
            scroll.autoresizingMask = [.width, .height]
            scroll.hasVerticalScroller = true
            scroll.hasHorizontalScroller = false
            scroll.autohidesScrollers = true
            scroll.borderType = .noBorder
            scroll.drawsBackground = false
            let doc = NSView(frame: NSRect(x: 0, y: 0, width: scroll.contentSize.width, height: scroll.contentSize.height))
            scroll.documentView = doc
            listBox.addSubview(scroll)
            listScroll = scroll
            listDoc = doc

            let footRow = NSView()
            let addBtn = NSButton(title: "Add…", target: self, action: #selector(addCustom(_:)))
            addBtn.bezelStyle = .rounded
            addBtn.frame = NSRect(x: 0, y: 0, width: 72, height: 28)
            let count = NSTextField(labelWithString: "")
            count.font = .systemFont(ofSize: 12)
            count.textColor = .secondaryLabelColor
            count.alignment = .right
            count.frame = NSRect(x: 80, y: 5, width: innerW - 80, height: 18)
            countLabel = count
            footRow.addSubview(addBtn)
            footRow.addSubview(count)
            cy = place(footRow, height: 28, topGap: 10, at: cy, in: card)
        } else {
            searchField = nil
            listScroll = nil
            listDoc = nil
            countLabel = nil
        }

        // MARK: General section
        y = addSectionHeader("General", at: y, in: root)

        let trusted = TextSwapper.shared.isTrusted
        let permText = trusted
            ? "Accessibility: allowed — text swapping works."
            : "Accessibility: not allowed — Langy can't swap text yet. Flip the switch, then Quit & Reopen."
        let permH = wrappedHeight(permText, width: innerW, font: descFont)

        let genH: CGFloat = 14 + 26 + 10 + permH + 8 + 28 + 10 + 28 + 14
        let genCard = RoundedBox(radius: 18, fill: NSColor.controlBackgroundColor.withAlphaComponent(0.55))
        y = add(genCard, height: genH, topGap: 6, at: y, in: root)

        var gy = genH
        let launchRow = NSView()
        let launchLabel = NSTextField(labelWithString: "Launch on startup")
        launchLabel.font = .systemFont(ofSize: 13)
        launchLabel.frame = NSRect(x: 0, y: 4, width: innerW - 52, height: 18)
        launchSwitch = NSSwitch()
        launchSwitch.target = self
        launchSwitch.action = #selector(toggleLaunch(_:))
        launchSwitch.frame = NSRect(x: innerW - 40, y: 2, width: 40, height: 22)
        launchRow.addSubview(launchLabel)
        launchRow.addSubview(launchSwitch)
        gy = place(launchRow, height: 26, topGap: 14, at: gy, in: genCard)

        permissionLabel = NSTextField(wrappingLabelWithString: permText)
        permissionLabel.font = descFont
        gy = place(permissionLabel, height: permH, topGap: 10, at: gy, in: genCard)

        let permRow = NSView()
        let permBtn = NSButton(title: "Open Accessibility Settings…", target: self, action: #selector(openAccessibility(_:)))
        permBtn.bezelStyle = .rounded
        permBtn.frame = NSRect(x: 0, y: 0, width: 220, height: 28)
        let relaunchBtn = NSButton(title: "Quit & Reopen", target: self, action: #selector(relaunch(_:)))
        relaunchBtn.bezelStyle = .rounded
        relaunchBtn.toolTip = "Needed after flipping the Accessibility switch"
        relaunchBtn.frame = NSRect(x: 228, y: 0, width: 120, height: 28)
        permRow.addSubview(permBtn)
        permRow.addSubview(relaunchBtn)
        gy = place(permRow, height: 28, topGap: 8, at: gy, in: genCard)

        let quitBtn = NSButton(title: "Quit Langy Completely", target: self, action: #selector(quitApp(_:)))
        quitBtn.bezelStyle = .rounded
        gy = place(quitBtn, height: 28, topGap: 10, at: gy, in: genCard, width: 200)

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

        reload()

        // Shrink window to fit content exactly (canvas is oversized on purpose
        // so toggling the list back on never clips). Freeze subview frames so
        // the resize itself doesn't move anything, then shift everything down.
        let targetH = (rootH - y) + 16
        for v in root.subviews { v.autoresizingMask = [] }
        let delta = rootH - targetH
        for v in root.subviews where v !== bg { v.frame.origin.y -= delta }
        var frame = win.frame
        frame.size.height = targetH
        frame.origin.y = (win.frame.origin.y + win.frame.size.height) - targetH
        win.setFrame(frame, display: true, animate: false)
        bg.frame = root.bounds
        bg.autoresizingMask = [.width, .height]
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

    /// Place a view inside a card, with card insets on both sides.
    @discardableResult
    private func place(_ view: NSView, height: CGFloat, topGap: CGFloat, at y: CGFloat, in card: NSView, width: CGFloat = 0) -> CGFloat {
        let ny = y - height - topGap
        let w = width > 0 ? width : card.bounds.width - Self.inset * 2
        view.frame = NSRect(x: Self.inset, y: ny, width: w, height: height)
        view.autoresizingMask = [.width, .maxYMargin]
        card.addSubview(view)
        return ny
    }

    private func addSectionHeader(_ text: String, topGap: CGFloat = 14, at y: CGFloat, in root: NSView) -> CGFloat {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return add(label, height: 18, topGap: topGap, at: y, in: root)
    }

    private func wrappedHeight(_ text: String, width: CGFloat, font: NSFont) -> CGFloat {
        let r = (text as NSString).boundingRect(
            with: NSSize(width: width, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font]
        )
        return ceil(r.height) + 4
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
        useSystemSwitch.state = LayoutStore.shared.useSystemLayouts ? .on : .off
        launchSwitch.state = StartupManager.isEnabled ? .on : .off
        rebuildList()
        refreshPermissionRow()
    }

    /// Rebuild the layout rows (label + switch, per-row remove for customs).
    private func rebuildList() {
        guard let doc = listDoc, let scroll = listScroll else { return }
        doc.subviews.forEach { $0.removeFromSuperview() }
        let list = rows
        let docW = scroll.contentSize.width
        let visibleH = scroll.contentSize.height
        if list.isEmpty {
            let empty = NSTextField(labelWithString: filter.isEmpty ? "No layouts." : "No layouts match “\(filter)”.")
            empty.font = .systemFont(ofSize: 12)
            empty.textColor = .secondaryLabelColor
            empty.alignment = .center
            empty.frame = NSRect(x: 0, y: max(0, visibleH - 24), width: docW, height: 18)
            doc.addSubview(empty)
            doc.setFrameSize(NSSize(width: docW, height: visibleH))
        } else {
            let docH = max(visibleH, CGFloat(list.count) * Self.rowHeight)
            doc.setFrameSize(NSSize(width: docW, height: docH))
            for (i, layout) in list.enumerated() {
                let custom = isCustom(layout)
                let swW: CGFloat = 40
                let rmW: CGFloat = custom ? 30 : 0
                let row = NSView(frame: NSRect(x: 0, y: docH - CGFloat(i + 1) * Self.rowHeight, width: docW, height: Self.rowHeight))
                let label = NSTextField(labelWithString: displayName(layout))
                label.font = .systemFont(ofSize: 13)
                label.lineBreakMode = .byTruncatingTail
                label.frame = NSRect(x: 12, y: 7, width: docW - 12 - 12 - swW - 8 - rmW, height: 18)
                row.addSubview(label)
                if custom {
                    let rm = makeRemoveButton()
                    rm.identifier = NSUserInterfaceItemIdentifier(layout.id)
                    rm.target = self
                    rm.action = #selector(removeCustomRow(_:))
                    rm.frame = NSRect(x: docW - 12 - swW - 8 - 22, y: 5, width: 22, height: 22)
                    row.addSubview(rm)
                }
                let sw = NSSwitch()
                sw.identifier = NSUserInterfaceItemIdentifier(layout.id)
                sw.state = LayoutStore.shared.disabledIDs.contains(layout.id) ? .off : .on
                sw.target = self
                sw.action = #selector(toggleLayout(_:))
                sw.frame = NSRect(x: docW - 12 - swW, y: 5, width: swW, height: 22)
                row.addSubview(sw)
                doc.addSubview(row)
            }
            if docH > visibleH {
                scroll.contentView.scroll(to: NSPoint(x: 0, y: docH - visibleH))
                scroll.reflectScrolledClipView(scroll.contentView)
            }
        }
        let enabled = LayoutStore.shared.effectiveLayouts().count
        countLabel?.stringValue = "\(enabled) of \(allRows.count) enabled"
    }

    private func makeRemoveButton() -> NSButton {
        if let img = NSImage(systemSymbolName: "minus.circle", accessibilityDescription: "Remove custom layout") {
            let b = NSButton(image: img, target: nil, action: nil)
            b.isBordered = false
            b.imageScaling = .scaleProportionallyDown
            b.toolTip = "Remove custom layout"
            b.contentTintColor = .secondaryLabelColor
            return b
        }
        let b = NSButton(title: "Remove", target: nil, action: nil)
        b.bezelStyle = .inline
        b.controlSize = .small
        return b
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

    @objc private func toggleUseSystem(_ sender: NSSwitch) {
        LayoutStore.shared.useSystemLayouts = sender.state == .on
        buildContent()
    }

    @objc private func toggleLayout(_ sender: NSSwitch) {
        guard let id = sender.identifier?.rawValue, !id.isEmpty else { return }
        var disabled = LayoutStore.shared.disabledIDs
        if sender.state == .on { disabled.remove(id) } else { disabled.insert(id) }
        LayoutStore.shared.disabledIDs = disabled
        let enabled = LayoutStore.shared.effectiveLayouts().count
        countLabel?.stringValue = "\(enabled) of \(allRows.count) enabled"
    }

    @objc private func toggleLaunch(_ sender: NSSwitch) {
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
        rebuildList()
    }

    @objc private func removeCustomRow(_ sender: NSButton) {
        guard let id = sender.identifier?.rawValue, !id.isEmpty else { return }
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

// MARK: - Rounded card

/// Layer-backed rounded container using dynamic NSColors, so it tracks
/// light/dark appearance changes via updateLayer.
private final class RoundedBox: NSView {
    private let radius: CGFloat
    private let fill: NSColor

    init(radius: CGFloat, fill: NSColor) {
        self.radius = radius
        self.fill = fill
        super.init(frame: .zero)
        wantsLayer = true
        layer?.borderWidth = 1
        updateLayer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        layer?.cornerRadius = radius
        layer?.backgroundColor = fill.cgColor
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.4).cgColor
    }
}
