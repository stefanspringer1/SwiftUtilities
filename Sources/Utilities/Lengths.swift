/*
 Some definitions useful when working with lengths (e.g. in layouts).
*/

import Foundation

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
    public static func fromText(_ s: String?) -> Self? {
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

/// Get number and unit from a textual length value.
public func numberAndUnitTexts(fromText _text: String?) -> (number: Substring, unit: Substring?)? {
    guard let text = _text?.trimming() else { return nil }
    if Double(text) != nil { return (number: text, unit: nil) }
    guard let firstChar = text.unicodeScalars.first(where: { scalar in
        (scalar >= U_LATIN_SMALL_LETTER_A && scalar <= U_LATIN_SMALL_LETTER_Z) ||
        (scalar >= U_LATIN_CAPITAL_LETTER_A && scalar <= U_LATIN_CAPITAL_LETTER_Z)
    }) else { return nil }
    guard let firstCharIndex = text.firstIndex(of: Character(firstChar)) else { return nil }
    
    let number = text[..<firstCharIndex].trimming()
    let unit = text[firstCharIndex...].trimming()
    
    return (number: number, unit: unit)
}

/// Normalize length number.
public func normalizeLengthNumber(inText text: String?, withDecimalPlacesForUnit: [String:Int]) -> String? {
    guard let (number: numberText, unit: unitText) = numberAndUnitTexts(fromText: text),
          let unitText, let numberOfDecimalPlaces = withDecimalPlacesForUnit[String(unitText)] else { return text }
    let numberParts = numberText.split(separator: ".")
    guard numberParts.count == 2 else { return "\(numberText).\(String(repeating: "0", count: numberOfDecimalPlaces))\(unitText)" }
    var decimalPlaces = numberParts[1]
    decimalPlaces.replace(/0+$/, with: "")
    let missingZeros = numberOfDecimalPlaces - decimalPlaces.count
    if missingZeros > 0 {
        decimalPlaces += String(repeating: "0", count: missingZeros)
    } else if missingZeros < 0 {
        guard let numberFromDecimalPlaces = Double(decimalPlaces) else { return text }
        decimalPlaces = Substring(String(Int(round(numberFromDecimalPlaces / (pow(10.0, Double(-missingZeros)))))))
    }
    return "\(numberParts[0]).\(decimalPlaces)\(unitText)"
}

/// Get the "cm" value from a text where a unit is used that occurs in the `UnitOfLength` enumeration.
/// The second vaue is the original unit used.
public func centimetersWithOriginalUnit(fromText _text: String?) -> (centimeters: Double, originalUnit: UnitOfLength?)? {
    guard let (number: numberText, unit: unitText) = numberAndUnitTexts(fromText: _text) else { return nil }
    
    guard let number = Double(numberText) else { return nil }
    
    guard let unitText, let unit = UnitOfLength.fromText(String(unitText)) else { return nil }
    let factor = unit.factorFromCentimeters
    
    return (factor == 1 ? number : number * factor, unit)
}

public func length(fromText text: String?, in unit: UnitOfLength) -> Double? {
    guard let (centimeters, _) = centimetersWithOriginalUnit(fromText: text) else { return nil }
    return centimeters / unit.factorFromCentimeters
}

/// Get the percent value from " ... % ".
public func percents(fromText _text: String?) -> Double? {
    guard let text = _text?.trimming() else { return nil }
    if text.hasSuffix("%") {
        return Double(text.dropLast().trimming())
    } else {
        return nil
    }
}

/// Get the relative value from " ... * ".
public func relativeValue(fromText _text: String?) -> Double? {
    guard let text = _text?.trimming() else { return nil }
    if text.hasSuffix("*") {
        return Double(text.dropLast().trimming())
    } else {
        return nil
    }
}

/// Get the textual representation for a centimeters value with a certain unit.
public func text(forCentimeters centimeters: Double, usingUnit unit: UnitOfLength? = nil, digits: Int = 3, zeroDigits: Int = 0) -> String {
    var factor: Double = 1
    var unitText = "cm"
    if let unit = unit {
        factor = unit.factorFromCentimeters
        unitText = unit.rawValue
    }
    if zeroDigits == 0 {
        return String(format: "%.\(digits)f", factor == 1 ? centimeters: centimeters / factor) + unitText
    } else {
        return String(format: "%.\(digits - zeroDigits)f", factor == 1 ? centimeters: centimeters / factor) + String(repeating: "0", count: zeroDigits) + unitText
    }
}

/// Get the textual representation for a star value (i.e. relative width).
public func text(forStars stars: Double, digits: Int = 3) -> String {
    sizeText(forValue: stars, digits: digits, postfix: "*")
}

/// Get the textual representation for a percent value (i.e. relative width).
public func text(forPercentage percentage: Double, digits: Int = 3) -> String {
    sizeText(forValue: percentage, digits: digits, postfix: "%")
}

/// Get the textual representation for a value (i.e. relative width).
public func sizeText(forValue value: Double, digits: Int = 3, postfix: String) -> String {
    if value == floor(value) {
        return String(Int(value)) + "*"
    } else {
        var numberText = Substring(String(format: "%.\(digits)f", value))
        while numberText.hasSuffix("0") {
            numberText = numberText.dropLast()
        }
        if numberText.hasSuffix(".") {
            numberText = numberText.dropLast()
        }
        return numberText + postfix
    }
}
