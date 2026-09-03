import Foundation

/// Best-effort positional maps for 50 European languages: US key → character.
/// Only keys that DIFFER from the US layout are listed (identity is assumed).
///
/// These fill the gaps: whatever you have installed in the system is read live
/// and takes precedence (see LayoutStore); these built-ins cover the rest and
/// also work with system layouts turned off. Small regional languages that in
/// practice use a neighbour's keyboard reuse that neighbour's map.
enum BuiltinLayouts {
    // Shared bases (reused by regional languages on the same hardware).
    private static let german: [String: String] = [
        "y": "z", "z": "y", "-": "ß", "=": "´",
        "[": "ü", "]": "+", "\\": "#",
        ";": "ö", "'": "ä", "/": "-", "`": "^",
    ]
    private static let french: [String: String] = [
        "1": "&", "2": "é", "3": "\"", "4": "'", "5": "(",
        "6": "-", "7": "è", "8": "_", "9": "ç", "0": "à",
        "-": ")", "=": "=",
        "q": "a", "w": "z", "a": "q", "z": "w",
        "[": "^", "]": "$", ";": "m", "'": "ù", "\\": "*",
        "`": "²", "m": ",", ",": ";", ".": ":", "/": "!",
    ]
    private static let spanish: [String: String] = [
        "`": "º", "-": "'", "=": "¡",
        "[": "`", "]": "+", "\\": "ç",
        ";": "ñ", "'": "´", "/": "-",
    ]
    private static let italian: [String: String] = [
        "`": "\\", "-": "'", "=": "ì",
        "[": "è", "]": "+", "\\": "ù",
        ";": "ò", "'": "à", "/": "-",
    ]
    private static let dutch: [String: String] = ["`": "@"]
    private static let danish: [String: String] = [
        "`": "½", "[": "å", "]": "¨", "\\": "'",
        ";": "æ", "'": "ø", "/": "-", "-": "+", "=": "´",
    ]
    private static let serbianLatin: [String: String] = [
        "y": "z", "z": "y", "[": "š", "]": "đ",
        ";": "č", "'": "ć", "=": "ž", "-": "'", "/": "-",
    ]
    private static let turkish: [String: String] = [
        "i": "ı", "[": "ğ", "]": "ü",
        ";": "ş", "'": "i", ",": "ö", ".": "ç", "/": ".",
        "-": "*", "=": "-",
    ]

    static let all: [KeyboardLayout] = [
        KeyboardLayout(id: "builtin.en", name: "English (US)", map: [:], isSystem: false),
        KeyboardLayout(id: "builtin.de", name: "German", map: german, isSystem: false),
        KeyboardLayout(id: "builtin.fr", name: "French", map: french, isSystem: false),
        KeyboardLayout(id: "builtin.es", name: "Spanish", map: spanish, isSystem: false),
        KeyboardLayout(id: "builtin.it", name: "Italian", map: italian, isSystem: false),
        KeyboardLayout(id: "builtin.pt", name: "Portuguese", map: [
            ";": "ç", "[": "+", "]": "´", "'": "º", "`": "\\", "-": "/", "/": "-",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.nl", name: "Dutch", map: dutch, isSystem: false),
        KeyboardLayout(id: "builtin.sv", name: "Swedish", map: [
            "`": "§", "[": "å", "]": "¨", "\\": "'",
            ";": "ö", "'": "ä", "/": "-", "-": "+", "=": "´",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.no", name: "Norwegian", map: [
            "[": "å", "]": "¨", "\\": "'",
            ";": "ø", "'": "æ", "/": "-", "-": "+", "=": "\\",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.da", name: "Danish", map: danish, isSystem: false),
        KeyboardLayout(id: "builtin.fi", name: "Finnish", map: [
            "`": "§", "[": "å", "]": "¨", "\\": "'",
            ";": "ö", "'": "ä", "/": "-", "-": "+", "=": "´",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.is", name: "Icelandic", map: [
            "`": "°", "[": "ð", "]": "´", ";": "ö", "'": "æ",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.cs", name: "Czech", map: [
            "y": "z", "z": "y", "`": ";", "-": "=", "=": "´",
            "[": "ú", "]": ")", ";": "ů", "'": "§",
            "1": "+", "2": "ě", "3": "š", "4": "č", "5": "ř",
            "6": "ž", "7": "ý", "8": "á", "9": "í", "0": "é",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.sk", name: "Slovak", map: [
            "y": "z", "z": "y", "`": ";", "-": "=", "=": "´",
            "[": "á", "]": "ä", ";": "ô", "'": "§",
            "1": "+", "2": "ľ", "3": "š", "4": "č", "5": "ť",
            "6": "ž", "7": "ý", "8": "á", "9": "í", "0": "é",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.hu", name: "Hungarian", map: [
            "y": "z", "z": "y", "0": "ö", "-": "ü", "=": "ó",
            "[": "ő", "]": "ú", ";": "é", "'": "á", "\\": "ű",
            ",": "?", ".": ":", "/": "_",
        ], isSystem: false),
        // Unshifted base matches US positions (diacritics via AltGr);
        // kept so the language is represented; live system layouts convert it.
        KeyboardLayout(id: "builtin.pl", name: "Polish", map: [:], isSystem: false),
        KeyboardLayout(id: "builtin.ro", name: "Romanian", map: [
            "[": "ă", "]": "î", ";": "ș", "'": "ț",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.bg", name: "Bulgarian", map: [
            "q": "я", "w": "в", "e": "е", "r": "р", "t": "т",
            "y": "ъ", "u": "у", "i": "и", "o": "о", "p": "п",
            "[": "ч", "]": "ш",
            "a": "а", "s": "с", "d": "д", "f": "ф", "g": "г",
            "h": "х", "j": "й", "k": "к", "l": "л", "'": "щ",
            "z": "з", "c": "ц", "v": "ж", "b": "б", "n": "н", "m": "м",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.el", name: "Greek", map: [
            "q": ";", "w": "ς", "e": "ε", "r": "ρ", "t": "τ",
            "y": "υ", "u": "θ", "i": "ι", "o": "ο", "p": "π",
            "a": "α", "s": "σ", "d": "δ", "f": "φ", "g": "γ",
            "h": "η", "j": "ξ", "k": "κ", "l": "λ",
            "z": "ζ", "x": "χ", "c": "ψ", "v": "ω", "b": "β",
            "n": "ν", "m": "μ",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.tr", name: "Turkish", map: turkish, isSystem: false),
        KeyboardLayout(id: "builtin.sr-cyrl", name: "Serbian (Cyrillic)", map: [
            "q": "љ", "w": "њ", "e": "е", "r": "р", "t": "т",
            "y": "з", "u": "у", "i": "и", "o": "о", "p": "п",
            "[": "ш", "]": "ђ",
            "a": "а", "s": "с", "d": "д", "f": "ф", "g": "г",
            "h": "х", "j": "ј", "k": "к", "l": "л",
            ";": "ч", "'": "ћ",
            "z": "џ", "c": "ц", "v": "в", "b": "б", "n": "н", "m": "м",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.sr-latn", name: "Serbian (Latin)", map: serbianLatin, isSystem: false),
        KeyboardLayout(id: "builtin.hr", name: "Croatian", map: serbianLatin, isSystem: false),
        KeyboardLayout(id: "builtin.sl", name: "Slovenian", map: [
            "y": "z", "z": "y", "[": "š", ";": "č", "=": "ž", "-": "'", "/": "-",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.bs", name: "Bosnian", map: serbianLatin, isSystem: false),
        KeyboardLayout(id: "builtin.sq", name: "Albanian", map: [
            "[": "ë", "'": "ç",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.lt", name: "Lithuanian", map: [
            "1": "ą", "2": "č", "3": "ę", "4": "ė",
            "5": "į", "6": "š", "7": "ų", "8": "ū",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.lv", name: "Latvian", map: [
            "1": "ā", "2": "č", "3": "ē", "4": "ģ",
            "5": "ī", "6": "ķ", "7": "ļ",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.et", name: "Estonian", map: [
            "[": "ü", "]": "õ", ";": "ö", "'": "ä",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.mt", name: "Maltese", map: [:], isSystem: false),
        KeyboardLayout(id: "builtin.ga", name: "Irish", map: [:], isSystem: false),
        KeyboardLayout(id: "builtin.cy", name: "Welsh", map: [:], isSystem: false),
        KeyboardLayout(id: "builtin.gd", name: "Scottish Gaelic", map: [:], isSystem: false),
        KeyboardLayout(id: "builtin.eu", name: "Basque", map: spanish, isSystem: false),
        KeyboardLayout(id: "builtin.ca", name: "Catalan", map: spanish, isSystem: false),
        KeyboardLayout(id: "builtin.gl", name: "Galician", map: spanish, isSystem: false),
        KeyboardLayout(id: "builtin.lb", name: "Luxembourgish", map: german, isSystem: false),
        KeyboardLayout(id: "builtin.rm", name: "Romansh", map: german, isSystem: false),
        KeyboardLayout(id: "builtin.fy", name: "Frisian", map: dutch, isSystem: false),
        KeyboardLayout(id: "builtin.fo", name: "Faroese", map: danish, isSystem: false),
        KeyboardLayout(id: "builtin.br", name: "Breton", map: french, isSystem: false),
        KeyboardLayout(id: "builtin.co", name: "Corsican", map: french, isSystem: false),
        KeyboardLayout(id: "builtin.sc", name: "Sardinian", map: italian, isSystem: false),
        KeyboardLayout(id: "builtin.oc", name: "Occitan", map: french, isSystem: false),
        KeyboardLayout(id: "builtin.be", name: "Belarusian", map: [
            "q": "й", "w": "ц", "e": "у", "r": "к", "t": "е",
            "y": "н", "u": "г", "i": "ш", "o": "ў", "p": "з",
            "[": "х", "]": "ъ",
            "a": "ф", "s": "ы", "d": "в", "f": "а", "g": "п",
            "h": "р", "j": "о", "k": "л", "l": "д",
            ";": "ж", "'": "э",
            "z": "я", "x": "ч", "c": "с", "v": "м", "b": "і",
            "n": "т", "m": "ь", ",": "б", ".": "ю", "`": "ё",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.ar", name: "Arabic", map: [
            "q": "ض", "w": "ص", "e": "ث", "r": "ق", "t": "ف",
            "y": "غ", "u": "ع", "i": "ه", "o": "خ", "p": "ح",
            "[": "ج", "]": "د",
            "a": "ش", "s": "س", "d": "ي", "f": "ب", "g": "ل",
            "h": "ا", "j": "ت", "k": "ن", "l": "م",
            ";": "ك", "'": "ط",
            "z": "ئ", "x": "ء", "c": "ؤ", "v": "ر", "b": "لا",
            "n": "ى", "m": "ة", ",": "و", ".": "ز", "/": "ظ",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.he", name: "Hebrew", map: [
            "q": "/", "w": "'", "e": "ק", "r": "ר", "t": "א",
            "y": "ט", "u": "ו", "i": "ן", "o": "ם", "p": "פ",
            "a": "ש", "s": "ד", "d": "ג", "f": "כ", "g": "ע",
            "h": "י", "j": "ח", "k": "ל", "l": "ך",
            ";": "ף", "'": ",",
            "z": "ז", "x": "ס", "c": "ב", "v": "ה", "b": "נ",
            "n": "מ", "m": "צ", ",": "ת", ".": "ץ", "/": ".",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.ka", name: "Georgian", map: [
            "q": "ქ", "w": "წ", "e": "ე", "r": "რ", "t": "ტ",
            "y": "ყ", "u": "უ", "i": "ი", "o": "ო", "p": "პ",
            "a": "ა", "s": "ს", "d": "დ", "f": "ფ", "g": "გ",
            "h": "ჰ", "j": "ჯ", "k": "კ", "l": "ლ",
            "z": "ზ", "x": "ძ", "c": "ც", "v": "ვ", "b": "ბ",
            "n": "ნ", "m": "მ",
        ], isSystem: false),
        KeyboardLayout(id: "builtin.az", name: "Azerbaijani", map: turkish, isSystem: false),
        KeyboardLayout(id: "builtin.me", name: "Montenegrin", map: serbianLatin, isSystem: false),
    ]
}
