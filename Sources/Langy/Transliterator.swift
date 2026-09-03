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
    var layouts: [KeyboardLayout] = []

    private var lastBase: String?
    private var lastResult: String?
    private var lastIndex: Int = -1

    /// Returns the next variant for `input`, plus which layout produced it.
    /// The first press always visibly converts when any layout can; further
    /// presses step strictly through every layout so each one gets its turn.
    /// Returns nil only when conversion is impossible (no layouts / empty
    /// input / no layout changes the text).
    func next(for input: String) -> (text: String, layout: KeyboardLayout?)? {
        guard !layouts.isEmpty, !input.isEmpty else { return nil }
        if let b = lastBase, input == lastResult {
            // Same text as we just produced → step to the next layout,
            // even if it renders this word identically.
            let base = b
            let index = (lastIndex + 1) % layouts.count
            let layout = layouts[index]
            let text = apply(map: layout.map, to: base)
            lastResult = text
            lastIndex = index
            return (text, layout)
        }
        // Fresh text: detect which layout it is in, continue after it,
        // taking the first layout that visibly changes it.
        let (base, source) = decodeToPositional(input)
        let start = (source + 1) % layouts.count
        lastBase = base
        for k in 0 ..< layouts.count {
            let j = (start + k) % layouts.count
            let text = apply(map: layouts[j].map, to: base)
            if text != input {
                lastResult = text
                lastIndex = j
                return (text, layouts[j])
            }
        }
        return nil
    }

    func reset() {
        lastBase = nil; lastResult = nil; lastIndex = -1
    }

    // MARK: - Mapping

    func apply(map: [String: String], to text: String) -> String {
        var out = ""
        out.reserveCapacity(text.count)
        for ch in text {
            let s = String(ch)
            if let direct = map[s] { out += direct; continue }
            let lower = s.lowercased()
            if let mapped = map[lower] {
                out += ch.isUppercase ? mapped.uppercased() : mapped
            } else {
                out += s
            }
        }
        return out
    }

    /// Decode `text` to positional (ASCII) form.
    /// Returns the decoded text plus the index of the layout it was decoded
    /// with, or -1 when the text is already positional / undecodable.
    private func decodeToPositional(_ text: String) -> (String, Int) {
        let foreign = text.unicodeScalars.filter { !$0.isASCII }
        guard !foreign.isEmpty else { return (text, -1) }
        var bestIndex = -1
        var bestHits = 0
        var bestText = text
        for (i, layout) in layouts.enumerated() {
            var reverse: [String: String] = [:]
            for (en, local) in layout.map {
                if reverse[local] == nil { reverse[local] = en }
            }
            var candidate = ""
            candidate.reserveCapacity(text.count)
            var hits = 0
            for ch in text {
                let s = String(ch)
                if !s.unicodeScalars.allSatisfy({ $0.isASCII }),
                   let en = reverse[s] ?? reverse[s.lowercased()] {
                    candidate += ch.isUppercase ? en.uppercased() : en
                    hits += 1
                } else {
                    candidate += s
                }
            }
            if hits > bestHits {
                bestHits = hits
                bestIndex = i
                bestText = candidate
            }
        }
        guard bestHits > 0 else { return (text, -1) }
        return (bestText, bestIndex)
    }
}
