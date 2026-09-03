import AppKit
import Carbon

/// Discovers real system keyboard layouts via TIS + UCKeyTranslate,
/// merges them with built-ins and user customs, persists prefs.
/// Everything is lazy/on-demand — no polling, ~zero idle cost.
final class LayoutStore {
    static let shared = LayoutStore()

    private let defaults = UserDefaults.standard
    private let kUseSystem = "langy.useSystemLayouts"
    private let kCustom = "langy.customLayouts"
    private let kDisabled = "langy.disabledLayoutIDs"

    var useSystemLayouts: Bool {
        get { defaults.object(forKey: kUseSystem) == nil ? true : defaults.bool(forKey: kUseSystem) }
        set { defaults.set(newValue, forKey: kUseSystem) }
    }

    var disabledIDs: Set<String> {
        get { Set(defaults.stringArray(forKey: kDisabled) ?? []) }
        set { defaults.set(Array(newValue), forKey: kDisabled) }
    }

    var customLayouts: [KeyboardLayout] {
        get {
            guard let data = defaults.data(forKey: kCustom),
                  let decoded = try? JSONDecoder().decode([KeyboardLayout].self, from: data)
            else { return [] }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: kCustom)
            }
        }
    }

    func addCustom(_ layout: KeyboardLayout) {
        var all = customLayouts
        all.removeAll { $0.id == layout.id }
        all.append(layout)
        customLayouts = all
    }

    func removeCustom(id: String) {
        customLayouts = customLayouts.filter { $0.id != id }
    }

    // MARK: - Effective list for cycling (⇧⌥L scrolls through these in order)

    /// System ON: your installed keyboards + your customs — nothing else.
    /// System OFF: built-ins + customs.
    func effectiveLayouts() -> [KeyboardLayout] {
        var out: [KeyboardLayout] = []
        var seen = Set<String>()
        let systems = useSystemLayouts ? systemLayouts() : []
        for l in systems where !disabledIDs.contains(l.id) {
            out.append(l); seen.insert(l.id)
        }
        for l in customLayouts where !seen.contains(l.id) && !disabledIDs.contains(l.id) {
            out.append(l); seen.insert(l.id)
        }
        if !useSystemLayouts {
            for b in BuiltinLayouts.all.sorted(by: { $0.name < $1.name })
                where !seen.contains(b.id) && !disabledIDs.contains(b.id) {
                out.append(b); seen.insert(b.id)
            }
        }
        return out
    }

    /// Everything known (for the settings list), with enabled flags derived from disabledIDs.
    func allKnownLayouts() -> [KeyboardLayout] {
        var out: [KeyboardLayout] = []
        var seen = Set<String>()
        let systems = useSystemLayouts ? systemLayouts() : []
        for l in systems { out.append(l); seen.insert(l.id) }
        for l in customLayouts where !seen.contains(l.id) { out.append(l); seen.insert(l.id) }
        if !useSystemLayouts {
            for b in BuiltinLayouts.all.sorted(by: { $0.name < $1.name })
                where !seen.contains(b.id) {
                out.append(b); seen.insert(b.id)
            }
        }
        return out
    }

    // MARK: - System discovery

    private var cachedSystem: [KeyboardLayout]?
    private var cachedAt: Date = .distantPast

    /// Cached for 30s — rescanning TIS on every keypress would waste cycles.
    func systemLayouts() -> [KeyboardLayout] {
        if let c = cachedSystem, Date().timeIntervalSince(cachedAt) < 30 { return c }
        let found = discoverSystemLayouts()
        cachedSystem = found
        cachedAt = Date()
        return found
    }

    func refreshSystemLayouts() {
        cachedAt = .distantPast
        _ = systemLayouts()
    }

    private func discoverSystemLayouts() -> [KeyboardLayout] {
        guard let cfList = TISCreateInputSourceList(
            [kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String] as CFDictionary,
            false
        )?.takeRetainedValue() as? [TISInputSource] else { return [] }

        // Positional reference = the ASCII-capable layout (ABC, US, … — modern
        // systems ship ABC, not US). It also becomes the convertible identity
        // entry so text can convert back to it.
        var referenceID: String?
        var referenceName = "English"
        var refData: Data?
        if let asciiRef = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue() {
            referenceID = sourceID(of: asciiRef)
            if let n = sourceName(of: asciiRef) { referenceName = n }
            refData = layoutData(of: asciiRef)
        }
        guard let usData = refData else {
            NSLog("Langy: no ASCII-capable reference layout found")
            return []
        }

        var out: [KeyboardLayout] = []
        if let rid = referenceID {
            out.append(KeyboardLayout(id: rid, name: referenceName, map: [:], isSystem: true))
        }
        for src in cfList {
            guard let id = sourceID(of: src), id != referenceID else { continue }
            guard sourceEnabled(of: src) else { continue }
            guard let data = layoutData(of: src) else { continue }
            let name = sourceName(of: src) ?? id
            let map = positionalMap(usData: usData, targetData: data)
            guard map.count >= 5 else { continue } // not a real letter mapping
            out.append(KeyboardLayout(id: id, name: name, map: map, isSystem: true))
        }
        let found = out.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        NSLog("Langy: discovered %d system layouts", found.count)
        return found
    }

    private func sourceID(of src: TISInputSource) -> String? {
        guard let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    private func sourceName(of src: TISInputSource) -> String? {
        guard let ptr = TISGetInputSourceProperty(src, kTISPropertyLocalizedName) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    private func sourceEnabled(of src: TISInputSource) -> Bool {
        guard let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceIsEnabled) else { return true }
        return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(ptr).takeUnretainedValue())
    }

    private func layoutData(of src: TISInputSource) -> Data? {
        guard let ptr = TISGetInputSourceProperty(src, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        let cfData = Unmanaged<CFData>.fromOpaque(ptr).takeUnretainedValue() as Data
        return cfData
    }

    /// Build US-char → layout-char map by translating every keycode through both layouts.
    private func positionalMap(usData: Data, targetData: Data) -> [String: String] {
        var map: [String: String] = [:]
        usData.withUnsafeBytes { usRaw in
            targetData.withUnsafeBytes { tgtRaw in
                guard let usBase = usRaw.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self),
                      let tgtBase = tgtRaw.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self)
                else { return }
                for keyCode in 0 ..< 128 {
                    guard let usChar = displayChar(layout: usBase, keyCode: UInt16(keyCode)) else { continue }
                    // Only ASCII keys define positions (digits stay digits in most layouts).
                    guard usChar.isASCII, usChar != "\0" else { continue }
                    let usStr = String(usChar).lowercased()
                    guard usStr.count == 1, usStr.rangeOfCharacter(from: .alphanumerics.union(.init(charactersIn: "`-=[]\\;',./"))) != nil else { continue }
                    guard let local = displayChar(layout: tgtBase, keyCode: UInt16(keyCode)) else { continue }
                    let localStr = String(local)
                    guard localStr.count == 1, localStr != String(usChar) else { continue }
                    // Keep first mapping only; skip control chars.
                    guard local.unicodeScalars.allSatisfy({ !$0.properties.isDefaultIgnorableCodePoint }) else { continue }
                    if map[usStr] == nil { map[usStr] = localStr.lowercased() }
                }
            }
        }
        return map
    }

    private func displayChar(layout: UnsafePointer<UCKeyboardLayout>, keyCode: UInt16) -> Character? {
        var deadKeyState: UInt32 = 0
        var actualLength = 0
        var chars = [UniChar](repeating: 0, count: 4)
        let status: OSStatus = chars.withUnsafeMutableBufferPointer { buf -> OSStatus in
            guard let base = buf.baseAddress else { return OSStatus(paramErr) }
            return UCKeyTranslate(
                layout, keyCode, UInt16(kUCKeyActionDisplay),
                0, UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysMask),
                &deadKeyState, buf.count, &actualLength, base
            )
        }
        guard status == noErr, actualLength == 1,
              let scalar = UnicodeScalar(chars[0]) else { return nil }
        return Character(scalar)
    }
}
