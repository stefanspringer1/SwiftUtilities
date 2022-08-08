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
    
}

public extension StringProtocol {
    
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
    
    func contains(regex: String) -> Bool {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match != nil
    }
    
    func replace(regex: String, by theReplacement: String) -> String {
        var result: String = ""
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: theReplacement, options: .regularExpression, range: nil)
        }
        return result
    }
    
    func until(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[self.startIndex..<range.lowerBound])
        }
        else {
            return String(self)
        }
    }
    
    func after(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[range.lowerBound..<self.endIndex].dropFirst().dropLast())
        }
        else {
            return String(self)
        }
    }
    
    func nonEmptyOrNil() -> Self? {
        self.isEmpty ? nil : self
    }

    
}

public extension String {
    
    init<S: Sequence>(unicodeScalars ucs: S) where S.Iterator.Element == UnicodeScalar {
        var s = ""
        s.unicodeScalars.append(contentsOf: ucs)
        self = s
    }
    
    var nonEmpty: String? {
        self.isEmpty ? nil : self
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func trimLeft() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[index...])
    }
    
    func trimRight() -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[...index])
    }
    
    func contains(regex: String) -> Bool {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match != nil
    }
    
    func replace(regex: String, by theReplacement: String) -> String {
        var result = self
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: theReplacement, options: .regularExpression, range: nil)
        }
        return result
    }
    
    func replaceWhileChanging(regex: String, by theReplacement: String) -> String {
        var result = self
        var newResult = self
        repeat {
            result = newResult
            newResult = result.replace(regex: regex, by: theReplacement)
        } while newResult != result
        return result
    }
    
    func until(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[self.startIndex..<range.lowerBound])
        }
        else {
            return self
        }
    }
    
    func after(substring: String) -> String {
        if let range = self.range(of: substring) {
            return String(self[range.lowerBound..<self.endIndex].dropFirst().dropLast())
        }
        else {
            return self
        }
    }
    
    func nonEmptyOrNil() -> String? {
        self.isEmpty ? nil : self
    }
}

public extension Array where Element == String? {
    
    func joined(separator: String) -> String? {
        let nonNils = self.filter { $0 != nil } as! [String]
        return nonNils.isEmpty ? nil : nonNils.joined(separator: separator)
    }
    
    func joinedNonEmpties(separator: String) -> String? {
        let nonEmpties = self.filter { !($0?.isEmpty ?? false) } as! [String]
        return nonEmpties.isEmpty ? nil : nonEmpties.joined(separator: separator)
    }
}
