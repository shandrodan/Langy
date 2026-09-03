import AppKit

// Entry point. LSUIElement = no Dock icon, minimal footprint.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
