import Foundation

/// Cycles one mistyped string through the enabled layouts, in ANY direction.
/// Every call advances exactly one layout (strict round-robin), so repeated
/// presses scroll through every enabled layout even when two of them render
/// a word identically.
///
/// Model: every layout maps US key positions to its own characters, so any
/// text is first decoded back to positional (ASCII) form via the best-matching
/// layout, then encoded with the next layout. Works from and to any layout.
final class Transliterator {
    private struct CompiledMap {
        /// Fast path for the normal one-Character keys used by system and
        /// built-in layouts. The original map remains available for Unicode
        /// case-folding and multi-character edge cases.
        let exact: [Character: String]
        let strings: [String: String]

        init(_ map: [String: String]) {
            strings = map
            var exact: [Character: String] = [:]
            exact.reserveCapacity(map.count)
            for (key, value) in map where key.count == 1 {
                if let character = key.first {
                    exact[character] = value
                }
            }
            self.exact = exact
        }

        var isEmpty: Bool { strings.isEmpty }
    }

    private struct CompiledLayout {
        let layout: KeyboardLayout
        let forward: CompiledMap
        let reverse: [String: String]

        init(_ layout: KeyboardLayout) {
            self.layout = layout
            self.forward = CompiledMap(layout.map)
            self.reverse = Transliterator.reverseMap(for: layout.map)
        }
    }

    private(set) var layouts: [KeyboardLayout] = []
    private var compiledLayouts: [CompiledLayout] = []
    private var compiledRevision: UInt64?

    private var lastBase: String?
    private var lastResult: String?
    private var lastIndex: Int = -1

    /// Installs a layout snapshot and compiles its maps only when the
    /// effective list has changed. Conversion always supplies a revision from
    /// LayoutStore, so repeated presses do not rebuild these dictionaries.
    func updateLayouts(_ newLayouts: [KeyboardLayout], revision: UInt64) {
        guard compiledRevision != revision else { return }
        layouts = newLayouts
        compiledLayouts = newLayouts.map { CompiledLayout($0) }
        compiledRevision = revision
    }

    /// Returns the next variant for `input`, plus which layout produced it.
    /// The first press always visibly converts when any layout can; further
    /// presses step strictly through every layout so each one gets its turn.
    /// Returns nil only when conversion is impossible (no layouts / empty
    /// input / no layout changes the text).
    func next(for input: String) -> (text: String, layout: KeyboardLayout?)? {
        guard !compiledLayouts.isEmpty, !input.isEmpty else { return nil }
        if let b = lastBase, input == lastResult {
            // Same text as we just produced → step to the next layout,
            // even if it renders this word identically.
            let base = b
            let index = (lastIndex + 1) % compiledLayouts.count
            let compiled = compiledLayouts[index]
            let text = apply(compiledMap: compiled.forward, to: base)
            lastResult = text
            lastIndex = index
            return (text, compiled.layout)
        }
        // Fresh text: detect which layout it is in, continue after it,
        // taking the first layout that visibly changes it.
        let (base, source) = decodeToPositional(input)
        let start = (source + 1) % compiledLayouts.count
        lastBase = base
        for k in 0 ..< compiledLayouts.count {
            let j = (start + k) % compiledLayouts.count
            let compiled = compiledLayouts[j]
            let text = apply(compiledMap: compiled.forward, to: base)
            if text != input {
                lastResult = text
                lastIndex = j
                return (text, compiled.layout)
            }
        }
        return nil
    }

    func reset() {
        lastBase = nil; lastResult = nil; lastIndex = -1
    }

    // MARK: - Mapping

    /// Kept as the map-based helper for callers and tests. The conversion hot
    /// path uses the compiled overload below.
    func apply(map: [String: String], to text: String) -> String {
        apply(compiledMap: CompiledMap(map), to: text)
    }

    private func apply(compiledMap: CompiledMap, to text: String) -> String {
        guard !compiledMap.isEmpty else { return text }

        var out = ""
        out.reserveCapacity(text.count)
        for ch in text {
            if let direct = compiledMap.exact[ch] {
                out.append(contentsOf: direct)
                continue
            }

            let s = String(ch)
            let lower = s.lowercased()
            if let mapped = compiledMap.strings[lower] {
                out.append(contentsOf: ch.isUppercase ? mapped.uppercased() : mapped)
            } else {
                out.append(ch)
            }
        }
        return out
    }

    /// Decode `text` to positional (ASCII) form.
    /// Returns the decoded text plus the index of the layout it was decoded
    /// with, or -1 when the text is already positional / undecodable.
    private func decodeToPositional(_ text: String) -> (String, Int) {
        guard text.unicodeScalars.contains(where: { !$0.isASCII }) else {
            return (text, -1)
        }

        // Count first and materialize only the winning candidate. The old
        // implementation built a full temporary String for every layout even
        // when that layout could not win.
        var bestIndex = -1
        var bestHits = 0
        for (i, layout) in compiledLayouts.enumerated() {
            let hits = countHits(in: text, reverse: layout.reverse)
            if hits > bestHits {
                bestHits = hits
                bestIndex = i
            }
        }

        guard bestHits > 0 else { return (text, -1) }
        return (decode(text, using: compiledLayouts[bestIndex].reverse), bestIndex)
    }

    private func countHits(in text: String, reverse: [String: String]) -> Int {
        var hits = 0
        for ch in text {
            guard isForeign(ch) else { continue }
            let s = String(ch)
            if reverse[s] != nil || reverse[s.lowercased()] != nil {
                hits += 1
            }
        }
        return hits
    }

    private func decode(_ text: String, using reverse: [String: String]) -> String {
        var decoded = ""
        decoded.reserveCapacity(text.count)
        for ch in text {
            guard isForeign(ch) else {
                decoded.append(ch)
                continue
            }

            let s = String(ch)
            if let en = reverse[s] ?? reverse[s.lowercased()] {
                decoded.append(contentsOf: ch.isUppercase ? en.uppercased() : en)
            } else {
                decoded.append(ch)
            }
        }
        return decoded
    }

    private func isForeign(_ character: Character) -> Bool {
        !character.unicodeScalars.allSatisfy { $0.isASCII }
    }

    private static func reverseMap(for map: [String: String]) -> [String: String] {
        var reverse: [String: String] = [:]
        reverse.reserveCapacity(map.count)
        for (en, local) in map {
            if reverse[local] == nil { reverse[local] = en }
        }
        return reverse
    }
}
