import Foundation

func encoding(fromName name:  String) -> String.Encoding? {
    switch name {
    case "ascii":  .ascii
    case "iso2022JP":  .iso2022JP
    case "isoLatin1":  .isoLatin1
    case "isoLatin2":  .isoLatin2
    case "japaneseEUC":  .japaneseEUC
    case "macOSRoman":  .macOSRoman
    case "nextstep":  .nextstep
    case "nonLossyASCII":  .nonLossyASCII
    case "shiftJIS":  .shiftJIS
    case "symbol":  .symbol
    case "unicode":  .unicode
    case "utf16":  .utf16
    case "utf16BigEndian":  .utf16BigEndian
    case "utf16LittleEndian":  .utf16LittleEndian
    case "utf32":  .utf32
    case "utf32BigEndian":  .utf32BigEndian
    case "utf32LittleEndian":  .utf32LittleEndian
    case "utf8":  .utf8
    case "windowsCP1250":  .windowsCP1250
    case "windowsCP1251":  .windowsCP1251
    case "windowsCP1252":  .windowsCP1252
    case "windowsCP1253":  .windowsCP1253
    case "windowsCP1254":  .windowsCP1254
    default:  nil
    }
}
