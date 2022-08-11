/*
 Some definitions useful when working with lengths (e.g. in layouts).
*/

import Foundation

fileprivate let U_LATIN_CAPITAL_LETTER_A = UnicodeScalar(0x0041)!
fileprivate let U_LATIN_CAPITAL_LETTER_Z = UnicodeScalar(0x005A)!
fileprivate let U_LATIN_CAPITAL_LETTER_a = UnicodeScalar(0x0061)!
fileprivate let U_LATIN_CAPITAL_LETTER_z = UnicodeScalar(0x007A)!

/// An enumeration to desribe a length.
public enum UnitOfLength: String, CaseIterable, CustomStringConvertible {
    
    /// big point
    case bp
    
    /// cicero
    case cc
    
    /// centimeter
    case cm
    
    /// didot point
    case dd
    
    /// decimeter
    case dm
    
    /// em
    case em
    
    /// ex
    case ex
    
    /// inch
    case `in`
    
    /// meter
    case m
    
    /// millimeter
    case mm
    
    /// micrometer
    case mu
    
    /// pica
    case pc
    
    /// point
    case pt
    
    /// scaled point
    case sp
    
    /// Get the appropriate enumeration value from a string representaion of it.
    public static func fromString(_ s: String?) -> Self? {
        return UnitOfLength.allCases.first { $0.rawValue == s }
    }
    
    /// Get the string representation for the unit.
    public var description: String {
        return rawValue
    }
    
    /// The factor when calculating the numerical centimeters value from 1 times the current unit.
    public var factorFromCentimeters: Double {
        switch self {
        case .cm: return 1
        case .in: return 2.54
        case .pt: return 0.035145980363175
        case .em: return 0.35146
        case .mm: return 0.1
        case .m:  return 100
        case .dm: return 10
        case .cc: return 0.451277994663206
        case .dd: return 0.037606499555267
        case .sp: return 0.000000535516672
        case .bp: return 0.035277848697871
        case .ex: return 0.15132
        case .mu: return 0.0001
        case .pc: return 0.421751764358102
        }
    }
}

/// Get the "cm" value from a text where a unit is used that occurs in the `UnitOfLength` enumeration.
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

/// Get the percent value from " ... % ".
public func percents(fromText _text: String?) -> Double? {
    guard let text = _text?.trim() else { return nil }
    if text.hasSuffix("%") {
        return Double(text.dropLast())
    }
    else {
        return nil
    }
}

/// Get the percent value from " ... * ".
public func relativeValues(fromText _text: String?) -> Double? {
    guard let text = _text?.trim() else { return nil }
    if text.hasSuffix("*") {
        return Double(text.dropLast())
    }
    else {
        return nil
    }
}

/// Get the textual representation for a centimeters value with a certain unit.
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
