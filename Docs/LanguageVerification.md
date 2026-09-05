# Language Engine Verification

## Verdict

**The current engine does not pass the 50-language coverage audit.**

Langy repairs keyboard-layout mistakes by mapping physical key positions. It
does not translate, check grammar, or identify languages linguistically.
Catalog membership, an unchanged string, and a successful cached round trip
are not proof of correct fresh conversion.

This audit leaves production code and user keyboard settings unchanged. The
test suite exercises the actual `Transliterator` and `LayoutStore`, not a new
implementation substituted for the engine.

## Scope

The [50-language matrix](LanguageAudit.md#language-matrix) uses the repository's
current language roster, counts Serbian's two scripts as one language, excludes
Arabic/Hebrew from that roster, and adds Russian, Ukrainian, and Macedonian.
Arabic and Hebrew remain additional tests of shipped layouts.

This is an explicit **product coverage list, not a demographic top-50 ranking**.
"Most common" needs a speaker population, geography, date, and a decision on
regional languages versus immigrant languages. Armenian and Sami, for example,
could belong in a different roster. Each language also needs a declared keyboard
variant; French AZERTY, French Mac, and French PC are not interchangeable.

The shipped catalog has 50 entries but only 49 distinct language labels.
Russian, Ukrainian, and Macedonian have no builtin definition. Polish, Maltese,
Irish, Welsh, and Scottish Gaelic have empty maps. Shared maps are identified
in the report and do not establish independent regional-language coverage.

## Observed Results

Measured on 2026-09-05, macOS 26.6.2, ARM64, ANSI keyboard type 43. Results apply
to the production source at base commit `51e02ed`, not to future changes.

| Check | Observed result | What it establishes |
| --- | --- | --- |
| Existing six tests | Pass | Existing behavior/parity, not language correctness |
| New ordinary assertions | Pass | Catalog integrity, two complete cached cycles, selected Unicode preservation, French NFC/NFD equivalence, empty input |
| Fresh isolated reverse corpus | 10/42 exact recoveries | Internal reversibility for nonidentity roster layouts |
| Fresh full-catalog recovery | 10/42 exact recoveries | Source detection followed by cycling back to US |
| All 2,450 shipped directed pairs | 754 pass, 1,614 fail, 82 indistinguishable | Fresh two-layout conversion on the complete unshifted key-position corpus |
| Independent fixed XKB fixtures | 4/20 agree; 16 differ or are absent | Deliberately diagnostic samples, not an accuracy percentage |
| Live macOS builtin comparison | 2,209/2,352 key outputs agree; 143 differ across 45 entries | Agreement with the exact named macOS variants, not universal keyboard standards |
| Actual default discovery | ABC, Russian-PC, Ukrainian-PC | These enabled keyboards were found; no enabled keyboard-layout entries were omitted on this host |
| Discovered-layout independent conversion checks | 53/67 agree; 14 discrepancies | Includes actual forward, fresh reverse, and cycling behavior against OS output |

Debug and release strict runs reproduced the same totals: 11 ordinary tests
passed and both audit tests failed on the reported gaps. Without audit opt-in,
the suite passes 11 tests and explicitly skips the two report tests.

The pair corpus includes all 47 unshifted printable key positions, separated
by spaces, plus whitespace and unmapped Unicode. Expected pair renderings come
from the shipped maps, so these are **internal consistency tests**, not proof
that those maps describe real keyboards. Passing entries such as Icelandic
still have independent mapping errors. The pair failure rate is not an estimate
of the failure rate for everyday sentences. Alias and identity-only entries
duplicate outcomes against other targets; totals are per catalog ID, not
independent language coverage.

The live builtin audit compares 35 distinct macOS variants, with 14 explicit
inherited-base proxy comparisons and one unmatched builtin. Proxies repeat
base-layout evidence. Many differences involve the grave/ISO position or a
different national variant; inspect the per-key details before changing maps.

Reports contain exact inputs, expected/actual output, variant IDs, and exclusions:

- [Language audit and complete 50-language matrix](LanguageAudit.md)
- [Live macOS keyboard and production-discovery audit](SystemLayoutAudit.md)

## Confirmed Gaps

1. **Fresh reverse decoding skips mapped ASCII.**
   `Transliterator.decode` only reverses non-ASCII characters, even after it
   chooses a source layout. German `z` is not recovered to US `y`, French `a`
   is not recovered to US `q`, and Greek punctuation is not recovered correctly.
   Russian-PC and Ukrainian-PC corpus reversals leave a period where the
   original US slash belongs. Cached cycles retain the original positional
   base and hide this failure.

2. **Shift is approximated by Unicode uppercase.**
   US `{` should map to German U+00DC, but remains `{`. French `M` should map
   to `?`, but becomes `,`. Uppercasing letters is not a keyboard modifier
   model. System discovery also reads only the unmodified layer.

3. **Maps are missing, incomplete, or assigned to an undeclared variant.**
   Independent fixtures expose missing/wrong positions for Bulgarian,
   Belarusian, Serbian, Icelandic, Faroese, Azerbaijani, and Maltese.
   A Turkish alias does not supply Azerbaijani's full layout. Empty Polish or
   Celtic maps do not provide their diacritics, even where plain keys match US.

4. **Some recovery is ambiguous by construction.**
   Text alone cannot distinguish identical layouts or an ASCII-only QWERTZ
   word from a US word. Arabic lam-alef can come from the builtin `b` mapping
   or the sequence `gh`. Slovak maps both `8` and `[` to the same letter.
   The current algorithm neither models these ambiguities nor reports them.

5. **System availability is not builtin availability.**
   Default mode uses only enabled system layouts plus customs, not builtin
   fallback. The installed Russian/Ukrainian layouts work for the short word
   fixtures despite missing builtins. LayoutStore filters out non-reference
   layouts with fewer than five changed unmodified keys; coverage of such
   layouts remains a risk even though none were omitted on this host.

## Reproduce

Run from the repository root. XCTest requires full Xcode on this machine;
plain `swift test` under Command Line Tools failed with `no such module 'XCTest'`.
The command-local developer path does not change `xcode-select` or preferences.

Ordinary regression suite (the two report tests explicitly skip):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift test
```

Collect both reports and fail if support gaps are observed:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
LANGY_LANGUAGE_AUDIT_REPORT="$PWD/Docs/LanguageAudit.md" \
LANGY_SYSTEM_AUDIT_REPORT="$PWD/Docs/SystemLayoutAudit.md" \
LANGY_AUDIT_STRICT=1 \
xcrun swift test
```

**A nonzero result is currently expected in strict mode.** Both reports are
written before their audit assertions fail. Removing `LANGY_AUDIT_STRICT=1`
collects reports without failing on discrepancies; that exit status means
collection succeeded, not that language support passed. Add `-c release` to
test optimized code. Reports are opt-in and require existing writable parent
directories. Live results can change with macOS, keyboard hardware, locale,
and enabled layouts.

## Independent Sources

Fixed goldens use a pinned, publicly readable distribution copy of
[xkeyboard-config 2.42](https://github.com/deepin-community/xkeyboard-config/tree/873c813bf1ed4adfb231ea2afd295e5366cf62d5).
The upstream raw endpoint was inaccessible during research. Byte-for-byte
equivalence to upstream or Apple's layouts is not claimed. Tests do not need
network access; expectations and exact variant names are checked in.

- Physical reference: [`symbols/us`](https://github.com/deepin-community/xkeyboard-config/blob/873c813bf1ed4adfb231ea2afd295e5366cf62d5/symbols/us).
- German/French/Greek: `symbols/de` (`basic`), `symbols/fr` (`basic`), `symbols/gr` (`basic`, including `simple`).
- Cyrillic: `symbols/by` (`basic`, including `ru(winkeys)`), `symbols/bg` (`phonetic`), `symbols/rs` (`basic`, including `cyralpha`; `latin`).
- Turkish/Icelandic/Faroese/Azerbaijani: `symbols/tr` (`basic`), `symbols/is` (`basic`, `mac`), `symbols/fo` (`basic`), `symbols/az` (`latin`).
- Polish/Maltese: `symbols/pl` (`basic`; plain keys only), `symbols/mt` (`us`).
- Missing builtins: `symbols/ru` (`winkeys`), `symbols/ua` (`unicode`), `symbols/mk` (`basic`).

All symbol paths refer to the pinned tree above. The separate live audit uses
macOS `TISCreateInputSourceList` and `UCKeyTranslate` at named physical keycodes,
not builtin dictionaries, as its independent oracle. It never enables or
selects keyboards. Its Ukrainian-PC output differs from XKB `ua(unicode)` at
the backslash position; the report makes this variant difference explicit.

## Before Claiming Support

Choose explicit keyboard variants and a definition of supported modifier/dead-key
behavior first. Then repair fresh decoding, represent actual modifier layers,
and correct/complete maps against those standards. Do not fix all macOS/XKB
differences by blindly choosing whichever variant makes a test green.

No automated test here inserts text into another application. Accessibility
replacement, selections/caret handling, hotkeys, secure fields, long Unicode
typing chunks, and native/browser/Electron editor behavior still need end-to-end
verification. Full Option/AltGr, dead-key composition, IMEs, and linguistic
quality are not certified by these tests.
