import Foundation
import XCTest
@testable import Langy

final class LanguageCoverageTests: XCTestCase {
    // A product coverage roster, NOT a demographic ranking. Serbian scripts
    // count as one language; Arabic and Hebrew are additional catalog tests.
    private let roster: [(id: String, name: String)] = [
        ("sq", "Albanian"), ("az", "Azerbaijani"), ("eu", "Basque"),
        ("be", "Belarusian"), ("bs", "Bosnian"), ("br", "Breton"),
        ("bg", "Bulgarian"), ("ca", "Catalan"), ("co", "Corsican"),
        ("hr", "Croatian"), ("cs", "Czech"), ("da", "Danish"),
        ("nl", "Dutch"), ("en", "English"), ("et", "Estonian"),
        ("fo", "Faroese"), ("fi", "Finnish"), ("fr", "French"),
        ("fy", "Frisian"), ("gl", "Galician"), ("ka", "Georgian"),
        ("de", "German"), ("el", "Greek"), ("hu", "Hungarian"),
        ("is", "Icelandic"), ("ga", "Irish"), ("it", "Italian"),
        ("lv", "Latvian"), ("lt", "Lithuanian"), ("lb", "Luxembourgish"),
        ("mk", "Macedonian"), ("mt", "Maltese"), ("me", "Montenegrin"),
        ("no", "Norwegian"), ("oc", "Occitan"), ("pl", "Polish"),
        ("pt", "Portuguese"), ("ro", "Romanian"), ("rm", "Romansh"),
        ("ru", "Russian"), ("sc", "Sardinian"), ("gd", "Scottish Gaelic"),
        ("sr", "Serbian"), ("sk", "Slovak"), ("sl", "Slovenian"),
        ("es", "Spanish"), ("sv", "Swedish"), ("tr", "Turkish"),
        ("uk", "Ukrainian"), ("cy", "Welsh")
    ]
    private let positions = "`1234567890-=qwertyuiop[]\\asdfghjkl;'zxcvbnm,./"
    private let preserved = " \t\n\r\n\u{1F642}\u{1F469}\u{200D}\u{1F4BB}\u{10437}"

    private func engine(_ layouts: [KeyboardLayout]) -> Transliterator {
        let result = Transliterator()
        result.updateLayouts(layouts, revision: 1)
        return result
    }

    func testRosterAndCatalogIntegrity() {
        XCTAssertEqual(roster.count, 50)
        XCTAssertEqual(Set(roster.map(\.id)).count, 50)
        XCTAssertEqual(Set(BuiltinLayouts.all.map(\.id)).count, BuiltinLayouts.all.count)
        for layout in BuiltinLayouts.all {
            XCTAssertFalse(layout.name.isEmpty)
            for (key, value) in layout.map {
                XCTAssertEqual(key.count, 1, "\(layout.id): positional key \(key)")
                XCTAssertFalse(value.isEmpty, "\(layout.id): empty output for \(key)")
            }
        }
    }

    func testAllBuiltinsPreserveUnmappedUnicodeAndWhitespace() {
        for layout in BuiltinLayouts.all {
            XCTAssertEqual(engine([layout]).apply(map: layout.map, to: preserved), preserved, layout.id)
        }
    }

    func testAllBuiltinsCycleWithoutLosingTheCachedPositionalBase() throws {
        let layouts = BuiltinLayouts.all.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        let converter = engine(layouts)
        let base = positions + preserved
        let first = try XCTUnwrap(converter.next(for: base))
        let firstIndex = try XCTUnwrap(layouts.firstIndex { $0.id == first.layout?.id })
        XCTAssertEqual(first.text, converter.apply(map: layouts[firstIndex].map, to: base))
        var text = first.text
        for step in 1...layouts.count * 2 {
            let expected = layouts[(firstIndex + step) % layouts.count]
            let result = try XCTUnwrap(converter.next(for: text))
            XCTAssertEqual(result.layout?.id, expected.id)
            XCTAssertEqual(result.text, converter.apply(map: expected.map, to: base), expected.id)
            text = result.text
        }
    }

    func testCanonicalEquivalentFrenchInput() throws {
        let us = try XCTUnwrap(BuiltinLayouts.all.first { $0.id == "builtin.en" })
        let fr = try XCTUnwrap(BuiltinLayouts.all.first { $0.id == "builtin.fr" })
        for input in ["\u{00E9}", "e\u{0301}"] {
            XCTAssertEqual(engine([us, fr]).next(for: input)?.text, "2")
        }
    }

    func testEmptyInputAndNoLayouts() {
        XCTAssertNil(engine([]).next(for: positions))
        XCTAssertNil(engine(BuiltinLayouts.all).next(for: ""))
        XCTAssertNil(engine(BuiltinLayouts.all).next(for: preserved))
    }

    /// Collects failures without blessing them as supported behavior. Strict
    /// mode writes the same report, then fails the test if any gaps remain.
    func testLanguageCoverageAudit() throws {
        guard let path = ProcessInfo.processInfo.environment["LANGY_LANGUAGE_AUDIT_REPORT"],
              !path.isEmpty else {
            throw XCTSkip("Set LANGY_LANGUAGE_AUDIT_REPORT to collect the 50-language audit.")
        }
        guard path.hasPrefix("/") else {
            XCTFail("LANGY_LANGUAGE_AUDIT_REPORT must be an absolute path.")
            return
        }
        let layouts = BuiltinLayouts.all.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        let us = try XCTUnwrap(layouts.first { $0.id == "builtin.en" })
        let converter = engine(layouts)
        // Separate keys so multi-character output cannot accidentally join the
        // next key's output. Independent goldens below also test normal words.
        let base = positions.map(String.init).joined(separator: " ") + preserved
        let rendered = Dictionary(uniqueKeysWithValues: layouts.map {
            ($0.id, converter.apply(map: $0.map, to: base))
        })
        var rows: [String] = []
        var details: [String] = []
        var missing = 0
        var empty = 0
        var reverseFailures = 0
        var fullCatalogFailures = 0
        var reverseChecks = 0

        for language in roster {
            let ids = language.id == "sr" ? ["builtin.sr-cyrl", "builtin.sr-latn"] : ["builtin.\(language.id)"]
            for id in ids {
                guard let layout = layouts.first(where: { $0.id == id }), let text = rendered[id] else {
                    missing += 1
                    rows.append("| \(language.name) | \(id) | MISSING | Not tested | Not tested | Not tested |")
                    continue
                }
                let aliases = layouts.filter { $0.id != id && $0.map == layout.map }.map(\.id).sorted()
                let kind = layout.map.isEmpty ? (id == us.id ? "US identity reference" : "EMPTY: identity only") :
                    "\(layout.map.count) entries" + (aliases.isEmpty ? "" : "; shared map")
                if !aliases.isEmpty {
                    details.append("- \(id) has the same dictionary as: \(aliases.joined(separator: ", ")).")
                }
                if layout.map.isEmpty && id != us.id { empty += 1 }
                if id == us.id || text == base {
                    rows.append("| \(language.name) | \(id) | \(kind) | Identity; not evidence | Identity; not evidence | Included |")
                    continue
                }
                reverseChecks += 1
                let recovered = engine([us, layout]).next(for: text)
                let reverseOK = recovered?.layout?.id == us.id && recovered?.text == base
                if !reverseOK {
                    reverseFailures += 1
                    details.append("- \(id) fresh reverse: expected \(shown(base)), got \(shown(recovered?.text)).")
                }

                let full = engine(layouts)
                var input = text
                var recoveredUS: String?
                for _ in 0..<layouts.count {
                    guard let result = full.next(for: input) else { break }
                    if result.layout?.id == us.id { recoveredUS = result.text; break }
                    input = result.text
                }
                let fullOK = recoveredUS == base
                if !fullOK { fullCatalogFailures += 1 }
                rows.append("| \(language.name) | \(id) | \(kind) | \(reverseOK ? "PASS" : "FAIL") | \(fullOK ? "PASS" : "FAIL") | Included |")
            }
        }

        var pairPasses = 0
        var pairFailures = 0
        var indistinguishable = 0
        var pairRows: [String] = []
        for source in layouts {
            var failedTargets: [String] = []
            var passed = 0
            var identical = 0
            for target in layouts where source.id != target.id {
                let input = try XCTUnwrap(rendered[source.id])
                let expected = try XCTUnwrap(rendered[target.id])
                if input == expected {
                    indistinguishable += 1
                    identical += 1
                    continue
                }
                let result = engine([source, target]).next(for: input)
                if result?.layout?.id == target.id && result?.text == expected {
                    passed += 1
                    pairPasses += 1
                } else {
                    pairFailures += 1
                    failedTargets.append(target.id)
                }
            }
            pairRows.append("| \(source.id) | \(passed) | \(failedTargets.count) | \(identical) | \(failedTargets.joined(separator: ", ")) |")
        }
        XCTAssertEqual(pairPasses + pairFailures + indistinguishable, layouts.count * (layouts.count - 1))

        // Independent fixed expectations from the pinned XKB definitions linked
        // in Docs/LanguageVerification.md. Variants and modifiers are explicit.
        // Escapes keep the fixtures' exact Unicode code points reviewable.
        let goldens: [(id: String, variant: String, input: String, expected: String)] = [
            ("de", "de(basic)", "y-z[;'", "z\u{00DF}y\u{00FC}\u{00F6}\u{00E4}"),
            ("fr", "fr(basic)", "q2;", "a\u{00E9}m"),
            ("el", "gr(basic)", "qws", ";\u{03C2}\u{03C3}"),
            ("be", "by(basic)", "o]b/", "\u{045E}'\u{0456}."),
            ("bg", "bg(phonetic)", "q[]x", "\u{044F}\u{0448}\u{0449}\u{044C}"),
            ("sr-cyrl", "rs(basic)", "qwyzx", "\u{0459}\u{045A}\u{0437}\u{0436}\u{045F}"),
            ("sr-latn", "rs(latin)", "\\=", "\u{017E}+"),
            ("tr", "tr(basic)", "i'\\", "\u{0131}i,"),
            ("is", "is(basic), is(mac)", "[-;/", "\u{00F0}\u{00F6}\u{00E6}\u{00FE}"),
            ("fo", "fo(basic)", "[];'", "\u{00E5}\u{00F0}\u{00E6}\u{00F8}"),
            ("az", "az(latin)", "wi[];'", "\u{00FC}i\u{00F6}\u{011F}\u{0131}\u{0259}"),
            ("pl", "pl(basic), UNMODIFIED ONLY", "acelnosxz", "acelnosxz"),
            ("mt", "mt(us)", "`[]\\", "\u{010B}\u{0121}\u{0127}\u{017C}"),
            ("de", "de(basic), Shift+[", "{", "\u{00DC}"),
            ("fr", "fr(basic), Shift+m", "M", "?"),
            ("el", "gr(basic), Shift+q", "Q", ":"),
            ("tr", "tr(basic), Shift+'", "\"", "\u{0130}"),
            ("ru", "ru(winkeys)", "ghbdtn", "\u{043F}\u{0440}\u{0438}\u{0432}\u{0435}\u{0442}"),
            ("uk", "ua(unicode)", "s]'\\", "\u{0456}\u{0457}\u{0454}\u{0491}"),
            ("mk", "mk(basic)", "y]'\\x", "\u{0455}\u{0453}\u{045C}\u{0436}\u{045F}")
        ]
        var goldenFailures = 0
        let goldenRows = goldens.map { sample -> String in
            let layout = layouts.first { $0.id == "builtin.\(sample.id)" }
            let actual = layout.map { converter.apply(map: $0.map, to: sample.input) }
            let ok = actual == sample.expected
            if !ok { goldenFailures += 1 }
            return "| \(sample.id) | \(sample.variant) | \(shown(sample.input)) | \(shown(sample.expected)) | \(shown(actual)) | \(ok ? "PASS" : (layout == nil ? "MISSING" : "DIFFERS")) |"
        }

        let reverseGoldens: [(id: String, input: String, expected: String)] = [
            ("de", "z\u{00F6}", "y;"), ("fr", "a\u{00E9}m", "q2;"),
            ("el", ";\u{03C2}", "qw"), ("de", "\u{00C4}", "\""),
            ("ar", "\u{0644}\u{0627}", "b")
        ]
        var reverseGoldenFailures = 0
        let reverseRows = try reverseGoldens.map { sample -> String in
            let layout = try XCTUnwrap(layouts.first { $0.id == "builtin.\(sample.id)" })
            let result = engine([us, layout]).next(for: sample.input)
            let ok = result?.text == sample.expected && result?.layout?.id == us.id
            if !ok { reverseGoldenFailures += 1 }
            return "| \(sample.id) | \(shown(sample.input)) | \(shown(sample.expected)) | \(shown(result?.text)) | \(ok ? "PASS" : "FAIL") |"
        }

        let strict = ProcessInfo.processInfo.environment["LANGY_AUDIT_STRICT"] == "1"
        let hasGaps = missing + empty + reverseFailures + fullCatalogFailures + pairFailures + goldenFailures + reverseGoldenFailures > 0
        let status = hasGaps ? "NOT VERIFIED: GAPS FOUND" : "NO FAILURES IN LIMITED SAMPLES; NOT FULL LANGUAGE CERTIFICATION"
        let report = [
            "# Langy 50-Language Engine Audit", "", "**\(status)**", "",
            "- Generated: \(ISO8601DateFormatter().string(from: Date()))",
            "- Host: \(ProcessInfo.processInfo.operatingSystemVersionString)",
            "- Roster: 50 distinct product language labels, 51 requested layouts including both Serbian scripts. Not a demographic top-50 ranking.",
            "- Missing builtins: \(missing). Non-English identity-only entries: \(empty).",
            "- Fresh isolated reverse: \(reverseChecks - reverseFailures)/\(reverseChecks) exact recoveries of the key-position corpus.",
            "- Fresh full-catalog source detection followed by cycling to US: \(reverseChecks - fullCatalogFailures)/\(reverseChecks) exact recoveries.",
            "- All \(layouts.count) shipped layouts, directed pairs: \(pairPasses) pass, \(pairFailures) fail, \(indistinguishable) indistinguishable; \(pairPasses + pairFailures + indistinguishable) total.",
            "- Independent XKB variant/Shift fixtures: \(goldens.count - goldenFailures)/\(goldens.count) agree; \(goldenFailures) differ or are missing.",
            "- Fresh reverse diagnostic fixtures: \(reverseGoldens.count - reverseGoldenFailures)/\(reverseGoldens.count) pass.",
            "- Strict mode: \(strict). A successful reporting invocation means collection succeeded, NOT that support passed.", "",
            "## Method", "",
            "Every reverse case gets a new production Transliterator. Isolated tests enable US plus the target; full-catalog tests use LayoutStore's localized name ordering and look for the US result within one cycle. Directed-pair tests enable exactly source and target and require the very first conversion to return the target ID and exact expected text. Identical renderings are excluded rather than counted as support.", "",
            "The key-position corpus is \(shown(base)). Its forward renderings come from the shipped maps: these tests measure internal recoverability, NOT independent keyboard correctness. They intentionally include punctuation and digits, not just easy alphabetic words. Cached-cycle and Unicode-preservation assertions run as separate ordinary tests. A PASS here covers only the specified corpus, not arbitrary prose or all keyboard layers.", "",
            "Independent keyboard correctness comes from the pinned XKB fixtures below and the separate live macOS report. Different named variants can legitimately disagree. No language model, translation, linguistic quality, Accessibility writes, hotkeys, or real host-editor integration is certified here. No active keyboard or app preference is changed.", "",
            "## Language Matrix", "",
            "Identity rows are not reverse-test passes. Included means visited by the separate cached-cycle test, not independent correctness. Russian/Ukrainian can still be available in system mode despite absent builtins.", "",
            "| Language | Builtin ID | Map coverage | Fresh reverse to US | Full-catalog recovery | Cached cycle |",
            "| --- | --- | --- | --- | --- | --- |"
        ] + rows + [
            "", "## Independent Forward Fixtures", "",
            "XKB 2.42 distribution source, pinned at 873c813bf1ed4adfb231ea2afd295e5366cf62d5. Exact links and scope: [verification guide](LanguageVerification.md). Plain inputs denote US physical positions; Shift cases use the character produced by US with Shift held. Polish's unchanged plain letters do not test AltGr diacritics.", "",
            "| Builtin | XKB variant / layer | US input | Expected | Actual | Result |",
            "| --- | --- | --- | --- | --- | --- |"
        ] + goldenRows + [
            "", "## Fresh Reverse Diagnostics", "",
            "German, French and Greek base fixtures use the same independent key positions as above. German uppercase tests the actual Shift+quote US position, not Unicode case conversion. Arabic lam-alef is an extra multi-character diagnostic: the shipped map emits it from b, but gh can emit the same sequence, so exact fresh recovery is intrinsically ambiguous without keystroke/source context.", "",
            "| Source | Fresh input | Expected US positions | Actual | Result |",
            "| --- | --- | --- | --- | --- |"
        ] + reverseRows + [
            "", "## Directed Pair Results", "",
            "Includes Arabic/Hebrew as additional shipped layouts; this is not a claim of 50 distinct languages. Equal-rendering pairs are excluded; aliases and identity-only entries also duplicate pass/fail outcomes against other targets. Totals are per catalog ID, not independent language or map coverage.", "",
            "| Source | Pass | Fail | Indistinguishable | Failed target IDs |",
            "| --- | ---: | ---: | ---: | --- |"
        ] + pairRows + ["", "## Reverse Details and Shared Maps", ""] + details + [""]
        try report.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
        print("Langy language audit: \(status). Pairs \(pairPasses) pass / \(pairFailures) fail / \(indistinguishable) identical. Report: \(path)")
        if strict && hasGaps {
            XCTFail("50-language support not verified: \(missing) missing builtins, \(empty) identity-only languages, \(reverseFailures) isolated reverse failures, \(pairFailures) pair failures, \(goldenFailures) independent fixture gaps. See report.")
        }
    }

    private func shown(_ value: String?) -> String {
        guard let value else { return "NOT PRODUCED" }
        let escaped = value.debugDescription
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "|", with: "&#124;")
            .replacingOccurrences(of: "`", with: "&#96;")
            .replacingOccurrences(of: "\\", with: "&#92;")
        return "<code>\(escaped)</code>"
    }
}
