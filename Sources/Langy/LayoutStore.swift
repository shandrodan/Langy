import AppKit
import Carbon

/// Immutable layout data handed to a conversion worker. The revision lets the
/// transliterator keep compiled maps alive until the effective list changes.
struct LayoutSnapshot {
    let layouts: [KeyboardLayout]
    let revision: UInt64
}

/// Discovers real system keyboard layouts via TIS + UCKeyTranslate,
/// merges them with built-ins and user customs, persists prefs.
/// Everything is lazy/on-demand — no polling, ~zero idle cost.
final class LayoutStore {
    static let shared = LayoutStore()

    private let defaults: UserDefaults
    private let kUseSystem = "langy.useSystemLayouts"
    private let kCustom = "langy.customLayouts"
    private let kDisabled = "langy.disabledLayoutIDs"

    private struct SettingsSnapshot {
        let useSystem: Bool
        let custom: [KeyboardLayout]
        let disabled: Set<String>
    }

    private struct PositionalMapCacheKey: Hashable {
        let referenceID: String?
        let targetID: String
        let referenceData: Data
        let targetData: Data
    }

    private static let sortedBuiltins = BuiltinLayouts.all.sorted {
        $0.name.localizedCompare($1.name) == .orderedAscending
    }

    // Settings are edited on the main queue while conversion reads them from
    // its serial worker queue. Keep all cached snapshots atomic across both.
    private let cacheLock = NSLock()
    private var settingsCache: SettingsSnapshot?
    private var cachedEffective: [KeyboardLayout]?
    private var cachedEffectiveRevision: UInt64?
    private var layoutRevision: UInt64 = 0

    var useSystemLayouts: Bool {
        get {
            cacheLock.lock()
            defer { cacheLock.unlock() }
            return settingsSnapshotLocked().useSystem
        }
        set {
            cacheLock.lock()
            defaults.set(newValue, forKey: kUseSystem)
            invalidateSettingsCachesLocked()
            cacheLock.unlock()
        }
    }

    var disabledIDs: Set<String> {
        get {
            cacheLock.lock()
            defer { cacheLock.unlock() }
            return settingsSnapshotLocked().disabled
        }
        set {
            cacheLock.lock()
            defaults.set(Array(newValue), forKey: kDisabled)
            invalidateSettingsCachesLocked()
            cacheLock.unlock()
        }
    }

    var customLayouts: [KeyboardLayout] {
        get {
            cacheLock.lock()
            defer { cacheLock.unlock() }
            return settingsSnapshotLocked().custom
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            cacheLock.lock()
            defaults.set(data, forKey: kCustom)
            invalidateSettingsCachesLocked()
            cacheLock.unlock()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
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
        effectiveLayoutSnapshot().layouts
    }

    /// Returns the effective list and a revision that changes whenever its
    /// inputs change or the live system-layout cache is refreshed.
    func effectiveLayoutSnapshot() -> LayoutSnapshot {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let settings = settingsSnapshotLocked()
        let now = Date()
        let systems = settings.useSystem ? systemLayoutsLocked(now: now) : []
        if let cachedEffective, cachedEffectiveRevision == layoutRevision {
            return LayoutSnapshot(layouts: cachedEffective, revision: layoutRevision)
        }

        var out: [KeyboardLayout] = []
        var seen = Set<String>()
        let disabled = settings.disabled
        out.reserveCapacity(systems.count + settings.custom.count + Self.sortedBuiltins.count)

        for l in systems where !disabled.contains(l.id) {
            out.append(l); seen.insert(l.id)
        }
        for l in settings.custom where !seen.contains(l.id) && !disabled.contains(l.id) {
            out.append(l); seen.insert(l.id)
        }
        if !settings.useSystem {
            for b in Self.sortedBuiltins
                where !seen.contains(b.id) && !disabled.contains(b.id) {
                out.append(b); seen.insert(b.id)
            }
        }
        cachedEffective = out
        cachedEffectiveRevision = layoutRevision
        return LayoutSnapshot(layouts: out, revision: layoutRevision)
    }

    /// Everything known (for the settings list), with enabled flags derived from disabledIDs.
    func allKnownLayouts() -> [KeyboardLayout] {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        let settings = settingsSnapshotLocked()
        var out: [KeyboardLayout] = []
        var seen = Set<String>()
        let systems = settings.useSystem ? systemLayoutsLocked(now: Date()) : []
        for l in systems { out.append(l); seen.insert(l.id) }
        for l in settings.custom where !seen.contains(l.id) { out.append(l); seen.insert(l.id) }
        if !settings.useSystem {
            for b in Self.sortedBuiltins
                where !seen.contains(b.id) {
                out.append(b); seen.insert(b.id)
            }
        }
        return out
    }

    // MARK: - System discovery

    private var cachedSystem: [KeyboardLayout]?
    private var cachedAt: Date = .distantPast
    private var positionalMapCache: [PositionalMapCacheKey: [String: String]] = [:]

    /// Cached for 30s — rescanning TIS on every keypress would waste cycles.
    func systemLayouts() -> [KeyboardLayout] {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return systemLayoutsLocked(now: Date())
    }

    private func systemLayoutsLocked(now: Date) -> [KeyboardLayout] {
        if let c = cachedSystem, now.timeIntervalSince(cachedAt) < 30 { return c }
        let found = discoverSystemLayouts()
        cachedSystem = found
        // Preserve the previous behavior: the TTL starts after discovery,
        // not before the potentially expensive TIS scan.
        cachedAt = Date()
        layoutRevision &+= 1
        return found
    }

    func refreshSystemLayouts() {
        cacheLock.lock()
        cachedAt = .distantPast
        cachedSystem = nil
        cachedEffective = nil
        cachedEffectiveRevision = nil
        layoutRevision &+= 1
        _ = systemLayoutsLocked(now: Date())
        cacheLock.unlock()
    }

    private func settingsSnapshotLocked() -> SettingsSnapshot {
        if let settingsCache { return settingsCache }

        let useSystem = defaults.object(forKey: kUseSystem) == nil
            ? true
            : defaults.bool(forKey: kUseSystem)
        let disabled = Set(defaults.stringArray(forKey: kDisabled) ?? [])
        let custom: [KeyboardLayout]
        if let data = defaults.data(forKey: kCustom),
           let decoded = try? JSONDecoder().decode([KeyboardLayout].self, from: data) {
            custom = decoded
        } else {
            custom = []
        }

        let snapshot = SettingsSnapshot(useSystem: useSystem, custom: custom, disabled: disabled)
        settingsCache = snapshot
        return snapshot
    }

    private func invalidateSettingsCachesLocked() {
        settingsCache = nil
        cachedEffective = nil
        cachedEffectiveRevision = nil
        layoutRevision &+= 1
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
            let key = PositionalMapCacheKey(
                referenceID: referenceID,
                targetID: id,
                referenceData: usData,
                targetData: data
            )
            let map: [String: String]
            if let cached = positionalMapCache[key] {
                map = cached
            } else {
                map = positionalMap(usData: usData, targetData: data)
                positionalMapCache[key] = map
            }
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
