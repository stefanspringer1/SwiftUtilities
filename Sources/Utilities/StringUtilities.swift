/*
 Definitions useful when working with string and substrings.
 */

import Foundation

public extension String {
    
    /// Concatinates Strings prefix and self.
    ///
    /// - Parameters:
    ///     - prefix: optional String to prepend to self
    ///
    ///  - Returns: Concatination of prefix and self, if prefix is non nil, else self.
    func prepending(_ prefix: String?) -> String {
        if let prefix = prefix { return prefix.appending(self) } else { return self }
    }
    
    /// Concatinates Strings self and postfix.
    ///
    /// - Parameters:
    ///     - postfix: optional String to append to self
    ///
    ///  - Returns: Concatination of self and postfix, if postfix is non nil, else self.
    func appending(_ postfix: String?) -> String {
        if let postfix = postfix { return self.appending(postfix) } else { return self }
    }
    
}

public extension StringProtocol {
    
    /// Concatinates prefix and self, each being a String or SubString.
    ///
    /// - Parameters:
    ///     - prefix: optional String or SubString. to prepend to self
    ///
    ///  - Returns: Concatination of prefix and self, if prefix is non nil, else self as String.
    func prepending<T: StringProtocol>(_ prefix: T?) -> String {
        if let prefix = prefix { return prefix.appending(self) } else { return self as? String ?? String(self) }
    }
    
    /// Concatinates self and postfix, each being a String or SubString.
    ///
    /// - Parameters:
    ///     - postfix: optional String or SubString to append to self
    ///
    ///  - Returns: Concatination of self and postfix, if prefix is non nil, else self as String.
    func appending<T: StringProtocol>(_ postfix: T?) -> String {
        if let postfix = postfix { return self.appending(postfix) } else { return self as? String ?? String(self) }
    }
    
    /// Removes whitespace  and newlines from left and right of self.
    ///
    /// - Returns: Self with whitespace and newlines removed from left and right.
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Removes whitespace  and newlines from left of self.
    ///
    /// - Returns: Self with whitespace and newlines removed from left.
    func trimLeft() -> Self.SubSequence {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return self[index...]
    }
    
    /// Removes whitespace  and newlines from right of self.
    ///
    /// - Returns: Self with whitespace and newlines removed from right.
    func trimRight() -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[...index])
    }
    
    /// Test if a text contains a part matching a certain regular expression.
    ///
    /// Use a regular expression of the form "^...$" to test if the whole text matches the expression.
    func contains(regex: String) -> Bool {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match != nil
    }
    
    /// Replace all text matching a certain certain regular expression.
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid having to apply your regular expression several times.
    func replace(regex: String, by theReplacement: String) -> String {
        var result: String = ""
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: theReplacement, options: .regularExpression, range: nil)
        }
        return result
    }
    
    /// Substring of a string until a ceratin string occurs.
    ///
    /// If the substring is not found, the whole string is returned.
    func until(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[self.startIndex..<range.lowerBound])
        }
        else {
            return String(self)
        }
    }
    
    /// Substring of a string after a certain string occurs.
    ///
    /// If the substring is not found, the whole string is returned.
    func after(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[range.upperBound..<self.endIndex].dropFirst())
        }
        else {
            return String(self)
        }
    }
    
    /// If the string is empty, return nil, else return self.
    var nonEmptyOrNil: Self? {
        self.isEmpty ? nil : self
    }

    
}

public extension String {
    
    /// Create a string from a collection of `UnicodeScalar`.
    init<S: Sequence>(unicodeScalars ucs: S) where S.Iterator.Element == UnicodeScalar {
        var s = ""
        s.unicodeScalars.append(contentsOf: ucs)
        self = s
    }
    
    /// Trimming all whitespace.
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Trimming left whitespace.
    func trimLeft() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[index...])
    }
    
    /// Trimming right whitespace.
    func trimRight() -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[...index])
    }
    
    /// Test if a text contains a part matching a certain regular expression.
    ///
    /// Use a regular expression of the form "^...$" to test if the whole text matches the expression.
    func contains(regex: String) -> Bool {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match != nil
    }
    
    /// Replace all text matching a certain certain regular expression.
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid having to apply your regular expression several times.
    func replace(regex: String, by theReplacement: String) -> String {
        var result = self
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: theReplacement, options: .regularExpression, range: nil)
        }
        return result
    }
    
    /// Replace all text matching a certain certain regular expression, repeat it while teh text is changing.
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid the use of this method!
    func replaceWhileChanging(regex: String, by theReplacement: String) -> String {
        var result = self
        var newResult = self
        repeat {
            result = newResult
            newResult = result.replace(regex: regex, by: theReplacement)
        } while newResult != result
        return result
    }
    
    /// Substring of a string until a ceratin string occurs.
    ///
    /// If the substring is not found, the whole string is returned.
    func until(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[self.startIndex..<range.lowerBound])
        }
        else {
            return self
        }
    }
    
    /// If the string is empty, return nil, else return self.
    var nonEmptyOrNil: String? {
        self.isEmpty ? nil : self
    }
}

public extension Array where Element == String? {
    
    /// Join all strings in the array using a separator, but filter out nils,
    /// and if the array is then empty, return nil.
    func joined(separator: String) -> String? {
        let nonNils = self.filter { $0 != nil } as! [String]
        return nonNils.isEmpty ? nil : nonNils.joined(separator: separator)
    }
    
    /// Join all strings in the array using a separator, but filter out nils and
    /// empty strings, and if the array is then empty, return nil.
    func joinedNonEmpties(separator: String) -> String? {
        let nonEmpties = self.filter { !($0?.isEmpty ?? false) } as! [String]
        return nonEmpties.isEmpty ? nil : nonEmpties.joined(separator: separator)
    }
}
