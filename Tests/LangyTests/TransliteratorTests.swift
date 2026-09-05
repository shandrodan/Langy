import Foundation
import XCTest
@testable import Langy

final class TransliteratorTests: XCTestCase {
    private func makeTransliterator(
        _ layouts: [KeyboardLayout],
        revision: UInt64 = 1
    ) -> Transliterator {
        let transliterator = Transliterator()
        transliterator.updateLayouts(layouts, revision: revision)
        return transliterator
    }

    func testOptimizedTransliteratorMatchesReference() {
        let layouts = [
            KeyboardLayout(id: "us", name: "English", map: [:], isSystem: false),
            KeyboardLayout(
                id: "de", name: "German",
                map: ["y": "z", "z": "y", "a": "ä", "b": "ö"],
                isSystem: false
            ),
            KeyboardLayout(
                id: "el", name: "Greek",
                map: ["a": "α", "b": "β", "g": "γ"],
                isSystem: false
            ),
            KeyboardLayout(
                id: "ar", name: "Arabic",
                map: ["a": "ش", "b": "لا", "q": "ض"],
                isSystem: false
            )
        ]
        let inputs = [
            "type Y",
            "zebra",
            "Ä🙂 mixed",
            "καλημέρα",
            "hello, world! 👋",
            "a\u{301}",
            "لا"
        ]

        for input in inputs {
            let optimized = makeTransliterator(layouts)
            let reference = ReferenceTransliterator(layouts: layouts)
            let actual = optimized.next(for: input)
            let expected = reference.next(for: input)

            XCTAssertEqual(actual?.text, expected?.text, "text mismatch for \(input)")
            XCTAssertEqual(actual?.layout?.id, expected?.layout?.id, "layout mismatch for \(input)")
        }
    }

    func testRoundRobinStateIncludesIdenticalRenderedLayouts() {
        let layouts = [
            KeyboardLayout(id: "us", name: "English", map: [:], isSystem: false),
            KeyboardLayout(id: "first", name: "First", map: ["a": "ä"], isSystem: false),
            KeyboardLayout(id: "second", name: "Second", map: ["a": "ä"], isSystem: false)
        ]
        let transliterator = makeTransliterator(layouts)

        let first = transliterator.next(for: "a")
        XCTAssertEqual(first?.text, "ä")
        XCTAssertEqual(first?.layout?.id, "first")

        let second = transliterator.next(for: "ä")
        XCTAssertEqual(second?.text, "ä")
        XCTAssertEqual(second?.layout?.id, "second")

        let third = transliterator.next(for: "ä")
        XCTAssertEqual(third?.text, "a")
        XCTAssertEqual(third?.layout?.id, "us")
    }

    func testCasePrecedenceAndMultiCharacterValues() {
        let transliterator = makeTransliterator([
            KeyboardLayout(
                id: "custom", name: "Custom",
                map: ["a": "ä", "A": "direct", "b": "لا"],
                isSystem: false
            )
        ])

        XCTAssertEqual(transliterator.apply(map: ["a": "ä", "A": "direct"], to: "Aa"), "directä")
        XCTAssertEqual(transliterator.apply(map: ["a": "ä", "b": "لا"], to: "A b B"), "Ä لا لا")
    }

    func testCompiledMapsRebuildWhenRevisionChanges() {
        let transliterator = Transliterator()
        transliterator.updateLayouts([
            KeyboardLayout(id: "one", name: "One", map: ["a": "ä"], isSystem: false)
        ], revision: 1)
        XCTAssertEqual(transliterator.next(for: "a")?.text, "ä")

        transliterator.reset()
        transliterator.updateLayouts([
            KeyboardLayout(id: "two", name: "Two", map: ["a": "ö"], isSystem: false)
        ], revision: 2)
        XCTAssertEqual(transliterator.next(for: "a")?.text, "ö")
        XCTAssertEqual(transliterator.layouts.first?.id, "two")
    }

    func testLayoutSnapshotIsCachedAndInvalidatedBySettings() {
        let suiteName = "LangyTests.\(UUID().uuidString)"
        let defaults = try! XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = LayoutStore(defaults: defaults)
        store.useSystemLayouts = false

        let first = store.effectiveLayoutSnapshot()
        let repeated = store.effectiveLayoutSnapshot()
        XCTAssertEqual(first.revision, repeated.revision)
        XCTAssertEqual(first.layouts, repeated.layouts)

        let custom = KeyboardLayout(
            id: "custom.test", name: "Test", map: ["a": "ä"], isSystem: false
        )
        store.addCustom(custom)
        let withCustom = store.effectiveLayoutSnapshot()
        XCTAssertNotEqual(withCustom.revision, first.revision)
        XCTAssertTrue(withCustom.layouts.contains(where: { $0.id == custom.id }))

        var disabled = store.disabledIDs
        disabled.insert(custom.id)
        store.disabledIDs = disabled
        let disabledSnapshot = store.effectiveLayoutSnapshot()
        XCTAssertNotEqual(disabledSnapshot.revision, withCustom.revision)
        XCTAssertFalse(disabledSnapshot.layouts.contains(where: { $0.id == custom.id }))

        disabled.remove(custom.id)
        store.disabledIDs = disabled
        let reenabled = store.effectiveLayoutSnapshot()
        XCTAssertTrue(reenabled.layouts.contains(where: { $0.id == custom.id }))
    }

    func testLargeTextConversionBenchmark() {
        let layouts = [
            KeyboardLayout(id: "us", name: "English", map: [:], isSystem: false),
            KeyboardLayout(id: "de", name: "German", map: ["a": "ä", "b": "ö", "y": "z"], isSystem: false),
            KeyboardLayout(id: "el", name: "Greek", map: ["a": "α", "b": "β", "g": "γ"], isSystem: false),
            KeyboardLayout(id: "ar", name: "Arabic", map: ["a": "ش", "b": "ل", "q": "ض"], isSystem: false)
        ]
        let text = String(repeating: "Ä mixed text 123! ", count: 500)
        let transliterator = makeTransliterator(layouts)

        measure {
            transliterator.reset()
            _ = transliterator.next(for: text)
        }
    }
}

/// The pre-optimization algorithm used as a behavior oracle. It deliberately
/// keeps the old allocation pattern so parity tests compare outputs rather
/// than sharing implementation details with the optimized code.
private final class ReferenceTransliterator {
    let layouts: [KeyboardLayout]
    private var lastBase: String?
    private var lastResult: String?
    private var lastIndex: Int = -1

    init(layouts: [KeyboardLayout]) {
        self.layouts = layouts
    }

    func next(for input: String) -> (text: String, layout: KeyboardLayout?)? {
        guard !layouts.isEmpty, !input.isEmpty else { return nil }
        if let base = lastBase, input == lastResult {
            let index = (lastIndex + 1) % layouts.count
            let layout = layouts[index]
            let text = apply(map: layout.map, to: base)
            lastResult = text
            lastIndex = index
            return (text, layout)
        }

        let (base, source) = decodeToPositional(input)
        let start = (source + 1) % layouts.count
        lastBase = base
        for k in 0 ..< layouts.count {
            let index = (start + k) % layouts.count
            let layout = layouts[index]
            let text = apply(map: layout.map, to: base)
            if text != input {
                lastResult = text
                lastIndex = index
                return (text, layout)
            }
        }
        return nil
    }

    private func apply(map: [String: String], to text: String) -> String {
        var out = ""
        out.reserveCapacity(text.count)
        for ch in text {
            let s = String(ch)
            if let direct = map[s] {
                out += direct
                continue
            }
            let lower = s.lowercased()
            if let mapped = map[lower] {
                out += ch.isUppercase ? mapped.uppercased() : mapped
            } else {
                out += s
            }
        }
        return out
    }

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
