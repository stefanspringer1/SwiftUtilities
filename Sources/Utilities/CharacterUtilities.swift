/*
 Some definitions to be useful when working with characters, e.g. for characterizing them.
*/

import Foundation

/// The "CharacterClass" can be used to see to which class a character belongs to.
public enum CharacterClass: CombinedCharacterClass, CaseIterable {
    
    case EMPTY                 = 0b00000000000000000000000000000000
    case CAPITAL_LATIN_LETTERS = 0b00000000000000000000000000000001
    case SMALL_LATIN_LETTERS   = 0b00000000000000000000000000000010
    case LATIN_LETTERS         = 0b00000000000000000000000000000011 // do not insert characters directly into this class, use SMALL_LATIN_LETTERS or CAPITAL_LATIN_LETTERS
    case COMBINING_ABOVE       = 0b00000000000000000000000000000100
    case COMBINING_BELOW       = 0b00000000000000000000000000001000
    case COMBINING_MIDDLE      = 0b00000000000000000000000000010000
    case COMBINING             = 0b00000000000000000000000000011100 // do not insert characters directly into this class, use COMBINING_ABOVE, COMBINING_BELOW, or COMBINING_MIDDLE
    case ISO_8859_1            = 0b00000000000000000000000000100000
    case CAPITAL_GREEK_LETTERS = 0b00000000000000000000000001000000
    case SMALL_GREEK_LETTERS   = 0b00000000000000000000000010000000
    case GREEK_LETTERS         = 0b00000000000000000000000011000000 // do not insert characters directly into this class, use SMALL_GREEK_LETTERS or CAPITAL_GREEK_LETTERS
    case MATHEMATICAL          = 0b00000000000000000000000100000000
    case ROMAN                 = 0b00000000000000000000001000000000
    case ITALIC                = 0b00000000000000000000010000000000
    case BOLD                  = 0b00000000000000000000100000000000
    case SCRIPT                = 0b00000000000000000001000000000000
    case GOTHIC                = 0b00000000000000000010000000000000
    case SANSSERIF             = 0b00000000000000000100000000000000
    case MONOSPACE             = 0b00000000000000001000000000000000
    case DOUBLE_STRUCK         = 0b00000000000000010000000000000000
    case DIGIT                 = 0b00000000000000100000000000000000
    case LARGE_OPERATORS       = 0b00000000000001000000000000000000
    case BINARY_OPERATIONS     = 0b00000000000010000000000000000000
    case RELATIONS             = 0b00000000000100000000000000000000
    case NEGATED_RELATIONS     = 0b00000000001000000000000000000000
    case ARROWS                = 0b00000000010000000000000000000000
    case OPENING_DELIMITERS    = 0b00000000100000000000000000000000
    case CLOSING_DELIMITERS    = 0b00000001000000000000000000000000
    case PUNCTUATION           = 0b00000010000000000000000000000000
    case LEFT_RIGHT_ARROWS     = 0b00000100000000000000000000000000
    case CYRILLIC              = 0b00001000000000000000000000000000
    case ACCENTED              = 0b00010000000000000000000000000000
    case TRIVIAL_SPACES        = 0b00100000000000000000000000000000
    case NONTRIVIAL_SPACES     = 0b01000000000000000000000000000000
    case SPACES                = 0b01100000000000000000000000000000 // do not insert characters directly into this class, use TRIVIAL_SPACES or NONTRIVIAL_SPACES
    case ARBORTEXT_SPACE_BUG   = 0b10000000000000000000000000000000 // the Arbortext editor falsely sets a space between those characters and a combining character
    case ALL                   = 0b11111111111111111111111111111111

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
    // Latin Letters:
    // ------------------------------------------------------------------------
    
    // --------
    // capital:
    // --------
    
    let capitalLatinLetters = UCCodePoints(
        // ---- ranges:
        [
            0x0041...0x005A,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    capitalLatinLetters.forEach {
        characterClasses.add(.CAPITAL_LATIN_LETTERS, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.CAPITAL_LATIN_LETTERS] = capitalLatinLetters
    
    // ------
    // small:
    // ------
    
    let smallLatinLetters = UCCodePoints(
        // ---- ranges:
        [
            0x0061...0x007A,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    smallLatinLetters.forEach {
        characterClasses.add(.SMALL_LATIN_LETTERS, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.SMALL_LATIN_LETTERS] = smallLatinLetters
    
    // ------------------
    // all Latin letters:
    // ------------------
    
    characterClasses.codePoints[.LATIN_LETTERS] = smallLatinLetters + capitalLatinLetters
    
    // ------------------------------------------------------------------------
    // Combining Diacritical Marks:
    // ------------------------------------------------------------------------
    
    // ------
    // above:
    // ------
    
    let combiningAbove = UCCodePoints(
        // ---- ranges:
        [
            0x0300...0x0315, 0x031A...0x031B, 0x033D...0x0344, 0x034A...0x034C,
            0x0350...0x0352, 0x0357...0x0358, 0x035D...0x035E, 0x0360...0x0361,
            0x0363...0x036F, 0x0483...0x0487, 0x2DE0...0x2DFF, 0xA674...0xA67D,
            0xFE20...0xFE26, 0xFE2E...0xFE2F, 0xA69E...0xA69E,
        ],
        // ---- single codepoints:
        [
            0x20DB, 0x20DC, 0x0346, 0x035B, 0xA66F, 0x1E08F,
        ]
    )
    
    combiningAbove.forEach {
        characterClasses.add(.COMBINING_ABOVE, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.COMBINING_ABOVE] = combiningAbove
    
    // ------
    // below:
    // ------
    
    let combiningBelow = UCCodePoints(
        // ---- ranges:
        [
            0x0316...0x0319, 0x031C...0x0333, 0x0339...0x033C, 0x0347...0x0349,
            0x034D...0x034E, 0x0353...0x0356, 0x0359...0x035A, 0xFE27...0xFE2D,
        ],
        // ---- single codepoints:
        [
            0x0345, 0x035C, 0x035F, 0x0362,
        ]
    )
    
    combiningBelow.forEach {
        characterClasses.add(.COMBINING_BELOW, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.COMBINING_BELOW] = combiningBelow
    
    // ------
    // middle:
    // ------
    
    let combiningMiddle = UCCodePoints(
        // ---- ranges:
        [
            0x0334...0x0338, 0x0488...0x0489, 0xA670...0xA672,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    combiningMiddle.forEach {
        characterClasses.add(.COMBINING_MIDDLE, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.COMBINING_MIDDLE] = combiningMiddle
    
    // --------------
    // all combining:
    // --------------
    
    characterClasses.codePoints[.COMBINING] = combiningAbove + combiningBelow + combiningMiddle
    
    // ------------------------------------------------------------------------
    // ISO 8859-1:
    // ------------------------------------------------------------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x0020...0x007E, 0x00A0...0x00FF,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.ISO_8859_1, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.ISO_8859_1] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // Greek Letters:
    // ------------------------------------------------------------------------
    
    // --------
    // capital:
    // --------
    
    let capitalGreek = UCCodePoints(
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
            0x0370, 0x0372, 0x0376, 0x037F, 0x0386, 0x03CF, 0x03DC, 0x03F4,
            0x03F7, 0x03F9, 0x03FA, 0x03FD, 0x03FE, 0x03FF,
            
            // mathematical Greek:
            // -
        ]
    )
    
    capitalGreek.forEach {
        characterClasses.add(.CAPITAL_GREEK_LETTERS, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.CAPITAL_GREEK_LETTERS] = capitalGreek
    
    // ------
    // small:
    // ------
    
    let smallGreek = UCCodePoints(
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
            0x0371, 0x0373, 0x0377, 0x0390, 0x03D5, 0x03D9, 0x03DB, 0x03DD,
            0x03DF, 0x03E1, 0x03F8, 0x03FB,
            
            // mathematical Greek:
            // -
        ]
    )
    
    smallGreek.forEach {
        characterClasses.add(.SMALL_GREEK_LETTERS, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.SMALL_GREEK_LETTERS] = smallGreek
    
    // ----------
    // all Greek:
    // ----------
    
    characterClasses.codePoints[.GREEK_LETTERS] = capitalGreek + smallGreek
    
    // ------------------------------------------------------------------------
    // Mathematical Letters:
    // ------------------------------------------------------------------------
    
    // -----
    // bold:
    // -----
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D400...0x1D433,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ROMAN, toCodePoint: $0)
        }
    }
    
    // -------
    // italic:
    // -------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D434...0x1D467,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .ITALIC, toCodePoint: $0)
        }
    }
    
    // ------------
    // bold italic:
    // ------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D468...0x1D49B,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ITALIC, toCodePoint: $0)
        }
    }
    
    // -------
    // script:
    // -------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D49C...0x1D4CF,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SCRIPT, toCodePoint: $0)
        }
    }
    
    // ------------
    // bold script:
    // ------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D4D0...0x1D503,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .SCRIPT, toCodePoint: $0)
        }
    }
    
    // -------
    // gothic:
    // -------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D504...0x1D537,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .GOTHIC, toCodePoint: $0)
        }
    }
    
    // --------------
    // double-struck:
    // --------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D538...0x1D56B,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .DOUBLE_STRUCK, toCodePoint: $0)
        }
    }
    
    // ------------
    // bold gothic:
    // ------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D56C...0x1D59F,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .GOTHIC, toCodePoint: $0)
        }
    }
    
    // -----------
    // sans-serif:
    // -----------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D5A0...0x1D5D3,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .ROMAN, toCodePoint: $0)
        }
    }
    
    // ----------------
    // sans-serif bold:
    // ----------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D5D4...0x1D607,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ROMAN, toCodePoint: $0)
        }
    }
    
    // ------------------
    // sans-serif italic:
    // ------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D608...0x1D63B,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .ITALIC, toCodePoint: $0)
        }
    }
    
    // -----------------------
    // sans-serif bold italic:
    // -----------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D63C...0x1D66F,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ITALIC, toCodePoint: $0)
        }
    }
    
    // -----------------------
    // monospace:
    // -----------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D670...0x1D6A3,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .MONOSPACE, .ROMAN, toCodePoint: $0)
        }
    }
    
    // ---------------
    // dotless italic:
    // ---------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D6A4...0x1D6A5,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .ITALIC, toCodePoint: $0)
        }
    }
    
    // -----
    // bold:
    // -----
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D6A8...0x1D6E1,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ROMAN, toCodePoint: $0)
        }
    }
    
    // -------
    // italic:
    // -------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D6E2...0x1D71B,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .ITALIC, toCodePoint: $0)
        }
    }
    
    // ------------
    // bold italic:
    // ------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D71C...0x1D755,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ITALIC, toCodePoint: $0)
        }
    }
    
    // ----------------
    // sans-serif bold:
    // ----------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D756...0x1D78F,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ROMAN, toCodePoint: $0)
        }
    }
    
    // -----------------------
    // sans-serif bold italic:
    // -----------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D790...0x1D7C9,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .ITALIC, toCodePoint: $0)
        }
    }
    
    // -----
    // bold:
    // -----
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x1D7CA...0x1D7D7,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.MATHEMATICAL, .BOLD, .ROMAN, toCodePoint: $0)
        }
    }
    
    // ------
    // digit:
    // ------
    
    let digits = UCCodePoints(
        // ---- ranges:
        [
            0x0030...0x0039,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    digits.forEach {
        characterClasses.add(.DIGIT, toCodePoint: $0)
    }
    
    // --------------------
    // double-struck digit:
    // --------------------
    
    let doubleStruckDigits = UCCodePoints(
        // ---- ranges:
        [
            0x1D7D8...0x1D7E1,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    doubleStruckDigits.forEach {
        characterClasses.add(.MATHEMATICAL, .DOUBLE_STRUCK, .DIGIT, toCodePoint: $0)
    }
    
    // -----------------
    // sans-serif digit:
    // -----------------
    
    let sansSerifDigits = UCCodePoints(
        // ---- ranges:
        [
            0x1D7E2...0x1D7EB,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    sansSerifDigits.forEach {
        characterClasses.add(.MATHEMATICAL, .SANSSERIF, .DIGIT, toCodePoint: $0)
    }
    
    // ----------------------
    // sans-serif bold digit:
    // ----------------------
    
    let sansSerifBoldDigits = UCCodePoints(
        // ---- ranges:
        [
            0x1D7EC...0x1D7F5,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
    
    sansSerifBoldDigits.forEach {
        characterClasses.add(.MATHEMATICAL, .SANSSERIF, .BOLD, .DIGIT, toCodePoint: $0)
    }
    
    // ----------------
    // monospace digit:
    // ----------------
    
    let monospaceDigits = UCCodePoints(
        // ---- ranges:
        [
            0x1D7F6...0x1D7FF,
        ],
        // ---- single codepoints:
        [
            // -
        ]
    )
        
    monospaceDigits.forEach {
        characterClasses.add(.MATHEMATICAL, .MONOSPACE, .DIGIT, toCodePoint: $0)
    }
    
    // ----------------
    // all digits:
    // ----------------
    
    characterClasses.codePoints[.DIGIT] = digits + doubleStruckDigits + sansSerifDigits + sansSerifBoldDigits + monospaceDigits
    
    // ------------------------------------------------------------------------
    // large operators:
    // ------------------------------------------------------------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x220F...0x2211, 0x222B...0x2233, 0x22C0...0x22C3, 0x2A00...0x2A1E,
            ],
            // ---- single codepoints:
            [
                // -
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.LARGE_OPERATORS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.LARGE_OPERATORS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // binary operations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.BINARY_OPERATIONS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.BINARY_OPERATIONS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // relations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.RELATIONS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.RELATIONS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // negated relations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.NEGATED_RELATIONS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.NEGATED_RELATIONS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // arrows:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.ARROWS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.ARROWS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // opening delimiters:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.OPENING_DELIMITERS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.OPENING_DELIMITERS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // closing delimiters:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.CLOSING_DELIMITERS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.CLOSING_DELIMITERS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // punctuations:
    // ------------------------------------------------------------------------

    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x0021...0x0027, 0x002C...0x002F, 0x003A...0x003B, 0x2010...0x206F, 0x2E00...0x2E52,
                
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
                0x005C,
                
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
        
        codePoints.forEach {
            characterClasses.add(.PUNCTUATION, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.PUNCTUATION] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // left-right arrows:
    // ------------------------------------------------------------------------
    
    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
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
        
        codePoints.forEach {
            characterClasses.add(.LEFT_RIGHT_ARROWS, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.LEFT_RIGHT_ARROWS] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // trivial spaces:
    // ------------------------------------------------------------------------
    
    let trivialSpaces = UCCodePoints(
        // ---- ranges:
        [
            // -
        ],
        // ---- single codepoints:
        [
            0x0009, 0x0020, 0x000A, 0x000D, 0x0020,
        ]
    )
    
    trivialSpaces.forEach {
        characterClasses.add(.TRIVIAL_SPACES, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.TRIVIAL_SPACES] = trivialSpaces
    
    // ------------------------------------------------------------------------
    // non-trivial spaces:
    // ------------------------------------------------------------------------
    
    // TODO: might be augmented
    
    let nontrivialSpaces = UCCodePoints(
        // ---- ranges:
        [
            0x2000...0x200B,
        ],
        // ---- single codepoints:
        [
            0x00A0, 0x202F, 0x205F, 0x3000, 0xFEFF,
        ]
    )
    
    nontrivialSpaces.forEach {
        characterClasses.add(.NONTRIVIAL_SPACES, toCodePoint: $0)
    }
    
    characterClasses.codePoints[.NONTRIVIAL_SPACES] = nontrivialSpaces
    
    // ------------------------------------------------------------------------
    // all spaces:
    // ------------------------------------------------------------------------
    
    characterClasses.codePoints[.SPACES] = trivialSpaces + nontrivialSpaces
    
    // ------------------------------------------------------------------------
    // cyrillic:
    // ------------------------------------------------------------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x0400...0x0482, 0x048A...0x04FF, 0x0500...0x052F, 0xA640...0xA66E, 0xA67E...0xA69D, 0x1C80...0x1C88, 0x1E030...0x1E06D,
            ],
            // ---- single codepoints:
            [
                0x1D2B, 0x1D78, 0xA673,
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.CYRILLIC, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.CYRILLIC] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // accented:
    // ------------------------------------------------------------------------
    
    // TODO: might be augmented
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                // accented Latin letters:
                0x0100...0x024F,
                
                // accented Greek letters:
                0x0388...0x0390, 0x03AA...0x03B0, 0x03CA...0x03CE, 0x03D3...0x03D4,
                
                // accented Cyrillic letters:
                0x0400...0x0403, 0x0450...0x0453, 0x045C...0x045E, 0x046E...0x046F, 0x0467...0x0477, 0x047C...0x047F,
                0x048A...0x048B, 0x04D0...0x04D3, 0x04D6...0x04D7, 0x04D4...0x04DF, 0x04E2...0x04E7, 0x04E4...0x04FF
            ],
            // ---- single codepoints:
            [
                // accented Greek letters:
                0x0386, 0x0407,
                
                // accented Cyrillic letters:
                0x0457,
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.ACCENTED, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.ACCENTED] = codePoints
    }
    
    // ------------------------------------------------------------------------
    // Arbortext space bug:
    // ------------------------------------------------------------------------
    
    do {
        let codePoints = UCCodePoints(
            // ---- ranges:
            [
                0x0100...0x0113, 0x0116...0x0122, 0x0124...0x012B, 0x012E...0x014D, 0x0150...0x0151, 0x0154...0x015F, 0x0162...0x0177,
                0x0179...0x017C, 0x0391...0x03A1, 0x03A3...0x03A9, 0x03B1...0x03C9, 0x03D1...0x03D2, 0x03D5...0x03D6, 0x03DC...0x03DD,
                0x03F0...0x03F1, 0x03F5...0x03F6, 0x0410...0x044F, 0x2002...0x2005, 0x2007...0x200A, 0x2015...0x2016, 0x2018...0x2019,
                0x2025...0x2026, 0x2031...0x2035, 0x210A...0x210D, 0x210F...0x2113, 0x2115...0x211E, 0x2126...0x2129, 0x212B...0x212D,
                0x212F...0x2131, 0x2133...0x2138, 0x2153...0x215E, 0x2190...0x219B, 0x219D...0x21A3, 0x21A9...0x21AE, 0x21B0...0x21B3,
                0x21B6...0x21B7, 0x21BA...0x21DB, 0x21FD...0x2205, 0x2207...0x2209, 0x220B...0x220C, 0x220F...0x2214, 0x2217...0x2218,
                0x221D...0x2238, 0x223A...0x223E, 0x2240...0x2257, 0x2259...0x225A, 0x225F...0x2262, 0x2264...0x226C, 0x226E...0x228B,
                0x228D...0x229B, 0x229D...0x22A5, 0x22A7...0x22B0, 0x22B2...0x22DB, 0x22DE...0x22E3, 0x22E6...0x22F7, 0x22F9...0x22FE,
                0x2308...0x2310, 0x2312...0x2313, 0x2315...0x2316, 0x231C...0x231F, 0x2322...0x2323, 0x232D...0x232E, 0x23B0...0x23B1,
                0x23B4...0x23B6, 0x23E6...0x23E7, 0x2591...0x2593, 0x25A0...0x25A1, 0x25AD...0x25AE, 0x25B3...0x25B5, 0x25B8...0x25B9,
                0x25BD...0x25BF, 0x25C2...0x25C3, 0x25CA...0x25CB, 0x25F8...0x25FA, 0x2605...0x2606, 0x2665...0x2666, 0x266D...0x266F,
                0x27E8...0x27E9, 0x27F5...0x27FA, 0x2902...0x2905, 0x290C...0x2911, 0x2919...0x2920, 0x2923...0x292A, 0x2935...0x2939,
                0x293C...0x293D, 0x2948...0x294B, 0x2962...0x296F, 0x2971...0x2976, 0x2978...0x2979, 0x297B...0x297F, 0x2985...0x2986,
                0x298B...0x2996, 0x299C...0x299D, 0x29A4...0x29B7, 0x29BB...0x29BC, 0x29BE...0x29C5, 0x29CD...0x29CE, 0x29DC...0x29DE,
                0x29E3...0x29E5, 0x2A00...0x2A02, 0x2A0C...0x2A0D, 0x2A10...0x2A17, 0x2A22...0x2A27, 0x2A29...0x2A2A, 0x2A2D...0x2A2E,
                0x2A30...0x2A31, 0x2A33...0x2A3C, 0x2A42...0x2A4D, 0x2A53...0x2A58, 0x2A5A...0x2A5F, 0x2A6D...0x2A74, 0x2A77...0x2A9A,
                0x2A9D...0x2AA0, 0x2AA4...0x2AB0, 0x2AB3...0x2AC8, 0x2ACB...0x2ACC, 0x2ACF...0x2ADB, 0x2AE6...0x2AE9, 0x2AEB...0x2AF3,
                0x300A...0x300B, 0x3014...0x3015, 0x3018...0x301B, 0xE069...0xE06C, 0xE06E...0xE081, 0xFB00...0xFB04, 0x1D49E...0x1D49F,
                0x1D4A5...0x1D4A6, 0x1D4A9...0x1D4AC, 0x1D4AE...0x1D4B9, 0x1D4BD...0x1D4C3, 0x1D4C5...0x1D4CF, 0x1D504...0x1D505,
                0x1D507...0x1D50A, 0x1D50D...0x1D514, 0x1D516...0x1D51C, 0x1D51E...0x1D539, 0x1D53B...0x1D53E, 0x1D540...0x1D544,
                0x1D54A...0x1D550,
                
                // mathematical italic Greek:
                0x1D6E2...0x1D71B,
                
                // MATHEMATICAL ITALIC SMALL DOTLESS ...:
                0x1D6A4...0x1D6A5,
                
                // private use:
                0xE000...0xF8FF, 0xF0000...0xFFFFD, 0x100000...0x10FFFD,
            ],
            // ---- single codepoints:
            [
                0x0027, 0x003E, 0x00A0, 0x00BD, 0x01B5, 0x01F5, 0x0401, 0x0451, 0x1E9E, 0x2013, 0x201C, 0x202F, 0x0237, 0x2041, 0x2043,
                0x204F, 0x2057, 0x2102, 0x2105, 0x2124, 0x21A6, 0x21DD, 0x21F5, 0x221A, 0x225C, 0x2300, 0x2336, 0x233D, 0x233F, 0x237C,
                0x2396, 0x23E2, 0x2423, 0x24C8, 0x2580, 0x2584, 0x2588, 0x25AA, 0x25B1, 0x25EC, 0x25EF, 0x260E, 0x2640, 0x2642, 0x2660,
                0x2663, 0x266A, 0x2713, 0x2717, 0x2720, 0x2736, 0x27C2, 0x27FC, 0x27FF, 0x2916, 0x2933, 0x2945, 0x299A, 0x29B9, 0x29C9,
                0x29DA, 0x29EB, 0x29F6, 0x2A04, 0x2A06, 0x2A40, 0x2A50, 0x2A66, 0x2A6A, 0x2AE4, 0x2AFD, 0xE905, 0xFE68, 0x1D49C,
                0x1D4A2, 0x1D4BB, 0x1D546,
            ]
        )
        
        codePoints.forEach {
            characterClasses.add(.ARBORTEXT_SPACE_BUG, toCodePoint: $0)
        }
        
        characterClasses.codePoints[.ARBORTEXT_SPACE_BUG] = codePoints
    }
    
    return characterClasses
}

//*****************************************************************************

public class CharacterClasses {
    var combinedClasses = [UCCodePoint:CombinedCharacterClass]()
    var codePoints = [CharacterClass:UCCodePoints]()
    var classLiterals = [CharacterClass:String]()
    
    public func classLiteral(forCharacterClass characterClass: CharacterClass) -> String {
        return classLiterals[characterClass] ?? {
            let literal = "\\{\(String(describing: characterClass))}"
            classLiterals[characterClass] = literal
            return literal
        }()
    }
    
    public func replaceClasses(inRegex _regex: String) -> String {
        var regex = _regex
        for characterClass in CharacterClass.allCases {
            regex = regex.replacingOccurrences(of: classLiteral(forCharacterClass: characterClass), with: codePoints[characterClass]?.regex ?? "")
        }
        return regex
    }
    
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
    
    public func codePoints(forClass theClass: CharacterClass) -> UCCodePoints? {
        return codePoints[theClass]
    }
}

final public class UCCodePoints {
    
    public let ranges: [ClosedRange<UInt32>]
    public let singles: [UInt32]
    private var _regex: String? = nil

    init(_ ranges: [ClosedRange<UInt32>], _ singles: [UInt32]) {
        self.ranges = ranges
        self.singles = singles
    }
    
    public var regex: String {
        return _regex ?? {
            var ss = [String]()
            ranges.forEach { range in ss.append("\\x{\(String(format:"%X", range.lowerBound))}-\\x{\(String(format:"%X", range.upperBound))}") }
            singles.forEach { single in ss.append("\\x{\(String(format:"%X", single))}") }
            let theRegex = ss.joined()
            _regex = theRegex
            return theRegex
        }()
    }
    
    func forEach(operation: (UInt32) -> ()) {
        ranges.forEach { for single in $0 { operation(single) } }
        singles.forEach(operation)
    }
    
    public static func +(lhs: UCCodePoints, rhs: UCCodePoints) -> UCCodePoints {
        UCCodePoints(lhs.ranges + rhs.ranges, lhs.singles + rhs.singles)
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
    
    func isCapitalGreek(usingCharacterClasses characterClasses: CharacterClasses) -> Bool {
        return self.unicodeScalars.allSatisfy { characterClasses[$0].contains(.CAPITAL_GREEK_LETTERS) }
    }
    
    func isSmallGreek(usingCharacterClasses characterClasses: CharacterClasses) -> Bool {
        return self.unicodeScalars.allSatisfy { characterClasses[$0].contains(.SMALL_GREEK_LETTERS) }
    }
    
    func isRelation(usingCharacterClasses characterClasses: CharacterClasses) -> Bool {
        let scalars = self.unicodeScalars
        return scalars.count == 1 && characterClasses[scalars.first!].contains(.RELATIONS || .NEGATED_RELATIONS)
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
public let U_LATIN_SMALL_LETTER_A = UnicodeScalar(0x0061)!
public let U_LATIN_SMALL_LETTER_Z = UnicodeScalar(0x007A)!

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
public let U_REVERSED_PRIME = UnicodeScalar(0x2035)!

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
