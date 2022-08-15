/*
 Some definitions to be useful when working with characters, e.g. for characterizing them.
*/

import Foundation

/// The "CharacterClass" can be used to see to which class a character belongs to.
public enum CharacterClass: CombinedCharacterClass {
    
    case EMPTY                              = 0b00000000000000000000000000000000
    case ACCENTS                            = 0b00000000000000000000000000000001
    case COMBINING                          = 0b00000000000000000000000000000010
    case COMBINING_ABOVE                    = 0b00000000000000000000000000000100
    case COMBINING_BELOW                    = 0b00000000000000000000000000001000
    case COMBINING_MIDDLE                   = 0b00000000000000000000000000010000
    case GREEK_LETTERS                      = 0b00000000000000000000000000100000
    case LOWERCASE_GREEK_LETTERS            = 0b00000000000000000000000001000000
    case UPPERCASE_GREEK_LETTERS            = 0b00000000000000000000000010000000
    case MATHEMATICAL                       = 0b00000000000000000000000100000000
    case ROMAN                              = 0b00000000000000000000001000000000
    case ITALIC                             = 0b00000000000000000000010000000000
    case BOLD                               = 0b00000000000000000000100000000000
    case SCRIPT                             = 0b00000000000000000001000000000000
    case GOTHIC                             = 0b00000000000000000010000000000000
    case SANSSERIF                          = 0b00000000000000000100000000000000
    case MONOSPACE                          = 0b00000000000000001000000000000000
    case DOUBLE_STRUCK                      = 0b00000000000000010000000000000000
    case DIGIT                              = 0b00000000000000100000000000000000
    case LARGE_OPERATORS                    = 0b00000000000001000000000000000000
    case BINARY_OPERATIONS                  = 0b00000000000010000000000000000000
    case RELATIONS                          = 0b00000000000100000000000000000000
    case NEGATED_RELATIONS                  = 0b00000000001000000000000000000000
    case ARROWS                             = 0b00000000010000000000000000000000
    case OPENING_DELIMITERS                 = 0b00000000100000000000000000000000
    case CLOSING_DELIMITERS                 = 0b00000001000000000000000000000000
    case PUNCTUATION                        = 0b00000010000000000000000000000000
    case LEFT_RIGHT_ARROWS                  = 0b00000100000000000000000000000000
    case SPACES                             = 0b00001000000000000000000000000000
    case ALL                                = 0b11111111111111111111111111111111
    
}

public extension CharacterClass {
    var asCombinedCharacterClass: CombinedCharacterClass { self.rawValue }
}

//*****************************************************************************
// UNICODE DATA
//*****************************************************************************

/// Make an instance of `CharacterClasses` to use it.
public func getCharacterClasses() -> CharacterClasses {
    let characterClasses = CharacterClasses()

    // ------------------------------------------------------------------------
    // Combining Diacritical Marks:
    // ------------------------------------------------------------------------
    
    // ------
    // above:
    // ------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x0300...0x0315, 0x031A...0x031B, 0x033D...0x0344, 0x034A...0x034C,
            0x0350...0x0352, 0x0357...0x0358, 0x035D...0x035E, 0x0360...0x0361,
            0x0363...0x036F,
        ],
        // ---- single codepoints:
        [
            0x0346, 0x035B,
        ]
    )
        .forEach {
            characterClasses.add(.ACCENTS, .COMBINING, .COMBINING_ABOVE, toCodePoint: $0)
        }
    
    // ------
    // below:
    // ------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x0316...0x0319, 0x031C...0x0333, 0x0339...0x033C, 0x0347...0x0349,
            0x034D...0x034E, 0x0353...0x0356, 0x0359...0x035A
        ],
        // ---- single codepoints:
        [
            0x0345, 0x035C, 0x035F, 0x0362,
        ]
    )
        .forEach {
            characterClasses.add(.ACCENTS, .COMBINING, .COMBINING_BELOW, toCodePoint: $0)
        }
    
    // ------
    // middle:
    // ------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x0334...0x0338,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.ACCENTS, .COMBINING, .COMBINING_MIDDLE, toCodePoint: $0)
        }
    
    // --------------------------
    // combining grapheme joiner:
    // --------------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            // -
        ],
        // ---- single codepoints:
        [
            0x034F,
        ]
    )
        .forEach {
            characterClasses.add(.COMBINING, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Greek Letters:
    // ------------------------------------------------------------------------
    
    // ----------
    // uppercase:
    // ----------
    
    UCCodePoints(
        // ---- ranges:
        [
            // Greek:
            0x0388...0x03AB,
            
            // mathematical Greek:
            0x1D6A8...0x1D6C0, // bold
            0x1D6E2...0x1D6FA, // italic
            0x1D726...0x1D734, // bold italic
            0x1D756...0x1D76E, // sans-serif bold
            0x1D790...0x1D7A8, // sans-serif bold italic
        ],
        // ---- single codepoints:
        [
            // Greek:
            0x0370, 0x0372, 0x0376, 0x037F, 0x0386, 0x03CF, 0x03F4, 0x03F7,
            0x03F9, 0x03FA, 0x03FD, 0x03FE, 0x03FF,
            
            // mathematical Greek:
            // -
        ]
    )
        .forEach {
            characterClasses.add(.GREEK_LETTERS, .UPPERCASE_GREEK_LETTERS, toCodePoint: $0)
        }
    
    // ----------
    // lowercase:
    // ----------
    
    UCCodePoints(
        // ---- ranges:
        [
            // Greek:
            0x037B...0x037D, 0x03AC...0x03CE,
        
            // mathematical Greek:
            0x1D6C1...0x1D6E1, // bold
            0x1D6FB...0x1D71B, // italic
            0x1D735...0x1D755, // bold italic
            0x1D76F...0x1D78F, // sans-serif bold
            0x1D7A9...0x1D7C9, // sans-serif bold italic
        ],
        // ---- single codepoints:
        [
            // Greek:
            0x0371, 0x0373, 0x0377, 0x0390, 0x03D9, 0x03DB, 0x03DD, 0x03DF,
            0x03E1, 0x03F8, 0x03FB,
            
            // mathematical Greek:
            // -
        ]
    )
        .forEach {
            characterClasses.add(.GREEK_LETTERS, .LOWERCASE_GREEK_LETTERS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Mathematical Letters:
    // ------------------------------------------------------------------------
    
    // -----
    // bold:
    // -----
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D400...0x1D433,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ROMAN, toCodePoint: $0)
        }
    
    // -------
    // italic:
    // -------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D434...0x1D467,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .ITALIC, toCodePoint: $0)
        }
    
    // ------------
    // bold italic:
    // ------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D468...0x1D49B,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ITALIC, toCodePoint: $0)
        }
    
    // -------
    // script:
    // -------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D49C...0x1D4CF,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SCRIPT, toCodePoint: $0)
        }
    
    // ------------
    // bold script:
    // ------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D4D0...0x1D503,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .SCRIPT, toCodePoint: $0)
        }
    
    // -------
    // gothic:
    // -------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D504...0x1D537,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .GOTHIC, toCodePoint: $0)
        }
    
    // --------------
    // double-struck:
    // --------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D538...0x1D56B,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .DOUBLE_STRUCK, toCodePoint: $0)
        }
    
    // ------------
    // bold gothic:
    // ------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D56C...0x1D59F,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .GOTHIC, toCodePoint: $0)
        }
    
    // -----------
    // sans-serif:
    // -----------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D5A0...0x1D5D3,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .ROMAN, toCodePoint: $0)
        }
    
    // ----------------
    // sans-serif bold:
    // ----------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D5D4...0x1D607,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ROMAN, toCodePoint: $0)
        }
    
    // ------------------
    // sans-serif italic:
    // ------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D608...0x1D63B,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .ITALIC, toCodePoint: $0)
        }
    
    // -----------------------
    // sans-serif bold italic:
    // -----------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D63C...0x1D66F,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ITALIC, toCodePoint: $0)
        }
    
    // -----------------------
    // monospace:
    // -----------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D670...0x1D6A3,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .MONOSPACE, .ROMAN, toCodePoint: $0)
        }
    
    // ---------------
    // dotless italic:
    // ---------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D6A4...0x1D6A5,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .ITALIC, toCodePoint: $0)
        }
    
    // -----
    // bold:
    // -----
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D6A8...0x1D6E1,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ROMAN, toCodePoint: $0)
        }
    
    // -------
    // italic:
    // -------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D6E2...0x1D71B,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .ITALIC, toCodePoint: $0)
        }
    
    // ------------
    // bold italic:
    // ------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D71C...0x1D755,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ITALIC, toCodePoint: $0)
        }
    
    // ----------------
    // sans-serif bold:
    // ----------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D756...0x1D78F,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ROMAN, toCodePoint: $0)
        }
    
    // -----------------------
    // sans-serif bold italic:
    // -----------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D790...0x1D7C9,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ITALIC, toCodePoint: $0)
        }
    
    // -----
    // bold:
    // -----
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D7CA...0x1D7D7,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ROMAN, toCodePoint: $0)
        }
    
    // ------
    // digit:
    // ------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x0030...0x0039,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.DIGIT, toCodePoint: $0)
        }
    
    // --------------------
    // double-struck digit:
    // --------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D7D8...0x1D7E1,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .DOUBLE_STRUCK, .DIGIT, toCodePoint: $0)
        }
    
    // -----------------
    // sans-serif digit:
    // -----------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D7E2...0x1D7EB,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .DIGIT, toCodePoint: $0)
        }
    
    // ----------------------
    // sans-serif bold digit:
    // ----------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D7EC...0x1D7F5,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .DIGIT, toCodePoint: $0)
        }
    
    // ----------------
    // monospace digit:
    // ----------------
    
    UCCodePoints(
        // ---- ranges:
        [
            0x1D7F6...0x1D7FF,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.MATHEMATICAL, .MONOSPACE, .DIGIT, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Digits:
    // ------------------------------------------------------------------------
    
    // mathematical characters are added separately!
    
    UCCodePoints(
        // ---- ranges:
        [
            0x0030...0x0039,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.DIGIT, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Large Operators:
    // ------------------------------------------------------------------------
    
    UCCodePoints(
        // ---- ranges:
        [
            
            0x220F...0x2211, 0x222B...0x2233, 0x22C0...0x22C3, 0x2A00...0x2A1E,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        .forEach {
            characterClasses.add(.LARGE_OPERATORS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Binary Operations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x2020...0x2022, 0x2212...0x2213, 0x2216...0x2218, 0x2227...0x222A,
            0x2293...0x2299, 0x22B2...0x22B5, 0x22C5...0x22C6,
        ],
        // ---- single codepoints:
        [
            0x002A, 0x002B, 0x002D, 0x002F, 0x00B1, 0x00B7, 0x00D7, 0x00F7, 0x2210,
            0x2240, 0x228E, 0x25B3, 0x25B9, 0x25BD, 0x25C3, 0x25CB, 0x25EF, 0x2605,
            0x2666,
        ]
    )
        .forEach {
            characterClasses.add(.BINARY_OPERATIONS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Relations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x003C...0x003E, 0x2234...0x2235, 0x2254...0x2255, 0x2264...0x2265,
            0x226A...0x226B, 0x227A...0x227B, 0x2282...0x2283, 0x2286...0x2287,
            0x228F...0x2292, 0x22A2...0x22A3, 0x2322...0x2323,
            
        ],
        // ---- single codepoints:
        [
            0x2208, 0x220B, 0x221D, 0x2223, 0x2225, 0x2237, 0x223C, 0x2243, 0x2245,
            0x2248, 0x224D, 0x2250, 0x2257, 0x2259, 0x2261, 0x22A5, 0x22A7, 0x22C8,
            0x29BF, 0x2A74, 0x2AAF, 0x2AB0,
        ]
    )
        .forEach {
            characterClasses.add(.RELATIONS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Negated Relations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x226E...0x226F, 0x2280...0x2281, 0x2284...0x2285, 0x2288...0x2289,
            0x22E0...0x22E3, 0x2A87...0x2A88,
        ],
        // ---- single codepoints:
        [
            0x2209, 0x220C, 0x2241, 0x2244, 0x2247, 0x2249, 0x2260, 0x2262,
            0x2271,
        ]
    )
        .forEach {
            characterClasses.add(.NEGATED_RELATIONS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Arrows:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x2190...0x2199, 0x21BC...0x21BD, 0x21C0...0x21C1, 0x21D0...0x21D5,
            0x27F5...0x27FA,
        ],
        // ---- single codepoints:
        [
            0x219D, 0x21A6, 0x21A9, 0x21AA, 0x21C6, 0x21CB, 0x27FC,
        ]
    )
        .forEach {
            characterClasses.add(.ARROWS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Opening Delimiters:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x005B...0x005C, 0x005B...0x005C, 0x007B...0x007C,
        ],
        // ---- single codepoints:
        [
            0x0028, 0x002F, 0x2016, 0x2191, 0x2193, 0x2195, 0x21D1, 0x21D3,
            0x21D5, 0x2308, 0x230A, 0x23B0, 0x27E8, 0x2985, 0x300A, 0x3014,
            0x301A,
        ]
    )
        .forEach {
            characterClasses.add(.OPENING_DELIMITERS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Closing Delimiters:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x005C...0x005D, 0x007C...0x007D,
        ],
        // ---- single codepoints:
        [
            0x0029, 0x002F, 0x2016, 0x2016, 0x2191, 0x2193, 0x2195, 0x21D1, 0x21D3, 0x21D5,
            0x2309, 0x230B, 0x23B1, 0x27E9, 0x2986, 0x300B, 0x3015, 0x301B,
        ]
    )
        .forEach {
            characterClasses.add(.CLOSING_DELIMITERS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Punctuations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x0021...0x0027, 0x002C...0x002F, 0x003A...0x003B, 0x2010...0x206F, 0x2E00...0x2E52
            
            // "PUNCUATION" according to charmaps:
            /*
            0x0021...0x0027, 0x002C...0x002E, 0x003A...0x003B, 0x003F...0x0040, 0x00A1...0x00AB,
            0x00AD...0x00AE, 0x00B2...0x00B3, 0x00B5...0x00B6, 0x00B9...0x00BF, 0x2013...0x2015,
            0x2018...0x2019, 0x201C...0x201E, 0x2025...0x2026, 0x2153...0x215E, 0x2266...0x2267,
            0x22BB...0x22EF, 0x230C...0x230F, 0x2315...0x2316, 0x2591...0x2593, 0x25AD...0x25AE,
            0x25BE...0x25BF, 0x2972...0x2975, 0x29A4...0x29A5, 0x29B3...0x29B4, 0x2A23...0x2A24,
            0x2A42...0x2A43, 0x2A7D...0x2A7E, 0x2A9D...0x2A9E, 0xFB00...0xFB04,
            */
        ],
        // ---- single codepoints:
        [
            0x005C
            
            // "PUNCUATION" according to charmaps:
            /*
            0x002A, 0x005F, 0x00B0, 0x0192, 0x0308, 0x1E9E, 0x201A, 0x2030, 0x2039, 0x203A,
            0x2041, 0x2043, 0x20AC, 0x20DC, 0x2105, 0x2117, 0x211E, 0x2122, 0x2126, 0x212B,
            0x2217, 0x2236, 0x223C, 0x2242, 0x2248, 0x224A, 0x225A, 0x22F1, 0x22F7, 0x22FE,
            0x23E4, 0x2423, 0x2580, 0x2584, 0x2588, 0x25AA, 0x25B4, 0x25B8, 0x25C2, 0x25CA,
            0x260E, 0x2640, 0x2642, 0x266A, 0x2713, 0x2717, 0x2720, 0x2736, 0x2939, 0x2945,
            0x2979, 0x29B1, 0x29EB, 0x29F6, 0x2A31, 0x2A36, 0x2A5F, 0x2A6F, 0x2ABF, 0x2AC7,
            0x2AD7, 0x2AFD,
            */
        ]
    )
        .forEach {
            characterClasses.add(.PUNCTUATION, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Left-right arrows:
    // ------------------------------------------------------------------------
    
    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x21C0...0x21C1, 0x27F5...0x27FA,
        ],
        // ---- single codepoints:
        [
            0x2190, 0x2192, 0x2194, 0x219D, 0x21A6, 0x21A9, 0x21AA, 0x21BD, 0x21C6,
            0x21CB, 0x21D0, 0x21D2, 0x21D4, 0x27FC,
        ]
    )
        .forEach {
            characterClasses.add(.LEFT_RIGHT_ARROWS, toCodePoint: $0)
        }
    
    // ------------------------------------------------------------------------
    // Spaces:
    // ------------------------------------------------------------------------
    
    // TODO: might be augmented
    
    UCCodePoints(
        // ---- ranges:
        [
            0x2000...0x200B
        ],
        // ---- single codepoints:
        [
            0x0009, 0x0020, 0x000A, 0x000D, 0x0020, 0x00A0, 0x202F, 0x205F, 0x3000, 0xFEFF,
        ]
    )
        .forEach {
            characterClasses.add(.SPACES, toCodePoint: $0)
        }
    
    return characterClasses
}

//*****************************************************************************

public class CharacterClasses {
    var combinedClasses = [UCCodePoint:CombinedCharacterClass]()
    
    func add(_ classes: CharacterClass..., toCodePoint codePoint: UCCodePoint) {
        var combinedClass = combinedClasses[codePoint] ?? 0
        classes.forEach { combinedClass |= $0.rawValue }
        combinedClasses[codePoint] = combinedClass
    }
    
    public subscript(scalar: Unicode.Scalar) -> CombinedCharacterClass {
        get {
            combinedClasses[scalar.value] ?? CharacterClass.EMPTY.asCombinedCharacterClass
        }
    }
}

public struct UCCodePoints {
    
    public let ranges: [ClosedRange<UInt32>]
    public let singles: [UInt32]

    init(_ ranges: [ClosedRange<UInt32>], _ singles: [UInt32]) {
        self.ranges = ranges
        self.singles = singles
    }
    
    func forEach(operation: (UInt32) -> ()) {
        ranges.forEach { for single in $0 { operation(single) } }
        singles.forEach(operation)
    }
}

public typealias UCCodePoint = UInt32

public typealias CombinedCharacterClass = UInt32

public extension CombinedCharacterClass {
    
    func contains(_ characterClass: CharacterClass) -> Bool {
        return self & characterClass.rawValue > 0
    }
    
    func contains(_ combinedCharacterClass: CombinedCharacterClass) -> Bool {
        return self & combinedCharacterClass > 0
    }
}

public extension CharacterClass {
    static func || (left: CharacterClass, right: CharacterClass) -> CombinedCharacterClass {
        return left.rawValue | right.rawValue
    }
}

public extension String {
    
    func isGreek(usingCharacterClasses characterClasses: CharacterClasses) -> Bool {
        return self.unicodeScalars.allSatisfy { characterClasses[$0].contains(.GREEK_LETTERS) }
    }
    
    func isUppercaseGreek(usingCharacterClasses characterClasses: CharacterClasses) -> Bool {
        return self.unicodeScalars.allSatisfy { characterClasses[$0].contains(.UPPERCASE_GREEK_LETTERS) }
    }
    
    func isLowercaseGreek(usingCharacterClasses characterClasses: CharacterClasses) -> Bool {
        return self.unicodeScalars.allSatisfy { characterClasses[$0].contains(.LOWERCASE_GREEK_LETTERS) }
    }
    
}

public extension UnicodeScalar {
    
    /// Check if a character is part of the Private Use Areas of Unicode.
    var isPrivateUse: Bool {
        get { self.value >= 0xE000 && self.value <= 0xF8FF }
    }
    
}

public let U_LATIN_CAPITAL_LETTER_A = UnicodeScalar(0x0041)!
public let U_LATIN_CAPITAL_LETTER_Z = UnicodeScalar(0x005A)!
public let U_LATIN_CAPITAL_LETTER_a = UnicodeScalar(0x0061)!
public let U_LATIN_CAPITAL_LETTER_z = UnicodeScalar(0x007A)!

public let U_LEFT_CURLY_BRACKET = UnicodeScalar(0x007B)!
public let U_RIGHT_CURLY_BRACKET = UnicodeScalar(0x007D)!

public let GREEK_LETTER_RANGE = "\u{0391}-\u{03C9}"

public let MATH_GREEK_RANGE = "\u{1D6A8}-\u{1D7C9}"

public let ALL_GREEK_REGEX = "^[" +  GREEK_LETTER_RANGE + "|" + MATH_GREEK_RANGE + #"]*$"#

public let U_GREEK_CAPITAL_LETTER_SIGMA = UnicodeScalar(0x03A3)!
public let U_MATHEMATICAL_ITALIC_CAPITAL_SIGMA = UnicodeScalar(0x1D6F4)!
public let U_N_ARY_SUMMATION = UnicodeScalar(0x2211)!

public let U_GREEK_CAPITAL_LETTER_PI = UnicodeScalar(0x03A0)!
public let U_MATHEMATICAL_ITALIC_CAPITAL_PI = UnicodeScalar(0x1D6F1)!
public let U_N_ARY_PRODUCT = UnicodeScalar(0x220F)!

public let U_GREEK_CAPITAL_LETTER_ALPHA = UnicodeScalar(0x0391)!
public let U_GREEK_CAPITAL_LETTER_BETA = UnicodeScalar(0x0392)!
public let U_GREEK_CAPITAL_LETTER_ETA = UnicodeScalar(0x0397)!
public let U_GREEK_CAPITAL_LETTER_EPSILON = UnicodeScalar(0x0395)!
public let U_GREEK_CAPITAL_LETTER_IOTA = UnicodeScalar(0x0399)!
public let U_GREEK_CAPITAL_LETTER_KAPPA = UnicodeScalar(0x039A)!
public let U_GREEK_CAPITAL_LETTER_CHI = UnicodeScalar(0x03A7)!
public let U_GREEK_CAPITAL_LETTER_MU = UnicodeScalar(0x039C)!
public let U_GREEK_CAPITAL_LETTER_NU = UnicodeScalar(0x039D)!
public let U_GREEK_CAPITAL_LETTER_OMICRON = UnicodeScalar(0x039F)!
public let U_GREEK_SMALL_LETTER_OMICRON = UnicodeScalar(0x03BF)!
public let U_GREEK_CAPITAL_LETTER_RHO = UnicodeScalar(0x03A1)!
public let U_GREEK_CAPITAL_LETTER_TAU = UnicodeScalar(0x03C4)!
public let U_GREEK_CAPITAL_LETTER_UPSILON = UnicodeScalar(0x03A5)!
public let U_GREEK_CAPITAL_LETTER_ZETA = UnicodeScalar(0x0396)!

public let U_VULGAR_FRACTION_ONE_QUARTER = UnicodeScalar(0x00BC)!
public let U_VULGAR_FRACTION_ONE_HALF = UnicodeScalar(0x00BD)!
public let U_VULGAR_FRACTION_THREE_QUARTERS = UnicodeScalar(0x00BE)!

public let U_PRIME = UnicodeScalar(0x2032)!
public let U_DOUBLE_PRIME = UnicodeScalar(0x2033)!
public let U_TRIPLE_PRIME = UnicodeScalar(0x2034)!
public let U_QUADRUPLE_PRIME = UnicodeScalar(0x2057)!

public let U_VULGAR_FRACTION_ONE_SEVENTH = UnicodeScalar(0x2150)!
public let U_VULGAR_FRACTION_ONE_NINTH = UnicodeScalar(0x2151)!
public let U_VULGAR_FRACTION_ONE_TENTH = UnicodeScalar(0x2152)!
public let U_VULGAR_FRACTION_ONE_THIRD = UnicodeScalar(0x2153)!
public let U_VULGAR_FRACTION_TWO_THIRDS = UnicodeScalar(0x2154)!
public let U_VULGAR_FRACTION_ONE_FIFTH = UnicodeScalar(0x2155)!
public let U_VULGAR_FRACTION_TWO_FIFTHS = UnicodeScalar(0x2156)!
public let U_VULGAR_FRACTION_THREE_FIFTHS = UnicodeScalar(0x2157)!
public let U_VULGAR_FRACTION_FOUR_FIFTHS = UnicodeScalar(0x2158)!
public let U_VULGAR_FRACTION_ONE_SIXTH = UnicodeScalar(0x2159)!
public let U_VULGAR_FRACTION_FIVE_SIXTHS = UnicodeScalar(0x215A)!
public let U_VULGAR_FRACTION_ONE_EIGHTH = UnicodeScalar(0x215B)!
public let U_VULGAR_FRACTION_THREE_EIGHTHS = UnicodeScalar(0x215C)!
public let U_VULGAR_FRACTION_FIVE_EIGHTHS = UnicodeScalar(0x215D)!
public let U_VULGAR_FRACTION_SEVEN_EIGHTHS = UnicodeScalar(0x215E)!

public let U_LATIN_SMALL_LIGATURE_FF = UnicodeScalar(0xFB00)!
public let U_LATIN_SMALL_LIGATURE_FI = UnicodeScalar(0xFB01)!
public let U_LATIN_SMALL_LIGATURE_FL = UnicodeScalar(0xFB02)!
public let U_LATIN_SMALL_LIGATURE_FFI = UnicodeScalar(0xFB03)!
public let U_LATIN_SMALL_LIGATURE_FFL = UnicodeScalar(0xFB04)!
public let U_LATIN_SMALL_LIGATURE_LONG_S_T = UnicodeScalar(0xFB05)!
public let U_LATIN_SMALL_LIGATURE_ST = UnicodeScalar(0xFB06)!
public let U_PRIVATE_USE_LATIN_SMALL_LIGATURE_FJ = UnicodeScalar(0xE06C)!