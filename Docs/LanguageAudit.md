# Langy 50-Language Engine Audit

**NOT VERIFIED: GAPS FOUND**

- Generated: 2026-09-05T08:49:54Z
- Host: Version 26.6.2 (Build 25G83)
- Roster: 50 distinct product language labels, 51 requested layouts including both Serbian scripts. Not a demographic top-50 ranking.
- Missing builtins: 3. Non-English identity-only entries: 5.
- Fresh isolated reverse: 10/42 exact recoveries of the key-position corpus.
- Fresh full-catalog source detection followed by cycling to US: 10/42 exact recoveries.
- All 50 shipped layouts, directed pairs: 754 pass, 1614 fail, 82 indistinguishable; 2450 total.
- Independent XKB variant/Shift fixtures: 4/20 agree; 16 differ or are missing.
- Fresh reverse diagnostic fixtures: 0/5 pass.
- Strict mode: true. A successful reporting invocation means collection succeeded, NOT that support passed.

## Method

Every reverse case gets a new production Transliterator. Isolated tests enable US plus the target; full-catalog tests use LayoutStore's localized name ordering and look for the US result within one cycle. Directed-pair tests enable exactly source and target and require the very first conversion to return the target ID and exact expected text. Identical renderings are excluded rather than counted as support.

The key-position corpus is <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>. Its forward renderings come from the shipped maps: these tests measure internal recoverability, NOT independent keyboard correctness. They intentionally include punctuation and digits, not just easy alphabetic words. Cached-cycle and Unicode-preservation assertions run as separate ordinary tests. A PASS here covers only the specified corpus, not arbitrary prose or all keyboard layers.

Independent keyboard correctness comes from the pinned XKB fixtures below and the separate live macOS report. Different named variants can legitimately disagree. No language model, translation, linguistic quality, Accessibility writes, hotkeys, or real host-editor integration is certified here. No active keyboard or app preference is changed.

## Language Matrix

Identity rows are not reverse-test passes. Included means visited by the separate cached-cycle test, not independent correctness. Russian/Ukrainian can still be available in system mode despite absent builtins.

| Language | Builtin ID | Map coverage | Fresh reverse to US | Full-catalog recovery | Cached cycle |
| --- | --- | --- | --- | --- | --- |
| Albanian | builtin.sq | 2 entries | PASS | PASS | Included |
| Azerbaijani | builtin.az | 10 entries; shared map | FAIL | FAIL | Included |
| Basque | builtin.eu | 9 entries; shared map | FAIL | FAIL | Included |
| Belarusian | builtin.be | 33 entries | PASS | PASS | Included |
| Bosnian | builtin.bs | 9 entries; shared map | FAIL | FAIL | Included |
| Breton | builtin.br | 26 entries; shared map | FAIL | FAIL | Included |
| Bulgarian | builtin.bg | 28 entries | PASS | PASS | Included |
| Catalan | builtin.ca | 9 entries; shared map | FAIL | FAIL | Included |
| Corsican | builtin.co | 26 entries; shared map | FAIL | FAIL | Included |
| Croatian | builtin.hr | 9 entries; shared map | FAIL | FAIL | Included |
| Czech | builtin.cs | 19 entries | FAIL | FAIL | Included |
| Danish | builtin.da | 9 entries; shared map | FAIL | FAIL | Included |
| Dutch | builtin.nl | 1 entries; shared map | FAIL | FAIL | Included |
| English | builtin.en | US identity reference | Identity; not evidence | Identity; not evidence | Included |
| Estonian | builtin.et | 4 entries | PASS | PASS | Included |
| Faroese | builtin.fo | 9 entries; shared map | FAIL | FAIL | Included |
| Finnish | builtin.fi | 9 entries; shared map | FAIL | FAIL | Included |
| French | builtin.fr | 26 entries; shared map | FAIL | FAIL | Included |
| Frisian | builtin.fy | 1 entries; shared map | FAIL | FAIL | Included |
| Galician | builtin.gl | 9 entries; shared map | FAIL | FAIL | Included |
| Georgian | builtin.ka | 26 entries | PASS | PASS | Included |
| German | builtin.de | 11 entries; shared map | FAIL | FAIL | Included |
| Greek | builtin.el | 26 entries | FAIL | FAIL | Included |
| Hungarian | builtin.hu | 13 entries | FAIL | FAIL | Included |
| Icelandic | builtin.is | 5 entries | PASS | PASS | Included |
| Irish | builtin.ga | EMPTY: identity only | Identity; not evidence | Identity; not evidence | Included |
| Italian | builtin.it | 9 entries; shared map | FAIL | FAIL | Included |
| Latvian | builtin.lv | 7 entries | PASS | PASS | Included |
| Lithuanian | builtin.lt | 8 entries | PASS | PASS | Included |
| Luxembourgish | builtin.lb | 11 entries; shared map | FAIL | FAIL | Included |
| Macedonian | builtin.mk | MISSING | Not tested | Not tested | Not tested |
| Maltese | builtin.mt | EMPTY: identity only | Identity; not evidence | Identity; not evidence | Included |
| Montenegrin | builtin.me | 9 entries; shared map | FAIL | FAIL | Included |
| Norwegian | builtin.no | 8 entries | FAIL | FAIL | Included |
| Occitan | builtin.oc | 26 entries; shared map | FAIL | FAIL | Included |
| Polish | builtin.pl | EMPTY: identity only | Identity; not evidence | Identity; not evidence | Included |
| Portuguese | builtin.pt | 7 entries | FAIL | FAIL | Included |
| Romanian | builtin.ro | 4 entries | PASS | PASS | Included |
| Romansh | builtin.rm | 11 entries; shared map | FAIL | FAIL | Included |
| Russian | builtin.ru | MISSING | Not tested | Not tested | Not tested |
| Sardinian | builtin.sc | 9 entries; shared map | FAIL | FAIL | Included |
| Scottish Gaelic | builtin.gd | EMPTY: identity only | Identity; not evidence | Identity; not evidence | Included |
| Serbian | builtin.sr-cyrl | 29 entries | PASS | PASS | Included |
| Serbian | builtin.sr-latn | 9 entries; shared map | FAIL | FAIL | Included |
| Slovak | builtin.sk | 19 entries | FAIL | FAIL | Included |
| Slovenian | builtin.sl | 7 entries | FAIL | FAIL | Included |
| Spanish | builtin.es | 9 entries; shared map | FAIL | FAIL | Included |
| Swedish | builtin.sv | 9 entries; shared map | FAIL | FAIL | Included |
| Turkish | builtin.tr | 10 entries; shared map | FAIL | FAIL | Included |
| Ukrainian | builtin.uk | MISSING | Not tested | Not tested | Not tested |
| Welsh | builtin.cy | EMPTY: identity only | Identity; not evidence | Identity; not evidence | Included |

## Independent Forward Fixtures

XKB 2.42 distribution source, pinned at 873c813bf1ed4adfb231ea2afd295e5366cf62d5. Exact links and scope: [verification guide](LanguageVerification.md). Plain inputs denote US physical positions; Shift cases use the character produced by US with Shift held. Polish's unchanged plain letters do not test AltGr diacritics.

| Builtin | XKB variant / layer | US input | Expected | Actual | Result |
| --- | --- | --- | --- | --- | --- |
| de | de(basic) | <code>"y-z[;&#92;'"</code> | <code>"zßyüöä"</code> | <code>"zßyüöä"</code> | PASS |
| fr | fr(basic) | <code>"q2;"</code> | <code>"aém"</code> | <code>"aém"</code> | PASS |
| el | gr(basic) | <code>"qws"</code> | <code>";ςσ"</code> | <code>";ςσ"</code> | PASS |
| be | by(basic) | <code>"o]b/"</code> | <code>"ў&#92;'і."</code> | <code>"ўъі/"</code> | DIFFERS |
| bg | bg(phonetic) | <code>"q[]x"</code> | <code>"яшщь"</code> | <code>"ячшx"</code> | DIFFERS |
| sr-cyrl | rs(basic) | <code>"qwyzx"</code> | <code>"љњзжџ"</code> | <code>"љњзџx"</code> | DIFFERS |
| sr-latn | rs(latin) | <code>"&#92;&#92;="</code> | <code>"ž+"</code> | <code>"&#92;&#92;ž"</code> | DIFFERS |
| tr | tr(basic) | <code>"i&#92;'&#92;&#92;"</code> | <code>"ıi,"</code> | <code>"ıi&#92;&#92;"</code> | DIFFERS |
| is | is(basic), is(mac) | <code>"[-;/"</code> | <code>"ðöæþ"</code> | <code>"ð-ö/"</code> | DIFFERS |
| fo | fo(basic) | <code>"[];&#92;'"</code> | <code>"åðæø"</code> | <code>"å¨æø"</code> | DIFFERS |
| az | az(latin) | <code>"wi[];&#92;'"</code> | <code>"üiöğıə"</code> | <code>"wığüşi"</code> | DIFFERS |
| pl | pl(basic), UNMODIFIED ONLY | <code>"acelnosxz"</code> | <code>"acelnosxz"</code> | <code>"acelnosxz"</code> | PASS |
| mt | mt(us) | <code>"&#96;[]&#92;&#92;"</code> | <code>"ċġħż"</code> | <code>"&#96;[]&#92;&#92;"</code> | DIFFERS |
| de | de(basic), Shift+[ | <code>"{"</code> | <code>"Ü"</code> | <code>"{"</code> | DIFFERS |
| fr | fr(basic), Shift+m | <code>"M"</code> | <code>"?"</code> | <code>","</code> | DIFFERS |
| el | gr(basic), Shift+q | <code>"Q"</code> | <code>":"</code> | <code>";"</code> | DIFFERS |
| tr | tr(basic), Shift+' | <code>"&#92;""</code> | <code>"İ"</code> | <code>"&#92;""</code> | DIFFERS |
| ru | ru(winkeys) | <code>"ghbdtn"</code> | <code>"привет"</code> | NOT PRODUCED | MISSING |
| uk | ua(unicode) | <code>"s]&#92;'&#92;&#92;"</code> | <code>"іїєґ"</code> | NOT PRODUCED | MISSING |
| mk | mk(basic) | <code>"y]&#92;'&#92;&#92;x"</code> | <code>"ѕѓќжџ"</code> | NOT PRODUCED | MISSING |

## Fresh Reverse Diagnostics

German, French and Greek base fixtures use the same independent key positions as above. German uppercase tests the actual Shift+quote US position, not Unicode case conversion. Arabic lam-alef is an extra multi-character diagnostic: the shipped map emits it from b, but gh can emit the same sequence, so exact fresh recovery is intrinsically ambiguous without keystroke/source context.

| Source | Fresh input | Expected US positions | Actual | Result |
| --- | --- | --- | --- | --- |
| de | <code>"zö"</code> | <code>"y;"</code> | <code>"z;"</code> | FAIL |
| fr | <code>"aém"</code> | <code>"q2;"</code> | <code>"a2m"</code> | FAIL |
| el | <code>";ς"</code> | <code>"qw"</code> | <code>";w"</code> | FAIL |
| de | <code>"Ä"</code> | <code>"&#92;""</code> | <code>"&#92;'"</code> | FAIL |
| ar | <code>"لا"</code> | <code>"b"</code> | <code>"gh"</code> | FAIL |

## Directed Pair Results

Includes Arabic/Hebrew as additional shipped layouts; this is not a claim of 50 distinct languages. Equal-rendering pairs are excluded; aliases and identity-only entries also duplicate pass/fail outcomes against other targets. Totals are per catalog ID, not independent language or map coverage.

| Source | Pass | Fail | Indistinguishable | Failed target IDs |
| --- | ---: | ---: | ---: | --- |
| builtin.sq | 49 | 0 | 0 |  |
| builtin.ar | 0 | 49 | 0 | builtin.sq, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.az | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.cy |
| builtin.eu | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.sv, builtin.tr, builtin.cy |
| builtin.be | 49 | 0 | 0 |  |
| builtin.bs | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.br | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.bg, builtin.ca, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.bg | 49 | 0 | 0 |  |
| builtin.ca | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.sv, builtin.tr, builtin.cy |
| builtin.co | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.bg, builtin.ca, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.hr | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.cs | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.da | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.nl, builtin.en, builtin.et, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.nl | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.en | 44 | 0 | 5 |  |
| builtin.et | 49 | 0 | 0 |  |
| builtin.fo | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.nl, builtin.en, builtin.et, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.fi | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.tr, builtin.cy |
| builtin.fr | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.bg, builtin.ca, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.fy | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.gl | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.sv, builtin.tr, builtin.cy |
| builtin.ka | 49 | 0 | 0 |  |
| builtin.de | 0 | 47 | 2 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.el | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.he | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.hu | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.is | 49 | 0 | 0 |  |
| builtin.ga | 44 | 0 | 5 |  |
| builtin.it | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.lv | 49 | 0 | 0 |  |
| builtin.lt | 49 | 0 | 0 |  |
| builtin.lb | 0 | 47 | 2 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.mt | 44 | 0 | 5 |  |
| builtin.me | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.no | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.oc | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.bg, builtin.ca, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.pl | 44 | 0 | 5 |  |
| builtin.pt | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.ro | 49 | 0 | 0 |  |
| builtin.rm | 0 | 47 | 2 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.sc | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.gd | 44 | 0 | 5 |  |
| builtin.sr-cyrl | 49 | 0 | 0 |  |
| builtin.sr-latn | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.sk | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sl, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.sl | 0 | 49 | 0 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.es, builtin.sv, builtin.tr, builtin.cy |
| builtin.es | 0 | 46 | 3 | builtin.sq, builtin.ar, builtin.az, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.sv, builtin.tr, builtin.cy |
| builtin.sv | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.az, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.tr, builtin.cy |
| builtin.tr | 0 | 48 | 1 | builtin.sq, builtin.ar, builtin.eu, builtin.be, builtin.bs, builtin.br, builtin.bg, builtin.ca, builtin.co, builtin.hr, builtin.cs, builtin.da, builtin.nl, builtin.en, builtin.et, builtin.fo, builtin.fi, builtin.fr, builtin.fy, builtin.gl, builtin.ka, builtin.de, builtin.el, builtin.he, builtin.hu, builtin.is, builtin.ga, builtin.it, builtin.lv, builtin.lt, builtin.lb, builtin.mt, builtin.me, builtin.no, builtin.oc, builtin.pl, builtin.pt, builtin.ro, builtin.rm, builtin.sc, builtin.gd, builtin.sr-cyrl, builtin.sr-latn, builtin.sk, builtin.sl, builtin.es, builtin.sv, builtin.cy |
| builtin.cy | 44 | 0 | 5 |  |

## Reverse Details and Shared Maps

- builtin.az has the same dictionary as: builtin.tr.
- builtin.az fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 * - q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; i z x c v b n m , . . &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.eu has the same dictionary as: builtin.ca, builtin.es, builtin.gl.
- builtin.eu fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t y u i o p &#96; + &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.bs has the same dictionary as: builtin.hr, builtin.me, builtin.sr-latn.
- builtin.bs fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.br has the same dictionary as: builtin.co, builtin.fr, builtin.oc.
- builtin.br fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; &amp; 2 &#92;" &#92;' ( - 7 _ 9 0 ) = a z e r t y u i o p ^ $ * q s d f g h j k l m &#92;' w x c v b n , ; : ! &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.ca has the same dictionary as: builtin.es, builtin.eu, builtin.gl.
- builtin.ca fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t y u i o p &#96; + &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.co has the same dictionary as: builtin.br, builtin.fr, builtin.oc.
- builtin.co fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; &amp; 2 &#92;" &#92;' ( - 7 _ 9 0 ) = a z e r t y u i o p ^ $ * q s d f g h j k l m &#92;' w x c v b n , ; : ! &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.hr has the same dictionary as: builtin.bs, builtin.me, builtin.sr-latn.
- builtin.hr fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.cs fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"; + 2 3 4 5 6 7 8 9 0 = = q w e r t z u i o p [ ) &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.da has the same dictionary as: builtin.fo.
- builtin.da fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 + = q w e r t y u i o p [ ] &#92;' a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.nl has the same dictionary as: builtin.fy.
- builtin.nl fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got NOT PRODUCED.
- builtin.en has the same dictionary as: builtin.cy, builtin.ga, builtin.gd, builtin.mt, builtin.pl.
- builtin.fo has the same dictionary as: builtin.da.
- builtin.fo fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 + = q w e r t y u i o p [ ] &#92;' a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.fi has the same dictionary as: builtin.sv.
- builtin.fi fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 + = q w e r t y u i o p [ ] &#92;' a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.fr has the same dictionary as: builtin.br, builtin.co, builtin.oc.
- builtin.fr fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; &amp; 2 &#92;" &#92;' ( - 7 _ 9 0 ) = a z e r t y u i o p ^ $ * q s d f g h j k l m &#92;' w x c v b n , ; : ! &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.fy has the same dictionary as: builtin.nl.
- builtin.fy fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got NOT PRODUCED.
- builtin.gl has the same dictionary as: builtin.ca, builtin.es, builtin.eu.
- builtin.gl fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t y u i o p &#96; + &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.de has the same dictionary as: builtin.lb, builtin.rm.
- builtin.de fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"^ 1 2 3 4 5 6 7 8 9 0 - = q w e r t z u i o p [ + # a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.el fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = ; w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.hu fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m ? : _ &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.ga has the same dictionary as: builtin.cy, builtin.en, builtin.gd, builtin.mt, builtin.pl.
- builtin.it has the same dictionary as: builtin.sc.
- builtin.it fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#92;&#92; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t y u i o p [ + &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.lb has the same dictionary as: builtin.de, builtin.rm.
- builtin.lb fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"^ 1 2 3 4 5 6 7 8 9 0 - = q w e r t z u i o p [ + # a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.mt has the same dictionary as: builtin.cy, builtin.en, builtin.ga, builtin.gd, builtin.pl.
- builtin.me has the same dictionary as: builtin.bs, builtin.hr, builtin.sr-latn.
- builtin.me fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.no fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 + &#92;&#92; q w e r t y u i o p [ ] &#92;' a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.oc has the same dictionary as: builtin.br, builtin.co, builtin.fr.
- builtin.oc fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; &amp; 2 &#92;" &#92;' ( - 7 _ 9 0 ) = a z e r t y u i o p ^ $ * q s d f g h j k l m &#92;' w x c v b n , ; : ! &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.pl has the same dictionary as: builtin.cy, builtin.en, builtin.ga, builtin.gd, builtin.mt.
- builtin.pt fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#92;&#92; 1 2 3 4 5 6 7 8 9 0 / = q w e r t y u i o p + ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.rm has the same dictionary as: builtin.de, builtin.lb.
- builtin.rm fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"^ 1 2 3 4 5 6 7 8 9 0 - = q w e r t z u i o p [ + # a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.sc has the same dictionary as: builtin.it.
- builtin.sc fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#92;&#92; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t y u i o p [ + &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.gd has the same dictionary as: builtin.cy, builtin.en, builtin.ga, builtin.mt, builtin.pl.
- builtin.sr-latn has the same dictionary as: builtin.bs, builtin.hr, builtin.me.
- builtin.sr-latn fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.sk fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"; + 2 3 4 5 6 7 [ 9 0 = = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.sl fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t z u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' y x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.es has the same dictionary as: builtin.ca, builtin.eu, builtin.gl.
- builtin.es fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 &#92;' = q w e r t y u i o p &#96; + &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.sv has the same dictionary as: builtin.fi.
- builtin.sv fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 + = q w e r t y u i o p [ ] &#92;' a s d f g h j k l ; &#92;' z x c v b n m , . - &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.tr has the same dictionary as: builtin.az.
- builtin.tr fresh reverse: expected <code>"&#96; 1 2 3 4 5 6 7 8 9 0 - = q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; &#92;' z x c v b n m , . / &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>, got <code>"&#96; 1 2 3 4 5 6 7 8 9 0 * - q w e r t y u i o p [ ] &#92;&#92; a s d f g h j k l ; i z x c v b n m , . . &#92;t&#92;n&#92;r&#92;n🙂👩‍💻𐐷"</code>.
- builtin.cy has the same dictionary as: builtin.en, builtin.ga, builtin.gd, builtin.mt, builtin.pl.
