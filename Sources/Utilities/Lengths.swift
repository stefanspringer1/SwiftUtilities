import Foundation

fileprivate let U_LATIN_CAPITAL_LETTER_A = UnicodeScalar(0x0041)!
fileprivate let U_LATIN_CAPITAL_LETTER_Z = UnicodeScalar(0x005A)!
fileprivate let U_LATIN_CAPITAL_LETTER_a = UnicodeScalar(0x0061)!
fileprivate let U_LATIN_CAPITAL_LETTER_z = UnicodeScalar(0x007A)!

public enum UnitOfLength: String, CaseIterable, CustomStringConvertible {
    
    case bp, cc, cm, dd, dm, em, ex, `in`, m, mm, mu, pc, pt, sp
    
    public static func fromString(_ s: String?) -> Self? {
        return UnitOfLength.allCases.first { $0.rawValue == s }
    }
    
    public var description: String {
        return ".\(rawValue)"
    }
    
    public var factorFromCentimeters: Double {
        switch self {
        case .cm: return 1 // centimeter
        case .in: return 2.54 // inch
        case .pt: return 0.035145980363175 // point
        case .em: return 0.35146
        case .mm: return 0.1 // millimeter
        case .m:  return 100 // meter
        case .dm: return 10 // decimeter
        case .cc: return 0.451277994663206 // cicero
        case .dd: return 0.037606499555267 // didot point
        case .sp: return 0.000000535516672 // scaled point
        case .bp: return 0.035277848697871 // big point
        case .ex: return 0.15132
        case .mu: return 0.0001 // micrometer
        case .pc: return 0.421751764358102 // pica
        }
    }
}

public func centimeters(fromText _text: String?) -> Double? {
    guard let text = _text else { return nil }
    guard let firstChar = text.unicodeScalars.first(where: { scalar in
        (scalar >= U_LATIN_CAPITAL_LETTER_a && scalar <= U_LATIN_CAPITAL_LETTER_z) ||
        (scalar >= U_LATIN_CAPITAL_LETTER_A && scalar <= U_LATIN_CAPITAL_LETTER_Z)
    }
    ) else { return nil }
    guard let firstCharIndex = text.firstIndex(of: Character(firstChar)) else { return nil }
    
    guard let number = Double(text[..<firstCharIndex].trimmingCharacters(in: .whitespaces)) else { return nil }
    
    guard let unit = UnitOfLength.fromString(text[firstCharIndex...].trimmingCharacters(in: .whitespaces)) else { return nil }
    let factor = unit.factorFromCentimeters
    
    return factor == 1 ? number : number * factor
}

public func percents(fromText _text: String?) -> Double? {
    guard let text = _text?.trim() else { return nil }
    if text.hasSuffix("%") {
        return Double(text.dropLast())
    }
    else {
        return nil
    }
}

public func relativeValues(fromText _text: String?) -> Double? {
    guard let text = _text?.trim() else { return nil }
    if text.hasSuffix("*") {
        return Double(text.dropLast())
    }
    else {
        return nil
    }
}

public func text(forCentimeters centimeters: Double, usingUnit unit: UnitOfLength? = nil, digits: Int? = nil) -> String {
    var factor: Double = 1
    var unitText = "cm"
    if let unit = unit {
        factor = unit.factorFromCentimeters
        unitText = unit.rawValue
    }
    if let digits = digits {
        return String(format: "%.\(digits)f", factor == 1 ? centimeters: centimeters / factor) + unitText
    }
    else {
        return String(format: "%.3f", factor == 1 ? centimeters: centimeters / factor) + unitText
    }
}
