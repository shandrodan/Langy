import AppKit
import Carbon

/// One keyboard layout: a map from US-English characters to this layout's characters.
/// Keys are single-character strings (lowercase for letters); case is preserved at apply time.
struct KeyboardLayout: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var map: [String: String]
    var isSystem: Bool
}
