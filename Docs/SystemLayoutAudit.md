# Langy Live macOS Keyboard Audit

**Result: DISCREPANCIES OBSERVED. Report generation is not a correctness pass.**

- Generated: 2026-09-05T08:49:54Z
- OS: Version 26.6.2 (Build 25G83)
- Keyboard type: 43, ANSI (LMGetKbdType / KBGetLayoutType; this host only)
- Inventory: TISCreateInputSourceList, keyboard-layout type, includeAllInstalled=true; 251 identified entries, 0 without IDs.
- Independent reference: com.apple.keylayout.ABC / ABC; 48/48 physical positions verified against known US characters.
- Builtins: 50 catalog entries; 49 matched (35 named variants, 14 explicitly inherited-base proxies), 1 unmatched; 35 distinct system IDs compared.
- Key agreement: 2209/2352; 143 mismatches across 45 builtin comparisons; 0 excluded samples. Proxy samples repeat base variants and are not independent language coverage.
- Default discovery: 3 discovered, 3 effective; 0 enabled keyboard-layout entries omitted.
- Production conversions against independent OS goldens: 53/67 agreements; 14 discrepancies (whole-text plus layout-ID checks, not key counts).
- Natural fixture declarations against Carbon: 2/2 agreements; 0 discrepancies. Engine checks use observed OS output regardless.
- Map-derived cycle consistency ONLY: 42/54 agreements; 12 discrepancies. These are NOT extra independent OS checks.
- Production conversion coverage exclusions: 0 unavailable goldens/check groups.
- Strict mode: true. Strict fails on observed builtin, discovery, production conversion, map-consistency, or fixture-declaration discrepancies, and on incomplete coverage.

## Method and Limits

The catalog is audited as shipped, not assumed to be 50 distinct European languages or keyboard standards. Exact system IDs listed below are predeclared comparison targets, not inferred builtin specifications. A difference means divergence from that named macOS variant, not proof that a different PC, legacy, regional, or national variant is wrong. Proxies validate only the explicitly reused base, never the named regional language's own keyboard.

UCKeyTranslate uses kUCKeyActionDisplay, modifiers=0, kUCKeyTranslateNoDeadKeysMask, fresh dead-key state for each key, and the recorded hardware type. Dead keys are compared as standalone display characters, not composed keystrokes. All printable UTF-16 output is retained, including multiple characters; equality uses Swift String canonical equivalence, with no lowercasing or compatibility folding. Failed, empty, control, and default-ignorable outputs are excluded and listed, never counted as agreements.

The sample is 47 explicitly named kVK_ANSI positions plus space. Production-discovered layouts additionally receive corpus/fixture forward, fresh reverse, and full-list cycling checks below; this is not comprehensive language-detection testing. Shift, Option/AltGr, Caps Lock, ISO/JIS-only positions, keypad, IMEs, composed dead-key sequences, hotkeys, and text insertion are not tested. No keyboards are enabled, selected, or disabled. No user configuration is changed or dumped; only TIS keyboard metadata and a fresh isolated defaults suite are inspected. The only requested persistent write is this report.

## Matched Builtins

### builtin.ar: Arabic

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.ArabicPC | Arabic – PC | false | 37 / 48 | 11 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"ذ"</code> (U+0630) | <code>"&#96;"</code> (U+0060) |
| 18 | <code>"1"</code> (U+0031) | <code>"١"</code> (U+0661) | <code>"1"</code> (U+0031) |
| 19 | <code>"2"</code> (U+0032) | <code>"٢"</code> (U+0662) | <code>"2"</code> (U+0032) |
| 20 | <code>"3"</code> (U+0033) | <code>"٣"</code> (U+0663) | <code>"3"</code> (U+0033) |
| 21 | <code>"4"</code> (U+0034) | <code>"٤"</code> (U+0664) | <code>"4"</code> (U+0034) |
| 23 | <code>"5"</code> (U+0035) | <code>"٥"</code> (U+0665) | <code>"5"</code> (U+0035) |
| 22 | <code>"6"</code> (U+0036) | <code>"٦"</code> (U+0666) | <code>"6"</code> (U+0036) |
| 26 | <code>"7"</code> (U+0037) | <code>"٧"</code> (U+0667) | <code>"7"</code> (U+0037) |
| 28 | <code>"8"</code> (U+0038) | <code>"٨"</code> (U+0668) | <code>"8"</code> (U+0038) |
| 25 | <code>"9"</code> (U+0039) | <code>"٩"</code> (U+0669) | <code>"9"</code> (U+0039) |
| 29 | <code>"0"</code> (U+0030) | <code>"٠"</code> (U+0660) | <code>"0"</code> (U+0030) |

### builtin.az: Azerbaijani

Proxy: inherited builtin.tr map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Turkish-QWERTY-PC | Turkish Q | false | 46 / 48 | 2 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>","</code> (U+002C) | <code>"&#92;&#92;"</code> (U+005C) |

### builtin.be: Belarusian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Byelorussian | Belarusian | false | 45 / 48 | 3 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"“"</code> (U+201C) | <code>"ё"</code> (U+0451) |
| 30 | <code>"]"</code> (U+005D) | <code>"&#92;'"</code> (U+0027) | <code>"ъ"</code> (U+044A) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ё"</code> (U+0451) | <code>"&#92;&#92;"</code> (U+005C) |

### builtin.bg: Bulgarian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Bulgarian-Phonetic | Bulgarian – QWERTY | false | 42 / 48 | 6 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"ч"</code> (U+0447) | <code>"&#96;"</code> (U+0060) |
| 33 | <code>"["</code> (U+005B) | <code>"ш"</code> (U+0448) | <code>"ч"</code> (U+0447) |
| 30 | <code>"]"</code> (U+005D) | <code>"щ"</code> (U+0449) | <code>"ш"</code> (U+0448) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ю"</code> (U+044E) | <code>"&#92;&#92;"</code> (U+005C) |
| 39 | <code>"&#92;'"</code> (U+0027) | <code>"&#92;'"</code> (U+0027) | <code>"щ"</code> (U+0449) |
| 7 | <code>"x"</code> (U+0078) | <code>"ь"</code> (U+044C) | <code>"x"</code> (U+0078) |

### builtin.br: Breton

Proxy: inherited builtin.fr map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.French-PC | French – PC | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"²"</code> (U+00B2) |

### builtin.bs: Bosnian

Proxy: inherited builtin.sr-latn map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Serbian-Latin | Serbian (Latin) | false | 42 / 48 | 6 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 27 | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) | <code>"&#92;'"</code> (U+0027) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"ž"</code> (U+017E) |
| 16 | <code>"y"</code> (U+0079) | <code>"y"</code> (U+0079) | <code>"z"</code> (U+007A) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ž"</code> (U+017E) | <code>"&#92;&#92;"</code> (U+005C) |
| 6 | <code>"z"</code> (U+007A) | <code>"z"</code> (U+007A) | <code>"y"</code> (U+0079) |

### builtin.ca: Catalan

Proxy: inherited builtin.es map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Spanish-ISO | Spanish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"º"</code> (U+00BA) |

### builtin.co: Corsican

Proxy: inherited builtin.fr map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.French-PC | French – PC | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"²"</code> (U+00B2) |

### builtin.cs: Czech

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Czech | Czech | false | 44 / 48 | 4 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#92;&#92;"</code> (U+005C) | <code>";"</code> (U+003B) |
| 24 | <code>"="</code> (U+003D) | <code>"&#92;'"</code> (U+0027) | <code>"´"</code> (U+00B4) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"¨"</code> (U+00A8) | <code>"&#92;&#92;"</code> (U+005C) |
| 44 | <code>"/"</code> (U+002F) | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) |

### builtin.cy: Welsh

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Welsh | Welsh | false | 48 / 48 | 0 | 0 / 48 |

No differences in the compared sample. This is not a full-layout correctness claim.

### builtin.da: Danish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Danish | Danish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"½"</code> (U+00BD) |

### builtin.de: German

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.German-DIN-2137 | German – Standard | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"^"</code> (U+005E) |

### builtin.el: Greek

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Greek | Greek | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 41 | <code>";"</code> (U+003B) | <code>"΄"</code> (U+0384) | <code>";"</code> (U+003B) |

### builtin.en: English (US)

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.US | U.S. | false | 48 / 48 | 0 | 0 / 48 |

No differences in the compared sample. This is not a full-layout correctness claim.

### builtin.es: Spanish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Spanish-ISO | Spanish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"º"</code> (U+00BA) |

### builtin.et: Estonian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Estonian | Estonian | false | 43 / 48 | 5 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 27 | <code>"-"</code> (U+002D) | <code>"+"</code> (U+002B) | <code>"-"</code> (U+002D) |
| 24 | <code>"="</code> (U+003D) | <code>"´"</code> (U+00B4) | <code>"="</code> (U+003D) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"&#92;'"</code> (U+0027) | <code>"&#92;&#92;"</code> (U+005C) |
| 44 | <code>"/"</code> (U+002F) | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) |

### builtin.eu: Basque

Proxy: inherited builtin.es map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Spanish-ISO | Spanish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"º"</code> (U+00BA) |

### builtin.fi: Finnish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Finnish | Finnish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"§"</code> (U+00A7) |

### builtin.fo: Faroese

Proxy: inherited builtin.da map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Danish | Danish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"½"</code> (U+00BD) |

### builtin.fr: French

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.French-PC | French – PC | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"²"</code> (U+00B2) |

### builtin.fy: Frisian

Proxy: inherited builtin.nl map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Dutch | Dutch | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#96;"</code> (U+0060) | <code>"@"</code> (U+0040) |

### builtin.ga: Irish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Irish | Irish | false | 48 / 48 | 0 | 0 / 48 |

No differences in the compared sample. This is not a full-layout correctness claim.

### builtin.gl: Galician

Proxy: inherited builtin.es map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Spanish-ISO | Spanish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"º"</code> (U+00BA) |

### builtin.he: Hebrew

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Hebrew-PC | Hebrew – PC | false | 45 / 48 | 3 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#92;&#92;"</code> (U+005C) | <code>"&#96;"</code> (U+0060) |
| 33 | <code>"["</code> (U+005B) | <code>"]"</code> (U+005D) | <code>"["</code> (U+005B) |
| 30 | <code>"]"</code> (U+005D) | <code>"["</code> (U+005B) | <code>"]"</code> (U+005D) |

### builtin.hr: Croatian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Croatian-PC | Croatian – QWERTZ | false | 45 / 48 | 3 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"ž"</code> (U+017E) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ž"</code> (U+017E) | <code>"&#92;&#92;"</code> (U+005C) |

### builtin.hu: Hungarian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Hungarian | Hungarian | false | 44 / 48 | 4 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"í"</code> (U+00ED) | <code>"&#96;"</code> (U+0060) |
| 43 | <code>","</code> (U+002C) | <code>","</code> (U+002C) | <code>"?"</code> (U+003F) |
| 47 | <code>"."</code> (U+002E) | <code>"."</code> (U+002E) | <code>":"</code> (U+003A) |
| 44 | <code>"/"</code> (U+002F) | <code>"-"</code> (U+002D) | <code>"_"</code> (U+005F) |

### builtin.is: Icelandic

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Icelandic | Icelandic | false | 40 / 48 | 8 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"°"</code> (U+00B0) |
| 27 | <code>"-"</code> (U+002D) | <code>"ö"</code> (U+00F6) | <code>"-"</code> (U+002D) |
| 24 | <code>"="</code> (U+003D) | <code>"-"</code> (U+002D) | <code>"="</code> (U+003D) |
| 30 | <code>"]"</code> (U+005D) | <code>"&#92;'"</code> (U+0027) | <code>"´"</code> (U+00B4) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"+"</code> (U+002B) | <code>"&#92;&#92;"</code> (U+005C) |
| 41 | <code>";"</code> (U+003B) | <code>"æ"</code> (U+00E6) | <code>"ö"</code> (U+00F6) |
| 39 | <code>"&#92;'"</code> (U+0027) | <code>"´"</code> (U+00B4) | <code>"æ"</code> (U+00E6) |
| 44 | <code>"/"</code> (U+002F) | <code>"þ"</code> (U+00FE) | <code>"/"</code> (U+002F) |

### builtin.it: Italian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Italian-Pro | Italian | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#92;&#92;"</code> (U+005C) |

### builtin.ka: Georgian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Georgian-QWERTY | Georgian – QWERTY | false | 46 / 48 | 2 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"„"</code> (U+201E) | <code>"&#96;"</code> (U+0060) |
| 7 | <code>"x"</code> (U+0078) | <code>"ხ"</code> (U+10EE) | <code>"ძ"</code> (U+10EB) |

### builtin.lb: Luxembourgish

Proxy: inherited builtin.de map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.German-DIN-2137 | German – Standard | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"^"</code> (U+005E) |

### builtin.lt: Lithuanian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Lithuanian | Lithuanian – QWERTY | false | 45 / 48 | 3 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 25 | <code>"9"</code> (U+0039) | <code>"„"</code> (U+201E) | <code>"9"</code> (U+0039) |
| 29 | <code>"0"</code> (U+0030) | <code>"“"</code> (U+201C) | <code>"0"</code> (U+0030) |
| 24 | <code>"="</code> (U+003D) | <code>"ž"</code> (U+017E) | <code>"="</code> (U+003D) |

### builtin.lv: Latvian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Latvian | Latvian | false | 40 / 48 | 8 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#92;'"</code> (U+0027) | <code>"&#96;"</code> (U+0060) |
| 18 | <code>"1"</code> (U+0031) | <code>"1"</code> (U+0031) | <code>"ā"</code> (U+0101) |
| 19 | <code>"2"</code> (U+0032) | <code>"2"</code> (U+0032) | <code>"č"</code> (U+010D) |
| 20 | <code>"3"</code> (U+0033) | <code>"3"</code> (U+0033) | <code>"ē"</code> (U+0113) |
| 21 | <code>"4"</code> (U+0034) | <code>"4"</code> (U+0034) | <code>"ģ"</code> (U+0123) |
| 23 | <code>"5"</code> (U+0035) | <code>"5"</code> (U+0035) | <code>"ī"</code> (U+012B) |
| 22 | <code>"6"</code> (U+0036) | <code>"6"</code> (U+0036) | <code>"ķ"</code> (U+0137) |
| 26 | <code>"7"</code> (U+0037) | <code>"7"</code> (U+0037) | <code>"ļ"</code> (U+013C) |

### builtin.me: Montenegrin

Proxy: inherited builtin.sr-latn map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Serbian-Latin | Serbian (Latin) | false | 42 / 48 | 6 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 27 | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) | <code>"&#92;'"</code> (U+0027) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"ž"</code> (U+017E) |
| 16 | <code>"y"</code> (U+0079) | <code>"y"</code> (U+0079) | <code>"z"</code> (U+007A) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ž"</code> (U+017E) | <code>"&#92;&#92;"</code> (U+005C) |
| 6 | <code>"z"</code> (U+007A) | <code>"z"</code> (U+007A) | <code>"y"</code> (U+0079) |

### builtin.mt: Maltese

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Maltese | Maltese | false | 45 / 48 | 3 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"ż"</code> (U+017C) | <code>"&#96;"</code> (U+0060) |
| 33 | <code>"["</code> (U+005B) | <code>"ġ"</code> (U+0121) | <code>"["</code> (U+005B) |
| 30 | <code>"]"</code> (U+005D) | <code>"ħ"</code> (U+0127) | <code>"]"</code> (U+005D) |

### builtin.nl: Dutch

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Dutch | Dutch | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#96;"</code> (U+0060) | <code>"@"</code> (U+0040) |

### builtin.no: Norwegian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Norwegian | Norwegian | false | 45 / 48 | 3 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 24 | <code>"="</code> (U+003D) | <code>"´"</code> (U+00B4) | <code>"&#92;&#92;"</code> (U+005C) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"@"</code> (U+0040) | <code>"&#92;'"</code> (U+0027) |

### builtin.oc: Occitan

Proxy: inherited builtin.fr map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.French-PC | French – PC | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"²"</code> (U+00B2) |

### builtin.pl: Polish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.PolishPro | Polish | false | 48 / 48 | 0 | 0 / 48 |

No differences in the compared sample. This is not a full-layout correctness claim.

### builtin.pt: Portuguese

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Portuguese | Portuguese | false | 43 / 48 | 5 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#92;&#92;"</code> (U+005C) |
| 27 | <code>"-"</code> (U+002D) | <code>"&#92;'"</code> (U+0027) | <code>"/"</code> (U+002F) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"="</code> (U+003D) |
| 33 | <code>"["</code> (U+005B) | <code>"º"</code> (U+00BA) | <code>"+"</code> (U+002B) |
| 39 | <code>"&#92;'"</code> (U+0027) | <code>"~"</code> (U+007E) | <code>"º"</code> (U+00BA) |

### builtin.rm: Romansh

Proxy: inherited builtin.de map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.German-DIN-2137 | German – Standard | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"^"</code> (U+005E) |

### builtin.ro: Romanian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Romanian-Standard | Romanian – Standard | false | 46 / 48 | 2 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#92;&#92;"</code> (U+005C) | <code>"&#96;"</code> (U+0060) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"â"</code> (U+00E2) | <code>"&#92;&#92;"</code> (U+005C) |

### builtin.sc: Sardinian

Proxy: inherited builtin.it map; NOT native-language validation

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Italian-Pro | Italian | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#92;&#92;"</code> (U+005C) |

### builtin.sk: Slovak

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Slovak | Slovak | false | 43 / 48 | 5 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&#92;&#92;"</code> (U+005C) | <code>";"</code> (U+003B) |
| 24 | <code>"="</code> (U+003D) | <code>"&#92;'"</code> (U+0027) | <code>"´"</code> (U+00B4) |
| 33 | <code>"["</code> (U+005B) | <code>"ú"</code> (U+00FA) | <code>"á"</code> (U+00E1) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ň"</code> (U+0148) | <code>"&#92;&#92;"</code> (U+005C) |
| 44 | <code>"/"</code> (U+002F) | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) |

### builtin.sl: Slovenian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Slovenian | Slovenian | false | 40 / 48 | 8 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 27 | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) | <code>"&#92;'"</code> (U+0027) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"ž"</code> (U+017E) |
| 16 | <code>"y"</code> (U+0079) | <code>"y"</code> (U+0079) | <code>"z"</code> (U+007A) |
| 30 | <code>"]"</code> (U+005D) | <code>"đ"</code> (U+0111) | <code>"]"</code> (U+005D) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ž"</code> (U+017E) | <code>"&#92;&#92;"</code> (U+005C) |
| 39 | <code>"&#92;'"</code> (U+0027) | <code>"ć"</code> (U+0107) | <code>"&#92;'"</code> (U+0027) |
| 6 | <code>"z"</code> (U+007A) | <code>"z"</code> (U+007A) | <code>"y"</code> (U+0079) |

### builtin.sq: Albanian

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Albanian | Albanian | false | 40 / 48 | 8 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 16 | <code>"y"</code> (U+0079) | <code>"z"</code> (U+007A) | <code>"y"</code> (U+0079) |
| 33 | <code>"["</code> (U+005B) | <code>"ç"</code> (U+00E7) | <code>"ë"</code> (U+00EB) |
| 30 | <code>"]"</code> (U+005D) | <code>"@"</code> (U+0040) | <code>"]"</code> (U+005D) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"]"</code> (U+005D) | <code>"&#92;&#92;"</code> (U+005C) |
| 41 | <code>";"</code> (U+003B) | <code>"ë"</code> (U+00EB) | <code>";"</code> (U+003B) |
| 39 | <code>"&#92;'"</code> (U+0027) | <code>"["</code> (U+005B) | <code>"ç"</code> (U+00E7) |
| 6 | <code>"z"</code> (U+007A) | <code>"y"</code> (U+0079) | <code>"z"</code> (U+007A) |

### builtin.sr-cyrl: Serbian (Cyrillic)

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Serbian | Serbian | false | 41 / 48 | 7 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 27 | <code>"-"</code> (U+002D) | <code>"’"</code> (U+2019) | <code>"-"</code> (U+002D) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"="</code> (U+003D) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ж"</code> (U+0436) | <code>"&#92;&#92;"</code> (U+005C) |
| 6 | <code>"z"</code> (U+007A) | <code>"ѕ"</code> (U+0455) | <code>"џ"</code> (U+045F) |
| 7 | <code>"x"</code> (U+0078) | <code>"џ"</code> (U+045F) | <code>"x"</code> (U+0078) |
| 44 | <code>"/"</code> (U+002F) | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) |

### builtin.sr-latn: Serbian (Latin)

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Serbian-Latin | Serbian (Latin) | false | 42 / 48 | 6 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 27 | <code>"-"</code> (U+002D) | <code>"/"</code> (U+002F) | <code>"&#92;'"</code> (U+0027) |
| 24 | <code>"="</code> (U+003D) | <code>"+"</code> (U+002B) | <code>"ž"</code> (U+017E) |
| 16 | <code>"y"</code> (U+0079) | <code>"y"</code> (U+0079) | <code>"z"</code> (U+007A) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>"ž"</code> (U+017E) | <code>"&#92;&#92;"</code> (U+005C) |
| 6 | <code>"z"</code> (U+007A) | <code>"z"</code> (U+007A) | <code>"y"</code> (U+0079) |

### builtin.sv: Swedish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Swedish-Pro | Swedish | false | 47 / 48 | 1 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"§"</code> (U+00A7) |

### builtin.tr: Turkish

Named macOS comparison variant; builtin does not declare an exact OS standard

| System ID | System name | Enabled | Agree / compared | Mismatches | Skipped / 48 |
| --- | --- | --- | ---: | ---: | ---: |
| com.apple.keylayout.Turkish-QWERTY-PC | Turkish Q | false | 46 / 48 | 2 | 0 / 48 |

All mismatch examples (Unicode scalar values included):

| Physical ANSI key code | ABC/U.S. input | macOS expected | Actual apply(map:to:) |
| ---: | --- | --- | --- |
| 50 | <code>"&#96;"</code> (U+0060) | <code>"&lt;"</code> (U+003C) | <code>"&#96;"</code> (U+0060) |
| 42 | <code>"&#92;&#92;"</code> (U+005C) | <code>","</code> (U+002C) | <code>"&#92;&#92;"</code> (U+005C) |

## Unmatched Builtins

Unmatched means unaudited, not passing. No substitute variant is silently selected.

| Builtin ID | Name | Reason / requested system ID |
| --- | --- | --- |
| builtin.gd | Scottish Gaelic | No explicit variant identified; no language-name or identity-map inference. |

## Default LayoutStore Discovery

Read-only LayoutStore(defaults:) with an empty UUID-named suite; default useSystemLayouts=true. This exercises production discovery rather than reconstructing its result from this audit's all-installed inventory.

Current ASCII-capable reference used by production discovery: com.apple.keylayout.ABC / ABC. This can differ from the audit's fixed ABC/U.S. reference. System state can change between these read-only snapshots.

| Discovered ID | Discovered name | Map entries | In default effective list |
| --- | --- | ---: | --- |
| com.apple.keylayout.ABC | ABC | 0 | true |
| com.apple.keylayout.RussianWin | Russian – PC | 34 | true |
| com.apple.keylayout.Ukrainian-PC | Ukrainian | 35 | true |

### Enabled Layouts Omitted

Enabled flags come independently from the all-installed TIS inventory. Unknown flags are not assumed enabled (0 entries). IME/input-mode types are outside this keyboard-layout inventory.

| Enabled system ID | Name | Diagnostic |
| --- | --- | --- |
| None observed | | |

## Production Conversion Audit

Golden text is independently translated from physical Carbon key codes for the actual production reference and each discovered layout. No US-character assumption is made for a non-ABC/U.S. reference. The corpus has 48 sampled positions with 47 physical space-key separators; fixtures have no separators. Translation failure excludes a whole golden, never silently shortens it.

Forward apply uses production maps. Fresh forward and reverse next calls each get a NEW engine with [reference, target]; reverse input is OS text, not prior engine output. The reference itself is checked by apply, not a duplicate [reference, reference] pair. Identical OS renderings expect nil from a fresh pair because next promises a visible first change.

Full-list cycling preserves discovery order, starts fresh from EVERY discovered source's OS text, and feeds actual results into two complete rounds. Expected order starts at the first OS rendering different from the known source, then includes every layout, even identical renderings. A nil result retains the last input for subsequent probes. Shared renderings and source-detection ties can make known-source recovery ambiguous; these are reported discrepancies, not evidence that the heuristic could infer unavailable source metadata.

Map-derived cycle baselines use the same expected order but apply production maps to the original reference golden. They test consistency with forward maps, NOT independent OS correctness. OS-only failures suggest map divergence; failures against both baselines can also involve decoding, source choice, or cycle state.

### Full corpus

Physical key codes: 50, 49, 18, 49, 19, 49, 20, 49, 21, 49, 23, 49, 22, 49, 26, 49, 28, 49, 25, 49, 29, 49, 27, 49, 24, 49, 12, 49, 13, 49, 14, 49, 15, 49, 17, 49, 16, 49, 32, 49, 34, 49, 31, 49, 35, 49, 33, 49, 30, 49, 42, 49, 0, 49, 1, 49, 2, 49, 3, 49, 5, 49, 4, 49, 38, 49, 40, 49, 37, 49, 41, 49, 39, 49, 6, 49, 7, 49, 8, 49, 9, 49, 11, 49, 45, 49, 46, 49, 43, 49, 47, 49, 44, 49, 49.

| Discovered system ID | Independent Carbon golden |
| --- | --- |
| com.apple.keylayout.ABC | <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  "</code> (U+0060 U+0020 U+0031 U+0020 U+0032 U+0020 U+0033 U+0020 U+0034 U+0020 U+0035 U+0020 U+0036 U+0020 U+0037 U+0020 U+0038 U+0020 U+0039 U+0020 U+0030 U+0020 U+002D U+0020 U+003D U+0020 U+0071 U+0020 U+0077 U+0020 U+0065 U+0020 U+0072 U+0020 U+0074 U+0020 U+0079 U+0020 U+0075 U+0020 U+0069 U+0020 U+006F U+0020 U+0070 U+0020 U+005B U+0020 U+005D U+0020 U+005C U+0020 U+0061 U+0020 U+0073 U+0020 U+0064 U+0020 U+0066 U+0020 U+0067 U+0020 U+0068 U+0020 U+006A U+0020 U+006B U+0020 U+006C U+0020 U+003B U+0020 U+0027 U+0020 U+007A U+0020 U+0078 U+0020 U+0063 U+0020 U+0076 U+0020 U+0062 U+0020 U+006E U+0020 U+006D U+0020 U+002C U+0020 U+002E U+0020 U+002F U+0020 U+0020) |
| com.apple.keylayout.RussianWin | <code>"ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  "</code> (U+0451 U+0020 U+0031 U+0020 U+0032 U+0020 U+0033 U+0020 U+0034 U+0020 U+0035 U+0020 U+0036 U+0020 U+0037 U+0020 U+0038 U+0020 U+0039 U+0020 U+0030 U+0020 U+002D U+0020 U+003D U+0020 U+0439 U+0020 U+0446 U+0020 U+0443 U+0020 U+043A U+0020 U+0435 U+0020 U+043D U+0020 U+0433 U+0020 U+0448 U+0020 U+0449 U+0020 U+0437 U+0020 U+0445 U+0020 U+044A U+0020 U+005C U+0020 U+0444 U+0020 U+044B U+0020 U+0432 U+0020 U+0430 U+0020 U+043F U+0020 U+0440 U+0020 U+043E U+0020 U+043B U+0020 U+0434 U+0020 U+0436 U+0020 U+044D U+0020 U+044F U+0020 U+0447 U+0020 U+0441 U+0020 U+043C U+0020 U+0438 U+0020 U+0442 U+0020 U+044C U+0020 U+0431 U+0020 U+044E U+0020 U+002E U+0020 U+0020) |
| com.apple.keylayout.Ukrainian-PC | <code>"ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  "</code> (U+0491 U+0020 U+0031 U+0020 U+0032 U+0020 U+0033 U+0020 U+0034 U+0020 U+0035 U+0020 U+0036 U+0020 U+0037 U+0020 U+0038 U+0020 U+0039 U+0020 U+0030 U+0020 U+002D U+0020 U+003D U+0020 U+0439 U+0020 U+0446 U+0020 U+0443 U+0020 U+043A U+0020 U+0435 U+0020 U+043D U+0020 U+0433 U+0020 U+0448 U+0020 U+0449 U+0020 U+0437 U+0020 U+0445 U+0020 U+0457 U+0020 U+02BC U+0020 U+0444 U+0020 U+0456 U+0020 U+0432 U+0020 U+0430 U+0020 U+043F U+0020 U+0440 U+0020 U+043E U+0020 U+043B U+0020 U+0434 U+0020 U+0436 U+0020 U+0454 U+0020 U+044F U+0020 U+0447 U+0020 U+0441 U+0020 U+043C U+0020 U+0438 U+0020 U+0442 U+0020 U+044C U+0020 U+0431 U+0020 U+044E U+0020 U+002E U+0020 U+0020) |

Independent OS conversion results

| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Forward apply | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | AGREE |
| Forward apply | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | AGREE |
| Fresh forward next [reference, target] | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | AGREE |
| Fresh reverse next [reference, target] | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Forward apply | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | AGREE |
| Fresh forward next [reference, target] | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | AGREE |
| Fresh reverse next [reference, target] | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.ABC, step 1 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 2 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 3 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 4 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 5 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 6 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 1 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 2 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 3 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 4 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 5 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 6 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 1 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 2 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 3 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 4 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 5 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 6 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |

Map-derived cycle consistency ONLY

| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Cycle from com.apple.keylayout.ABC, step 1 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 2 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 3 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 4 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 5 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | AGREE |
| Cycle from com.apple.keylayout.ABC, step 6 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 1 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 2 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 3 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 4 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 5 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.RussianWin, step 6 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 1 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 2 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 3 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 4 | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . /  " | com.apple.keylayout.ABC | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 5 | "&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю .  " | com.apple.keylayout.RussianWin | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | DIFFERENT |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 6 | "ё 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ъ &#92;&#92; ф ы в а п р о л д ж э я ч с м и т ь б ю ю  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю .  " | com.apple.keylayout.Ukrainian-PC | "ґ 1 2 3 4 5 6 7 8 9 0 - = й ц у к е н г ш щ з х ї ʼ ф і в а п р о л д ж є я ч с м и т ь б ю ю  " | DIFFERENT |

### Russian-PC ghbdtn

Physical key codes: 5, 4, 11, 2, 17, 45.

| Discovered system ID | Independent Carbon golden |
| --- | --- |
| com.apple.keylayout.ABC | <code>"ghbdtn"</code> (U+0067 U+0068 U+0062 U+0064 U+0074 U+006E) |
| com.apple.keylayout.RussianWin | <code>"привет"</code> (U+043F U+0440 U+0438 U+0432 U+0435 U+0442) |
| com.apple.keylayout.Ukrainian-PC | <code>"привет"</code> (U+043F U+0440 U+0438 U+0432 U+0435 U+0442) |

Fixture declaration checked against this exact OS variant: requested <code>"привет"</code> (U+043F U+0440 U+0438 U+0432 U+0435 U+0442); Carbon returned <code>"привет"</code> (U+043F U+0440 U+0438 U+0432 U+0435 U+0442); AGREE. Engine expectations below use Carbon, not the declaration.

Independent OS conversion results

| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Forward apply | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Fresh forward next [reference, target] | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Fresh reverse next [reference, target] | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 1 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 2 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 3 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 4 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 5 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 6 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 1 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 2 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 3 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 4 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 5 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 6 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 1 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 2 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 3 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 4 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 5 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 6 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |

Map-derived cycle consistency ONLY

| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Cycle from com.apple.keylayout.ABC, step 1 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 2 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 3 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 4 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 5 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 6 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 1 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 2 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 3 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 4 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 5 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 6 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 1 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 2 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 3 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 4 | "привет" | com.apple.keylayout.ABC | "ghbdtn" | com.apple.keylayout.ABC | "ghbdtn" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 5 | "ghbdtn" | com.apple.keylayout.RussianWin | "привет" | com.apple.keylayout.RussianWin | "привет" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 6 | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | com.apple.keylayout.Ukrainian-PC | "привет" | AGREE |

### Ukrainian-PC s]'&#92;

Physical key codes: 1, 30, 39, 42.

| Discovered system ID | Independent Carbon golden |
| --- | --- |
| com.apple.keylayout.ABC | <code>"s]&#92;'&#92;&#92;"</code> (U+0073 U+005D U+0027 U+005C) |
| com.apple.keylayout.RussianWin | <code>"ыъэ&#92;&#92;"</code> (U+044B U+044A U+044D U+005C) |
| com.apple.keylayout.Ukrainian-PC | <code>"іїєʼ"</code> (U+0456 U+0457 U+0454 U+02BC) |

Fixture declaration checked against this exact OS variant: requested <code>"іїєʼ"</code> (U+0456 U+0457 U+0454 U+02BC); Carbon returned <code>"іїєʼ"</code> (U+0456 U+0457 U+0454 U+02BC); AGREE. Engine expectations below use Carbon, not the declaration.

Independent OS conversion results

| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Forward apply | "s]&#92;'&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Fresh forward next [reference, target] | "s]&#92;'&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Fresh reverse next [reference, target] | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 1 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 2 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 3 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 4 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 5 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 6 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 1 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 2 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 3 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 4 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 5 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 6 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 1 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 2 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 3 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 4 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 5 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 6 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |

Map-derived cycle consistency ONLY

| Check | Exact input | Expected ID | Expected text | Actual ID | Actual text | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Cycle from com.apple.keylayout.ABC, step 1 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 2 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 3 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 4 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 5 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.ABC, step 6 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 1 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 2 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 3 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 4 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 5 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.RussianWin, step 6 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 1 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 2 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 3 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 4 | "іїєʼ" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | com.apple.keylayout.ABC | "s]&#92;'&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 5 | "s]&#92;'&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | com.apple.keylayout.RussianWin | "ыъэ&#92;&#92;" | AGREE |
| Cycle from com.apple.keylayout.Ukrainian-PC, step 6 | "ыъэ&#92;&#92;" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | com.apple.keylayout.Ukrainian-PC | "іїєʼ" | AGREE |


## Repeat

```sh
LANGY_SYSTEM_AUDIT_REPORT=/absolute/path/langy-system-audit.md swift test --filter SystemLayoutAuditTests
```

Use an existing writable parent directory. XCTest requires Xcode: if Command Line Tools are selected, prefix the command with DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer and invoke xcrun swift instead of swift; this does not change xcode-select. Use a separate --scratch-path when another agent is building. Add LANGY_AUDIT_STRICT=1 to fail after writing the report when discrepancies are observed. Without LANGY_SYSTEM_AUDIT_REPORT this XCTest skips before touching TIS or defaults. A zero exit status in reporting mode means only that collection and writing completed.
