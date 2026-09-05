import Carbon
import Foundation
import XCTest
@testable import Langy

final class SystemLayoutAuditTests: XCTestCase {
    /// Opt in with LANGY_SYSTEM_AUDIT_REPORT=/absolute/path/report.md.
    /// A normal XCTest pass means the report was generated, not that layouts are correct.
    func testSystemLayoutAudit() throws {
        guard let path = ProcessInfo.processInfo.environment["LANGY_SYSTEM_AUDIT_REPORT"],
              !path.isEmpty else {
            throw XCTSkip("Set LANGY_SYSTEM_AUDIT_REPORT to an absolute report path to audit live macOS layouts.")
        }
        guard path.hasPrefix("/") else {
            XCTFail("LANGY_SYSTEM_AUDIT_REPORT must be an absolute file path.")
            return
        }
        let strict = ProcessInfo.processInfo.environment["LANGY_AUDIT_STRICT"] == "1"
        let keyboardType = UInt32(LMGetKbdType())
        let hardwareType = KBGetLayoutType(Int16(keyboardType))
        let hardwareName = hardwareType == kKeyboardANSI ? "ANSI" :
            (hardwareType == kKeyboardISO ? "ISO" : (hardwareType == kKeyboardJIS ? "JIS" : "unknown"))
        let filter = [kTISPropertyInputSourceType as String: kTISTypeKeyboardLayout as String]
        let rawSources = try XCTUnwrap(
            TISCreateInputSourceList(filter as CFDictionary, true)?.takeRetainedValue() as? [TISInputSource],
            "TIS could not enumerate all installed keyboard layouts."
        )
        let sources = rawSources.compactMap(SystemSource.init).sorted {
            ($0.id, $0.name) < ($1.id, $1.name)
        }

        // These are physical positions, not a map reconstructed from Langy's output.
        // Do not scan 0..<128: keypad/control keys can alias printable ANSI positions.
        let keys: [(code: Int, us: String)] = [
            (kVK_ANSI_Grave, "`"),
            (kVK_ANSI_1, "1"), (kVK_ANSI_2, "2"), (kVK_ANSI_3, "3"),
            (kVK_ANSI_4, "4"), (kVK_ANSI_5, "5"), (kVK_ANSI_6, "6"),
            (kVK_ANSI_7, "7"), (kVK_ANSI_8, "8"), (kVK_ANSI_9, "9"),
            (kVK_ANSI_0, "0"), (kVK_ANSI_Minus, "-"), (kVK_ANSI_Equal, "="),
            (kVK_ANSI_Q, "q"), (kVK_ANSI_W, "w"), (kVK_ANSI_E, "e"),
            (kVK_ANSI_R, "r"), (kVK_ANSI_T, "t"), (kVK_ANSI_Y, "y"),
            (kVK_ANSI_U, "u"), (kVK_ANSI_I, "i"), (kVK_ANSI_O, "o"),
            (kVK_ANSI_P, "p"), (kVK_ANSI_LeftBracket, "["),
            (kVK_ANSI_RightBracket, "]"), (kVK_ANSI_Backslash, "\\"),
            (kVK_ANSI_A, "a"), (kVK_ANSI_S, "s"), (kVK_ANSI_D, "d"),
            (kVK_ANSI_F, "f"), (kVK_ANSI_G, "g"), (kVK_ANSI_H, "h"),
            (kVK_ANSI_J, "j"), (kVK_ANSI_K, "k"), (kVK_ANSI_L, "l"),
            (kVK_ANSI_Semicolon, ";"), (kVK_ANSI_Quote, "'"),
            (kVK_ANSI_Z, "z"), (kVK_ANSI_X, "x"), (kVK_ANSI_C, "c"),
            (kVK_ANSI_V, "v"), (kVK_ANSI_B, "b"), (kVK_ANSI_N, "n"),
            (kVK_ANSI_M, "m"), (kVK_ANSI_Comma, ","),
            (kVK_ANSI_Period, "."), (kVK_ANSI_Slash, "/"), (kVK_Space, " ")
        ]
        let reference = ["com.apple.keylayout.ABC", "com.apple.keylayout.US"].compactMap { id in
            let matches = sources.filter { $0.id == id && $0.data != nil }
            return matches.count == 1 ? matches.first : nil
        }.first
        var referenceIssues: [String] = []
        let referenceKeys = keys.filter { key in
            guard let data = reference?.data else {
                referenceIssues.append("Key \(key.code): no unique ABC/U.S. reference with Unicode layout data.")
                return false
            }
            let result = translate(data, key: key.code, keyboardType: keyboardType)
            guard result.text == key.us else {
                referenceIssues.append("Key \(key.code): expected US \(key.us.debugDescription); reference returned \(result.text?.debugDescription ?? result.issue).")
                return false
            }
            return true
        }

        // Exact, predeclared comparison variants; never pick the best-scoring layout
        // or fuzzy-match a localized language name. A divergence is not proof that
        // a PC/legacy/regional variant is incorrect.
        let variants = [
            "builtin.en": "US", "builtin.de": "German-DIN-2137",
            "builtin.fr": "French-PC", "builtin.es": "Spanish-ISO",
            "builtin.it": "Italian-Pro", "builtin.pt": "Portuguese",
            "builtin.nl": "Dutch", "builtin.sv": "Swedish-Pro",
            "builtin.no": "Norwegian", "builtin.da": "Danish",
            "builtin.fi": "Finnish", "builtin.is": "Icelandic",
            "builtin.cs": "Czech", "builtin.sk": "Slovak",
            "builtin.hu": "Hungarian", "builtin.pl": "PolishPro",
            "builtin.ro": "Romanian-Standard", "builtin.bg": "Bulgarian-Phonetic",
            "builtin.el": "Greek", "builtin.tr": "Turkish-QWERTY-PC",
            "builtin.sr-cyrl": "Serbian", "builtin.sr-latn": "Serbian-Latin",
            "builtin.hr": "Croatian-PC", "builtin.sl": "Slovenian",
            "builtin.sq": "Albanian", "builtin.lt": "Lithuanian",
            "builtin.lv": "Latvian", "builtin.et": "Estonian",
            "builtin.mt": "Maltese", "builtin.ga": "Irish", "builtin.cy": "Welsh",
            "builtin.be": "Byelorussian", "builtin.ar": "ArabicPC",
            "builtin.he": "Hebrew-PC", "builtin.ka": "Georgian-QWERTY"
        ]
        // BuiltinLayouts explicitly reuses these bases. Audit that base only;
        // e.g. Danish is not evidence of native Faroese keyboard correctness.
        let proxies = [
            "builtin.bs": "builtin.sr-latn", "builtin.eu": "builtin.es",
            "builtin.ca": "builtin.es", "builtin.gl": "builtin.es",
            "builtin.lb": "builtin.de", "builtin.rm": "builtin.de",
            "builtin.fy": "builtin.nl", "builtin.fo": "builtin.da",
            "builtin.br": "builtin.fr", "builtin.co": "builtin.fr",
            "builtin.sc": "builtin.it", "builtin.oc": "builtin.fr",
            "builtin.az": "builtin.tr", "builtin.me": "builtin.sr-latn"
        ]

        let engine = Transliterator()
        var details: [String] = []
        var unmatched: [String] = []
        var matchedIDs = Set<String>()
        var matched = 0
        var proxyMatches = 0
        var agreements = 0
        var compared = 0
        var mismatchCount = 0
        var layoutsWithDifferences = 0
        var skippedCount = 0
        for builtin in BuiltinLayouts.all.sorted(by: { $0.id < $1.id }) {
            let baseID = proxies[builtin.id] ?? builtin.id
            guard let suffix = variants[baseID] else {
                unmatched.append("| \(cell(builtin.id)) | \(cell(builtin.name)) | No explicit variant identified; no language-name or identity-map inference. |")
                continue
            }
            let systemID = "com.apple.keylayout.\(suffix)"
            let candidates = sources.filter { $0.id == systemID }
            guard candidates.count == 1, let source = candidates.first, let data = source.data else {
                let reason = candidates.isEmpty ? "Not installed" :
                    (candidates.count > 1 ? "Ambiguous duplicate system ID" : "No Unicode key-layout data")
                unmatched.append("| \(cell(builtin.id)) | \(cell(builtin.name)) | \(reason): \(cell(systemID)). |")
                continue
            }
            let isProxy = baseID != builtin.id
            guard !isProxy || BuiltinLayouts.all.first(where: { $0.id == baseID })?.map == builtin.map else {
                unmatched.append("| \(cell(builtin.id)) | \(cell(builtin.name)) | Declared proxy no longer equals \(cell(baseID)); review the audit's variant assignment. |")
                continue
            }
            let basis = isProxy ? "Proxy: inherited \(baseID) map; NOT native-language validation" :
                "Named macOS comparison variant; builtin does not declare an exact OS standard"
            var differences: [String] = []
            var skipped = referenceIssues
            var count = 0
            for key in referenceKeys {
                let expected = translate(data, key: key.code, keyboardType: keyboardType)
                guard let text = expected.text else {
                    skipped.append("Key \(key.code) (\(key.us.debugDescription)): \(expected.issue)")
                    continue
                }
                // Exercise the real engine, including its identity fallback and
                // multi-character output, rather than comparing map dictionaries.
                let actual = engine.apply(map: builtin.map, to: key.us)
                count += 1
                if actual != text {
                    differences.append("| \(key.code) | \(shown(key.us)) | \(shown(text)) | \(shown(actual)) |")
                }
            }
            matched += 1
            if isProxy { proxyMatches += 1 }
            matchedIDs.insert(source.id)
            compared += count
            agreements += count - differences.count
            mismatchCount += differences.count
            if !differences.isEmpty { layoutsWithDifferences += 1 }
            skippedCount += skipped.count
            details += [
                "### \(cell(builtin.id)): \(cell(builtin.name))", "", basis, "",
                "| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / \(keys.count) |",
                "| --- | --- | --- | ---: | ---: | ---: |",
                "| \(cell(source.id)) | \(cell(source.name)) | \(source.enabled.map(String.init) ?? "unknown") | \(count - differences.count) / \(count) | \(differences.count) | \(skipped.count) / \(keys.count) |", ""
            ]
            if differences.isEmpty {
                details.append(count == 0 ? "NOT AUDITED: no comparable keys." :
                    "No differences in the compared sample. This is not a full-layout correctness claim.")
            } else {
                details += [
                    "All mismatch examples (Unicode scalar values included):", "",
                    "| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |",
                    "| ---: | --- | --- | --- |"
                ] + differences
            }
            if !skipped.isEmpty {
                details += ["", "Excluded from agreement totals:"] + skipped.map { "- \(cell($0))" }
            }
            details.append("")
        }

        // No setters, registrations, persistent-domain writes, or .shared/.standard.
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "Langy.SystemLayoutAudit.\(UUID().uuidString)"))
        guard ["langy.useSystemLayouts", "langy.customLayouts", "langy.disabledLayoutIDs"].allSatisfy({
            defaults.object(forKey: $0) == nil
        }) else {
            XCTFail("The isolated defaults suite inherited Langy settings; cannot inspect pristine defaults. No values logged.")
            return
        }
        let store = LayoutStore(defaults: defaults)
        let referenceBeforeDiscovery = TISCopyCurrentASCIICapableKeyboardLayoutInputSource().flatMap {
            SystemSource($0.takeRetainedValue())
        }
        let discovered = store.systemLayouts()
        let effective = store.effectiveLayouts()
        let discoveredIDs = Set(discovered.map(\.id))
        let effectiveIDs = Set(effective.map(\.id))
        let enabledSources = sources.filter { $0.enabled == true }
        let omitted = enabledSources.filter { !discoveredIDs.contains($0.id) }
        let storeReference = TISCopyCurrentASCIICapableKeyboardLayoutInputSource().flatMap {
            SystemSource($0.takeRetainedValue())
        }

        var conversionDetails = [
            "## Production Conversion Audit", "",
            "Golden text is independently translated from physical Carbon key codes for the actual production reference and each discovered layout. No US-character assumption is made for a non-ABC/U.S. reference. The corpus has 48 sampled positions with 47 physical space-key separators; fixtures have no separators. Translation failure excludes a whole golden, never silently shortens it.", "",
            "Forward apply uses production maps. Fresh forward and reverse next calls each get a NEW engine with [reference, target]; reverse input is OS text, not prior engine output. The reference itself is checked by apply, not a duplicate [reference, reference] pair. Identical OS renderings expect nil from a fresh pair because next promises a visible first change.", "",
            "Full-list cycling preserves discovery order, starts fresh from EVERY discovered source's OS text, and feeds actual results into two complete rounds. Expected order starts at the first OS rendering different from the known source, then includes every layout, even identical renderings. A nil result retains the last input for subsequent probes. Shared renderings and source-detection ties can make known-source recovery ambiguous; these are reported discrepancies, not evidence that the heuristic could infer unavailable source metadata.", "",
            "Map-derived cycle baselines use the same expected order but apply production maps to the original reference golden. They test consistency with forward maps, NOT independent OS correctness. OS-only failures suggest map divergence; failures against both baselines can also involve decoding, source choice, or cycle state.", ""
        ]
        var conversionChecks = 0
        var conversionFailures = 0
        var consistencyChecks = 0
        var consistencyFailures = 0
        var fixtureChecks = 0
        var fixtureFailures = 0
        var conversionSkipped = 0
        if let storeReference, let referenceLayout = discovered.first(where: { $0.id == storeReference.id }),
           storeReference.data != nil, referenceBeforeDiscovery?.id == storeReference.id,
           referenceBeforeDiscovery?.data == storeReference.data {
            let corpusCodes = keys.enumerated().flatMap { index, key in
                index == 0 ? [key.code] : [kVK_Space, key.code]
            }
            let cases: [(name: String, codes: [Int], target: String?, claimed: String?)] = [
                ("Full corpus", corpusCodes, nil, nil),
                ("Russian-PC ghbdtn", [kVK_ANSI_G, kVK_ANSI_H, kVK_ANSI_B, kVK_ANSI_D, kVK_ANSI_T, kVK_ANSI_N],
                 "com.apple.keylayout.RussianWin", "\u{43F}\u{440}\u{438}\u{432}\u{435}\u{442}"),
                ("Ukrainian-PC s]'\\", [kVK_ANSI_S, kVK_ANSI_RightBracket, kVK_ANSI_Quote, kVK_ANSI_Backslash],
                  "com.apple.keylayout.Ukrainian-PC", "\u{456}\u{457}\u{454}\u{2BC}")
            ]
            for sample in cases {
                conversionDetails += [
                    "### \(cell(sample.name))", "", "Physical key codes: \(sample.codes.map(String.init).joined(separator: ", ")).", "",
                    "| Discovered system ID | Independent Carbon golden |", "| --- | --- |"
                ]
                var goldens: [String: String] = [:]
                for layout in discovered {
                    let candidates = sources.filter { $0.id == layout.id }
                    let data = layout.id == storeReference.id ? storeReference.data :
                        (candidates.count == 1 ? candidates.first?.data : nil)
                    guard let data else {
                        conversionSkipped += 1
                        conversionDetails.append("| \(cell(layout.id)) | NOT AUDITED: no unique Unicode layout data. |")
                        continue
                    }
                    let outputs = sample.codes.map { translate(data, key: $0, keyboardType: keyboardType) }
                    let issues = zip(sample.codes, outputs).compactMap { code, result in
                        result.text == nil ? "key \(code): \(result.issue)" : nil
                    }
                    guard issues.isEmpty else {
                        conversionSkipped += 1
                        conversionDetails.append("| \(cell(layout.id)) | NOT AUDITED: \(cell(issues.joined(separator: "; "))). |")
                        continue
                    }
                    let text = outputs.compactMap(\.text).joined()
                    goldens[layout.id] = text
                    conversionDetails.append("| \(cell(layout.id)) | \(shown(text)) |")
                }
                if let target = sample.target, let claimed = sample.claimed {
                    if let observed = goldens[target] {
                        fixtureChecks += 1
                        if observed != claimed { fixtureFailures += 1 }
                        conversionDetails += [
                            "", "Fixture declaration checked against this exact OS variant: requested \(shown(claimed)); Carbon returned \(shown(observed)); \(observed == claimed ? "AGREE" : "DIFFERENT"). Engine expectations below use Carbon, not the declaration."
                        ]
                    } else {
                        conversionSkipped += 1
                        conversionDetails += ["", "Fixture NOT AUDITED: exact target \(cell(target)) was not discovered with a usable golden; no variant substituted."]
                    }
                }
                guard let referenceText = goldens[referenceLayout.id] else {
                    conversionSkipped += 1
                    conversionDetails += ["", "Conversion checks NOT AUDITED: reference golden unavailable.", ""]
                    continue
                }
                var osRows: [String] = []
                var mapRows: [String] = []
                func record(_ label: String, input: String, expectedText: String?, expectedID: String?,
                            actualText: String?, actualID: String?, mapOnly: Bool = false) {
                    let agrees = expectedText == actualText && expectedID == actualID
                    let row = "| \(cell(label)) | \(cell(input.debugDescription)) | \(cell(expectedID ?? "nil")) | \(cell(expectedText?.debugDescription ?? "nil")) | \(cell(actualID ?? "nil")) | \(cell(actualText?.debugDescription ?? "nil")) | \(agrees ? "AGREE" : "DIFFERENT") |"
                    if mapOnly {
                        consistencyChecks += 1
                        if !agrees { consistencyFailures += 1 }
                        mapRows.append(row)
                    } else {
                        conversionChecks += 1
                        if !agrees { conversionFailures += 1 }
                        osRows.append(row)
                    }
                }
                for target in discovered where sample.target == nil || target.id == sample.target {
                    guard let targetText = goldens[target.id] else { continue }
                    record("Forward apply", input: referenceText, expectedText: targetText, expectedID: target.id,
                           actualText: engine.apply(map: target.map, to: referenceText), actualID: target.id)
                    guard target.id != referenceLayout.id else { continue }
                    for reverse in [false, true] {
                        let pair = Transliterator()
                        pair.updateLayouts([referenceLayout, target], revision: 1)
                        let input = reverse ? targetText : referenceText
                        let result = pair.next(for: input)
                        let changes = targetText != referenceText
                        record(reverse ? "Fresh reverse next [reference, target]" : "Fresh forward next [reference, target]",
                               input: input, expectedText: changes ? (reverse ? referenceText : targetText) : nil,
                               expectedID: changes ? (reverse ? referenceLayout.id : target.id) : nil,
                               actualText: result?.text, actualID: result?.layout?.id)
                    }
                }
                if goldens.count == discovered.count {
                    for (sourceIndex, source) in discovered.enumerated() {
                        let startText = goldens[source.id]!
                        let cycle = Transliterator()
                        cycle.updateLayouts(discovered, revision: 1)
                        let first = (1...discovered.count).map { (sourceIndex + $0) % discovered.count }
                            .first { goldens[discovered[$0].id] != startText }
                        guard let first else {
                            let result = cycle.next(for: startText)
                            record("Cycle from \(source.id): all OS renderings identical", input: startText,
                                   expectedText: nil, expectedID: nil, actualText: result?.text, actualID: result?.layout?.id)
                            continue
                        }
                        var input = startText
                        for step in 0..<(discovered.count * 2) {
                            let target = discovered[(first + step) % discovered.count]
                            let result = cycle.next(for: input)
                            let label = "Cycle from \(source.id), step \(step + 1)"
                            record(label, input: input, expectedText: goldens[target.id], expectedID: target.id,
                                   actualText: result?.text, actualID: result?.layout?.id)
                            record(label, input: input, expectedText: engine.apply(map: target.map, to: referenceText),
                                   expectedID: target.id, actualText: result?.text, actualID: result?.layout?.id, mapOnly: true)
                            input = result?.text ?? input
                        }
                    }
                } else {
                    conversionSkipped += 1
                    conversionDetails += ["", "Full-list cycling NOT AUDITED: at least one discovered layout lacks a complete OS golden."]
                }
                for (basis, rows) in [("Independent OS conversion results", osRows), ("Map-derived cycle consistency ONLY", mapRows)] {
                    conversionDetails += [
                        "", basis, "",
                        "| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |",
                        "| --- | --- | --- | --- | --- | --- | --- |"
                    ] + rows
                }
                conversionDetails.append("")
            }
        } else {
            conversionSkipped += 1
            conversionDetails += ["NOT AUDITED: production reference unavailable, absent from discovery, or changed ID/data across discovery. No ABC/U.S. substitute is assumed.", ""]
        }

        let incomplete = !unmatched.isEmpty || skippedCount > 0 || referenceKeys.count != keys.count || conversionSkipped > 0
        let hasDiscrepancies = mismatchCount > 0 || !omitted.isEmpty || conversionFailures > 0 || consistencyFailures > 0 || fixtureFailures > 0
        let status = hasDiscrepancies ? "DISCREPANCIES OBSERVED" :
            (incomplete ? "INCOMPLETE COVERAGE" : "NO DISCREPANCIES IN THIS LIMITED SAMPLE")
        var report = [
            "# Langy Live macOS Keyboard Audit", "",
            "**Result: \(status). Report generation is not a correctness pass.**", "",
            "- Generated: \(ISO8601DateFormatter().string(from: Date()))",
            "- OS: \(cell(ProcessInfo.processInfo.operatingSystemVersionString))",
            "- Keyboard type: \(keyboardType), \(hardwareName) (LMGetKbdType / KBGetLayoutType; this host only)",
            "- Inventory: TISCreateInputSourceList, keyboard-layout type, includeAllInstalled=true; \(sources.count) identified entries, \(rawSources.count - sources.count) without IDs.",
            "- Independent reference: \(cell(reference?.id ?? "UNAVAILABLE")) / \(cell(reference?.name ?? "UNAVAILABLE")); \(referenceKeys.count)/\(keys.count) physical positions verified against known US characters.",
            "- Builtins: \(BuiltinLayouts.all.count) catalog entries; \(matched) matched (\(matched - proxyMatches) named variants, \(proxyMatches) explicitly inherited-base proxies), \(unmatched.count) unmatched; \(matchedIDs.count) distinct system IDs compared.",
            "- Key agreement: \(agreements)/\(compared); \(mismatchCount) mismatches across \(layoutsWithDifferences) builtin comparisons; \(skippedCount) excluded samples. Proxy samples repeat base variants and are not independent language coverage.",
            "- Default discovery: \(discovered.count) discovered, \(effective.count) effective; \(omitted.count) enabled keyboard-layout entries omitted.",
            "- Production conversions against independent OS goldens: \(conversionChecks - conversionFailures)/\(conversionChecks) agreements; \(conversionFailures) discrepancies (whole-text plus layout-ID checks, not key counts).",
            "- Natural fixture declarations against Carbon: \(fixtureChecks - fixtureFailures)/\(fixtureChecks) agreements; \(fixtureFailures) discrepancies. Engine checks use observed OS output regardless.",
            "- Map-derived cycle consistency ONLY: \(consistencyChecks - consistencyFailures)/\(consistencyChecks) agreements; \(consistencyFailures) discrepancies. These are NOT extra independent OS checks.",
            "- Production conversion coverage exclusions: \(conversionSkipped) unavailable goldens/check groups.",
            "- Strict mode: \(strict). Strict fails on observed builtin, discovery, production conversion, map-consistency, or fixture-declaration discrepancies, and on incomplete coverage.", "",
            "## Method and Limits", "",
            "The catalog is audited as shipped, not assumed to be 50 distinct European languages or keyboard standards. Exact system IDs listed below are predeclared comparison targets, not inferred builtin specifications. A difference means divergence from that named macOS variant, not proof that a different PC, legacy, regional, or national variant is wrong. Proxies validate only the explicitly reused base, never the named regional language's own keyboard.", "",
            "UCKeyTranslate uses kUCKeyActionDisplay, modifiers=0, kUCKeyTranslateNoDeadKeysMask, fresh dead-key state for each key, and the recorded hardware type. Dead keys are compared as standalone display characters, not composed keystrokes. All printable UTF-16 output is retained, including multiple characters; equality uses Swift String canonical equivalence, with no lowercasing or compatibility folding. Failed, empty, control, and default-ignorable outputs are excluded and listed, never counted as agreements.", "",
            "The sample is 47 explicitly named kVK_ANSI positions plus space. Production-discovered layouts additionally receive corpus/fixture forward, fresh reverse, and full-list cycling checks below; this is not comprehensive language-detection testing. Shift, Option/AltGr, Caps Lock, ISO/JIS-only positions, keypad, IMEs, composed dead-key sequences, hotkeys, and text insertion are not tested. No keyboards are enabled, selected, or disabled. No user configuration is changed or dumped; only TIS keyboard metadata and a fresh isolated defaults suite are inspected. The only requested persistent write is this report.", "",
            "## Matched Builtins", ""
        ] + details + [
            "## Unmatched Builtins", "",
            "Unmatched means unaudited, not passing. No substitute variant is silently selected.", "",
            "| Builtin ID | Name | Reason / requested system ID |", "| --- | --- | --- |"
        ] + (unmatched.isEmpty ? ["| None | | |"] : unmatched) + [
            "", "## Default LayoutStore Discovery", "",
            "Read-only LayoutStore(defaults:) with an empty UUID-named suite; default useSystemLayouts=\(store.useSystemLayouts). This exercises production discovery rather than reconstructing its result from this audit's all-installed inventory.", "",
            "Current ASCII-capable reference used by production discovery: \(cell(storeReference?.id ?? "UNAVAILABLE")) / \(cell(storeReference?.name ?? "UNAVAILABLE")). This can differ from the audit's fixed ABC/U.S. reference. System state can change between these read-only snapshots.", "",
            "| Discovered ID | Discovered name | Map entries | In default effective list |",
            "| --- | --- | ---: | --- |"
        ]
        report += discovered.sorted(by: { $0.id < $1.id }).map {
            "| \(cell($0.id)) | \(cell($0.name)) | \($0.map.count) | \(effectiveIDs.contains($0.id)) |"
        }
        if discovered.isEmpty { report.append("| None | | | |") }
        report += [
            "", "### Enabled Layouts Omitted", "",
            "Enabled flags come independently from the all-installed TIS inventory. Unknown flags are not assumed enabled (\(sources.filter { $0.enabled == nil }.count) entries). IME/input-mode types are outside this keyboard-layout inventory.", "",
            "| Enabled system ID | Name | Diagnostic |", "| --- | --- | --- |"
        ]
        for source in omitted {
            let reason = source.data == nil ? "No Unicode key-layout data; cannot translate this source." :
                "Unicode data present. Production uses the current ASCII reference and rejects non-reference maps with fewer than 5 entries; omission is observed, not presumed intentional."
            report.append("| \(cell(source.id)) | \(cell(source.name)) | \(reason) |")
        }
        if omitted.isEmpty { report.append("| None observed | | |") }
        report += [""] + conversionDetails
        report += [
            "", "## Repeat", "", "```sh",
            "LANGY_SYSTEM_AUDIT_REPORT=/absolute/path/langy-system-audit.md swift test --filter SystemLayoutAuditTests",
            "```", "",
            "Use an existing writable parent directory. XCTest requires Xcode: if Command Line Tools are selected, prefix the command with DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer and invoke xcrun swift instead of swift; this does not change xcode-select. Use a separate --scratch-path when another agent is building. Add LANGY_AUDIT_STRICT=1 to fail after writing the report when discrepancies are observed. Without LANGY_SYSTEM_AUDIT_REPORT this XCTest skips before touching TIS or defaults. A zero exit status in reporting mode means only that collection and writing completed.", ""
        ]
        try report.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
        print("Langy system audit: \(status); \(mismatchCount) builtin key mismatches, \(omitted.count) enabled layouts omitted, \(unmatched.count) unmatched builtins; production OS discrepancies \(conversionFailures)/\(conversionChecks), map-only discrepancies \(consistencyFailures)/\(consistencyChecks), fixture declaration discrepancies \(fixtureFailures)/\(fixtureChecks), \(conversionSkipped) conversion exclusions. Report: \(path). Collection completion is NOT a correctness pass.")
        if strict && (hasDiscrepancies || incomplete) {
            XCTFail("Live audit observed \(mismatchCount) builtin key mismatches, \(omitted.count) enabled-layout omissions, \(conversionFailures) production OS discrepancies, \(consistencyFailures) map-only discrepancies, and \(fixtureFailures) fixture-declaration discrepancies; incomplete coverage: \(incomplete). See the written report; builtin differences are variant-specific.")
        }
    }

    private struct SystemSource {
        let id: String
        let name: String
        let enabled: Bool?
        let data: Data?

        init?(_ source: TISInputSource) {
            guard let idPointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
            id = Unmanaged<CFString>.fromOpaque(idPointer).takeUnretainedValue() as String
            if let pointer = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) {
                name = Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
            } else {
                name = id
            }
            if let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsEnabled) {
                enabled = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(pointer).takeUnretainedValue())
            } else {
                enabled = nil
            }
            if let pointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) {
                data = Unmanaged<CFData>.fromOpaque(pointer).takeUnretainedValue() as Data
            } else {
                data = nil
            }
        }
    }

    private func translate(_ data: Data, key: Int, keyboardType: UInt32) -> (text: String?, issue: String) {
        guard data.count >= MemoryLayout<UCKeyboardLayout>.size else { return (nil, "Layout data too short") }
        return data.withUnsafeBytes { raw in
            guard let layout = raw.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else {
                return (nil, "No layout data pointer")
            }
            var state: UInt32 = 0
            var length = 0
            var output = [UniChar](repeating: 0, count: 255)
            let status = output.withUnsafeMutableBufferPointer { buffer in
                UCKeyTranslate(layout, UInt16(key), UInt16(kUCKeyActionDisplay), 0, keyboardType,
                               OptionBits(kUCKeyTranslateNoDeadKeysMask), &state,
                               buffer.count, &length, buffer.baseAddress!)
            }
            guard status == noErr else { return (nil, "UCKeyTranslate OSStatus=\(status)") }
            guard length > 0, length <= output.count else { return (nil, "Empty or oversized output (\(length))") }
            let text = String(utf16CodeUnits: output, count: length)
            guard text.unicodeScalars.allSatisfy({
                !CharacterSet.controlCharacters.contains($0) && !$0.properties.isDefaultIgnorableCodePoint
            }) else { return (nil, "Nonprintable output: \(text.debugDescription)") }
            return (text, "")
        }
    }

    private func cell(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "|", with: "&#124;")
            .replacingOccurrences(of: "`", with: "&#96;")
            .replacingOccurrences(of: "\\", with: "&#92;")
            .replacingOccurrences(of: "\r", with: "&#13;")
            .replacingOccurrences(of: "\n", with: "<br>")
    }

    private func shown(_ text: String) -> String {
        let scalars = text.unicodeScalars.map { String(format: "U+%04X", $0.value) }.joined(separator: " ")
        return "<code>\(cell(text.debugDescription))</code> (\(scalars))"
    }
}
