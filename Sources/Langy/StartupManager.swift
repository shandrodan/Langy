import Foundation
import ServiceManagement

/// Launch-on-startup via SMAppService (macOS 13+). No helpers, no login-item plist edits.
enum StartupManager {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("Langy: startup toggle failed: \(error)")
        }
    }
}
