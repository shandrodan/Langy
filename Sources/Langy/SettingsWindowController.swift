import AppKit
import Carbon

/// Native settings, based on Figma frames 703:62 and 707:1057.
final class SettingsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    static let shared = SettingsWindowController()

    private static let width: CGFloat = 400
    private static let pad: CGFloat = 20
    private static let gap: CGFloat = 16
    private static let canvas: CGFloat = 1000
    private static let listHeight: CGFloat = 84 // Four rows, with room for the native cell inset.

    private let hotkeys: HotKeyManager
    private var useSystemSwitch: SettingsSwitch!
    private var menuBarSwitch: SettingsSwitch!
    private var launchSwitch: SettingsSwitch!
    private var searchField: NSSearchField?
    private var layoutTable: NSTableView?
    private var removeButton: NSButton?
    private var countLabel: NSTextField?
    private var permissionLabel: NSTextField!
    private var hotkeyRecorder: NSAlert?

    private var allRows: [KeyboardLayout] = []
    private var filter = ""
    private var rows: [KeyboardLayout] {
        guard !filter.isEmpty else { return allRows }
        return allRows.filter { $0.name.localizedCaseInsensitiveContains(filter) }
    }

    private var layoutHelp: String {
        let layouts = LayoutStore.shared.useSystemLayouts
            ? "your installed keyboards" : "the built-in or custom layouts"
        return "With text selected, \(hotkeys.shortcut(for: .convert).displayString) retypes the selection; with a plain caret, the whole field. " +
            "Press again for the next of \(layouts)."
    }

    init(hotkeys: HotKeyManager = .shared) {
        self.hotkeys = hotkeys
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: Self.width, height: 464),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        win.title = "Langy Settings"
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
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
        root.identifier = NSUserInterfaceItemIdentifier("settings.content")
        root.autoresizingMask = [.width, .height]
        installBackground(in: win, content: root)
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

        for action in HotKeyManager.Action.allCases {
            let row = NSView()
            let text = "\(action.title): \(hotkeys.shortcut(for: action).displayString)"
            let label = NSTextField(labelWithString: text)
            label.identifier = NSUserInterfaceItemIdentifier("shortcut.\(action.rawValue).label")
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.lineBreakMode = .byTruncatingTail
            label.toolTip = text
            label.frame = NSRect(x: 0, y: 3, width: 174, height: 18)
            row.addSubview(label)
            let rewrite = SettingsButton(title: action.rewriteTitle, target: self, action: #selector(rewriteHotkey(_:)))
            rewrite.tag = action.rawValue
            rewrite.font = .systemFont(ofSize: 12, weight: .medium)
            rewrite.frame = NSRect(x: 184, y: 0, width: contentWidth - 184, height: 24)
            row.addSubview(rewrite)
            y = add(row, height: 24, topGap: action == .convert ? Self.gap : 8, at: y, in: root)
        }

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
            table.backgroundColor = .clear
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
        let menuBarHelp = "\(hotkeys.shortcut(for: .settings).displayString) opens Settings, even when the menu-bar icon is hidden."
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
        let windowHeight = min(targetHeight, win.screen?.visibleFrame.height ?? targetHeight)
        var contentScroll: NSScrollView?
        if windowHeight < targetHeight {
            root.autoresizingMask = [.width]
            root.setFrameSize(NSSize(width: Self.width, height: targetHeight))
            let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: Self.width, height: windowHeight))
            scroll.hasVerticalScroller = true
            scroll.autohidesScrollers = true
            scroll.drawsBackground = false
            scroll.borderType = .noBorder
            scroll.scrollerStyle = .overlay
            scroll.documentView = root
            installBackground(in: win, content: scroll)
            contentScroll = scroll
        }
        var frame = win.frame
        frame.origin.y = frame.maxY - windowHeight
        frame.size.height = windowHeight
        if let visibleFrame = win.screen?.visibleFrame {
            frame.origin.y = max(visibleFrame.minY, min(frame.origin.y, visibleFrame.maxY - windowHeight))
        }
        win.setFrame(frame, display: true)
        if let scroll = contentScroll {
            scroll.contentView.scroll(to: NSPoint(x: 0, y: targetHeight - scroll.contentSize.height))
            scroll.reflectScrolledClipView(scroll.contentView)
        }

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
        let row = RoundedBox(radius: 12, fill: SettingsColors.rowFill)
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
            let toggle = SettingsSwitch(title: "Enable \(layout.name)", target: self, action: #selector(toggleLayout(_:)), small: true)
            toggle.identifier = NSUserInterfaceItemIdentifier(layout.id)
            toggle.state = LayoutStore.shared.disabledIDs.contains(layout.id) ? .off : .on
            toggle.frame = NSRect(x: 2, y: 2, width: 36, height: 16)
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

    @objc private func rewriteHotkey(_ sender: NSButton) {
        guard let win = window, win.attachedSheet == nil, !hotkeys.isRecording,
              let action = HotKeyManager.Action(rawValue: sender.tag) else { return }
        let manager = hotkeys
        let alert = NSAlert()
        hotkeyRecorder = alert
        alert.messageText = action.rewriteTitle
        alert.informativeText = "Press a key with Command, Control, or Option. Shift can be added too.\nDefault: \(action.defaultShortcut.displayString)"
        alert.window.identifier = NSUserInterfaceItemIdentifier("hotkey.recorder")
        let save = alert.addButton(withTitle: "Save")
        save.isEnabled = false
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Use Default")

        let accessory = NSView(frame: NSRect(x: 0, y: 0, width: 310, height: 110))
        let preview = NSTextField(labelWithString: manager.shortcut(for: action).displayString)
        preview.identifier = NSUserInterfaceItemIdentifier("hotkey.preview")
        preview.setAccessibilityLabel("New hotkey")
        preview.font = .monospacedSystemFont(ofSize: 24, weight: .medium)
        preview.alignment = .center
        preview.frame = NSRect(x: 0, y: 74, width: 310, height: 32)
        accessory.addSubview(preview)
        let hint = NSTextField(wrappingLabelWithString: "Press your new shortcut, then click Save. Escape cancels without changing it.")
        hint.identifier = NSUserInterfaceItemIdentifier("hotkey.hint")
        hint.font = .systemFont(ofSize: 12)
        hint.textColor = .secondaryLabelColor
        hint.frame = NSRect(x: 0, y: 0, width: 310, height: 62)
        accessory.addSubview(hint)
        alert.accessoryView = accessory

        var candidate: KeyboardShortcut?
        manager.beginRecording()
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak alert, weak win] event in
            guard let alert, let win else { return event }
            guard event.window === alert.window else { return event }
            guard !event.isARepeat else { return nil }
            let modifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])
            if event.keyCode == UInt16(kVK_Escape), modifiers.isEmpty {
                win.endSheet(alert.window, returnCode: .alertSecondButtonReturn)
                return nil
            }
            if event.keyCode == UInt16(kVK_Return), modifiers.isEmpty { return event }
            if event.keyCode == UInt16(kVK_Tab), modifiers.subtracting(.shift).isEmpty { return event }
            if event.keyCode == UInt16(kVK_Space), modifiers.isEmpty, alert.window.firstResponder is NSButton { return event }
            let shortcut = KeyboardShortcut(event: event)
            do {
                try manager.validate(shortcut, for: action)
                candidate = shortcut
                preview.stringValue = shortcut.displayString
                hint.stringValue = "Click Save to use this shortcut everywhere in Langy."
                hint.textColor = .secondaryLabelColor
                save.isEnabled = true
            } catch {
                candidate = nil
                hint.stringValue = error.localizedDescription
                hint.textColor = SettingsColors.warning
                save.isEnabled = false
            }
            return nil
        }
        let observers = [NSApplication.didResignActiveNotification, NSWindow.willCloseNotification].map { name in
            NotificationCenter.default.addObserver(forName: name, object: name == NSWindow.willCloseNotification ? win : NSApp, queue: .main) { [weak alert, weak win] _ in
                guard let alert, let win else { return }
                if win.attachedSheet === alert.window {
                    win.endSheet(alert.window, returnCode: .alertSecondButtonReturn)
                }
            }
        }
        alert.beginSheetModal(for: win) { [weak self] response in
            if let monitor { NSEvent.removeMonitor(monitor) }
            observers.forEach { NotificationCenter.default.removeObserver($0) }
            var errors: [String] = []
            let chosen = response == .alertThirdButtonReturn ? action.defaultShortcut : candidate
            if response == .alertFirstButtonReturn || response == .alertThirdButtonReturn, let chosen {
                do { try manager.setShortcut(chosen, for: action) }
                catch { errors.append(error.localizedDescription) }
            }
            errors += manager.endRecording()
            self?.hotkeyRecorder = nil
            self?.buildContent()
            if !errors.isEmpty, win.isVisible {
                let problem = NSAlert()
                problem.messageText = "Hotkey registration problem"
                problem.informativeText = errors.joined(separator: "\n\n") +
                    "\n\nYou can always reopen Langy from Finder or Spotlight to reach Settings."
                problem.beginSheetModal(for: win)
            }
        }
    }

    @objc private func toggleUseSystem(_ sender: NSView) {
        guard let sender = sender as? SettingsSwitch else { return }
        LayoutStore.shared.useSystemLayouts = sender.state == .on
        buildContent()
        window?.makeFirstResponder(useSystemSwitch)
    }

    @objc private func toggleLayout(_ sender: NSView) {
        guard let sender = sender as? SettingsSwitch else { return }
        guard let id = sender.identifier?.rawValue, !id.isEmpty else { return }
        var disabled = LayoutStore.shared.disabledIDs
        if sender.state == .on { disabled.remove(id) } else { disabled.insert(id) }
        LayoutStore.shared.disabledIDs = disabled
        updateListControls()
    }

    @objc private func toggleMenuBar(_ sender: NSView) {
        guard let sender = sender as? SettingsSwitch else { return }
        (NSApp.delegate as? AppDelegate)?.showsMenuBarIcon = sender.state == .on
    }

    @objc private func toggleLaunch(_ sender: NSView) {
        guard let sender = sender as? SettingsSwitch else { return }
        StartupManager.setEnabled(sender.state == .on)
        sender.state = StartupManager.isEnabled ? .on : .off
    }

    @objc private func showHelp(_ sender: NSButton) {
        guard let window else { return }
        let help = NSAlert()
        help.messageText = "Keyboard shortcuts"
        help.informativeText = layoutHelp + "\n\n\(hotkeys.shortcut(for: .settings).displayString) opens Settings, even when the menu-bar icon is hidden. " +
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
        sheet.titlebarAppearsTransparent = true
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 380, height: 220))
        content.autoresizingMask = [.width, .height]
        installBackground(in: sheet, content: content)
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
            content.addSubview(view)
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

    private func installBackground(in window: NSWindow, content: NSView) {
        window.isOpaque = false
        window.backgroundColor = .clear
        if #available(macOS 26, *) {
            // Keep glass behind the scroll view and native controls. Embedding a
            // scroll view as glass content can flatten nested switch layers.
            let shell = NSView(frame: content.frame)
            shell.autoresizingMask = [.width, .height]
            let glass = NSGlassEffectView(frame: shell.bounds)
            glass.autoresizingMask = [.width, .height]
            glass.style = .regular
            glass.cornerRadius = 16
            shell.addSubview(glass)
            shell.addSubview(content)
            window.contentView = shell
        } else {
            let effect = NSVisualEffectView(frame: content.frame)
            effect.material = .sidebar
            effect.blendingMode = .behindWindow
            effect.state = .active
            effect.addSubview(content)
            window.contentView = effect
        }
    }
}

// MARK: - Figma styling, with native control behavior and adaptive colors

private enum SettingsColors {
    static let accent = NSColor(srgbRed: 0, green: 0.74, blue: 0.87, alpha: 1)
    static let border = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor.white.withAlphaComponent(0.18) : NSColor.black.withAlphaComponent(0.16)
    }
    static let rowFill = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? NSColor.white.withAlphaComponent(0.045) : NSColor.white.withAlphaComponent(0.20)
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
        layer?.borderWidth = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? 1 : 0.75
        layer?.borderColor = (NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? NSColor.labelColor : SettingsColors.border).cgColor
    }
}

/// AppKit owns the switch geometry, thumb, accent, focus behavior, and motion.
final class SettingsSwitch: NSSwitch {
    init(title: String, target: AnyObject, action: Selector, small: Bool = false) {
        super.init(frame: .zero)
        self.target = target
        self.action = action
        controlSize = small ? .mini : .regular
        setAccessibilityLabel(title)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

private final class SettingsButtonCell: NSButtonCell {
    override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView) {
        super.highlight(flag, withFrame: cellFrame, in: controlView)
        (controlView as? SettingsButton)?.updateInteraction()
    }
}

final class SettingsButton: NSButton {
    var isStatic = false {
        didSet { updateInteraction(animated: false) }
    }

    private var isHovered = false
    private var hoverTrackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        cell = SettingsButtonCell(textCell: "")
        setButtonType(.momentaryPushIn)
        isBordered = false
        font = .systemFont(ofSize: 14, weight: .medium)
        focusRingType = .exterior
        wantsLayer = true
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(displayOptionsChanged),
            name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var isEnabled: Bool {
        didSet {
            if !isEnabled { isHovered = false }
            updateInteraction(animated: false)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let hoverTrackingArea { removeTrackingArea(hoverTrackingArea) }
        let area = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self)
        addTrackingArea(area)
        hoverTrackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        guard isEnabled else { return }
        isHovered = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        needsDisplay = true
    }

    override func highlight(_ flag: Bool) {
        super.highlight(flag)
        updateInteraction()
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateInteraction(animated: false)
    }

    @objc private func displayOptionsChanged() {
        updateInteraction(animated: false)
    }

    fileprivate func updateInteraction(animated: Bool = true) {
        needsDisplay = true
        guard let layer else { return }
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let scale: CGFloat = isEnabled && isHighlighted && !isStatic && !reduceMotion ? 0.96 : 1
        var transform = CATransform3DMakeScale(scale, scale, 1)
        // Preserve the optical center without changing AppKit's frame, hit target, or layer anchor.
        transform.m41 = bounds.width * (0.5 - layer.anchorPoint.x) * (1 - scale)
        transform.m42 = bounds.height * (0.5 - layer.anchorPoint.y) * (1 - scale)
        if animated && CATransform3DEqualToTransform(layer.transform, transform) { return }
        let current = layer.presentation()?.transform ?? layer.transform
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.transform = transform
        CATransaction.commit()
        if animated && !isStatic && !reduceMotion && !CATransform3DEqualToTransform(current, transform) {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: current)
            animation.toValue = NSValue(caTransform3D: transform)
            animation.duration = 0.15
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            layer.add(animation, forKey: "press")
        } else {
            layer.removeAnimation(forKey: "press")
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        let primary = keyEquivalent == "\r" && isEnabled
        let color = primary ? SettingsColors.accent : SettingsColors.button
        let overlay: NSColor = primary ? .black : .labelColor
        let intensity: CGFloat = isEnabled && isHighlighted ? 0.12 : (isEnabled && isHovered ? 0.06 : 0)
        (color.blended(withFraction: intensity, of: overlay) ?? color).setFill()
        let path = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6)
        path.fill()
        if NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast {
            NSColor.labelColor.setStroke()
            path.lineWidth = 1
            path.stroke()
        }
        let text = NSAttributedString(string: title, attributes: [
            .font: font ?? NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: isEnabled ? (primary ? NSColor.black : NSColor.labelColor) : NSColor.disabledControlTextColor
        ])
        let size = text.size()
        text.draw(at: NSPoint(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2))
    }

    override func drawFocusRingMask() {
        NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6).fill()
    }

    override var focusRingMaskBounds: NSRect { bounds }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
