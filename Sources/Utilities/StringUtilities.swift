/*
 Definitions useful when working with string and substrings.
 */

import Foundation
import AutoreleasepoolShim

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
    
    /// Removing quotes "..." or '...'.
    var withoutQuotes: String {
        if let range = self.firstMatch(of: /^["'](.*)["']$/) {
            return String(range.1)
        } else {
            return self
        }
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
    func trimming() -> Self.SubSequence {
        return self.trimmingLeft().trimmingRight()
    }
    
    /// Removes whitespace  and newlines from left of self.
    ///
    /// - Returns: Self with whitespace and newlines removed from left.
    func trimmingLeft() -> Self.SubSequence {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return ""
        }
        return self[index...]
    }
    
    /// Removes whitespace  and newlines from right of self.
    ///
    /// - Returns: Self with whitespace and newlines removed from right.
    func trimmingRight() -> Self.SubSequence {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return ""
        }
        return self[...index]
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
    
    /// Find first occurrence of a regex.
    func firstOccurrence(ofRegex regex: String) -> Range<String.Index>? {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match
    }
    
    /// Find first occurrence of a regex after skipping n occurrences of it.
    func firstOccurrence(ofRegex regex: String, skipping: Int) -> Range<String.Index>? {
        var match: Range<String.Index>?
        var searchRange = self.startIndex..<self.endIndex
        var skippingRest = skipping
        autoreleasepool {
            while skippingRest >= 0 {
                match = self.range(of: regex, options: .regularExpression, range: searchRange)
                if let match {
                    skippingRest -= 1
                    searchRange = match.upperBound..<searchRange.upperBound
                }
                else {
                    skippingRest = -1
                }
            }
        }
        return match
    }
    
    /// Test if a text only consists of whitespace.
    var isWhitespace: Bool { contains(regex: #"^\s*$"#) }
    
    /// Test if a text only consists of whitespace.
    var nonEmpty: Self? { self.isEmpty ? nil : self }
    
    /// Replace all text matching a certain certain regular expression.
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid having to apply your regular expression several times.
    func replacing(regex: String, withTemplate template: String) -> String {
        var result: String = ""
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: template, options: .regularExpression, range: nil)
        }
        return result
    }
    
    /// Substring of a string until a ceratin string occurs.
    ///
    /// If the substring is not found, nil is returned.
    func until(_ substring: any StringProtocol) -> Self.SubSequence? {
        if let range = self.range(of: substring) {
            return self[self.startIndex..<range.lowerBound]
        } else {
            return nil
        }
    }
    
    /// Substring of a string after a certain string occurs.
    ///
    /// If the substring is not found, nil is returned.
    func after(_ substring: any StringProtocol) -> Self.SubSequence? {
        if let range = self.range(of: substring) {
            return self[range.upperBound..<self.endIndex]
        } else {
            return nil
        }
    }
    
    /// If the string is empty, return nil, else return self.
    var nonEmptyOrNil: Self? {
        self.isEmpty ? nil : self
    }

    /// Find parts according to a regex.
    func parts(matchingRegex regex: String) -> [String] {
        var parts = [String]()
        var rest = Substring(self)
        while let word = rest.firstOccurrence(ofRegex: regex) {
            parts.append(String(rest[word.lowerBound..<word.upperBound]))
            rest = rest[word.upperBound...]
        }
        return parts
    }
    
    /// Test if a text contains a part matching a certain regular expression.
    ///
    /// Use a regular expression of the form "^...$" to test if the whole text matches the expression.
    func contains(regex: any StringProtocol) -> Bool {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match != nil
    }
    
    /// Find first occurrence of a regex.
    func firstOccurrence(ofRegex regex: any StringProtocol) -> Range<String.Index>? {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match
    }
    
    /// Find first occurrence of a regex after skipping n occurrences of it.
    func firstOccurrence(ofRegex regex: any StringProtocol, skipping: Int) -> Range<String.Index>? {
        var match: Range<String.Index>?
        var searchRange = self.startIndex..<self.endIndex
        var skippingRest = skipping
        autoreleasepool {
            while skippingRest >= 0 {
                match = self.range(of: regex, options: .regularExpression, range: searchRange)
                if let match {
                    skippingRest -= 1
                    searchRange = match.upperBound..<searchRange.upperBound
                }
                else {
                    skippingRest = -1
                }
            }
        }
        return match
    }
    
    var asString: String {
        return String(self)
    }
}

extension BidirectionalCollection where Self.SubSequence == Substring {

    /// Find first occurrence of a regex after skipping n occurrences of it.
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    public func firstOccurrence(of r: some RegexComponent, skipping: Int) -> Range<String.Index>? {
        let matches = self.matches(of: r)
        if matches.count > skipping {
            return matches[skipping].range
        } else {
            return nil
        }
    }
}

public extension String {
    
    /// Create a string from a collection of `UnicodeScalar`.
    init<S: Sequence>(unicodeScalars ucs: S) where S.Iterator.Element == UnicodeScalar {
        var s = ""
        s.unicodeScalars.append(contentsOf: ucs)
        self = s
    }
    
    /// Replace all text matching a certain certain regular expression.
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid having to apply your regular expression several times.
    func replacing(regex: String, withTemplate template: any StringProtocol) -> String {
        var result = self
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: template, options: .regularExpression, range: nil)
        }
        return result
    }
    
    /// Replace all text matching a certain certain regular expression, semangtic level can be set to
    /// .unicodeScala or .graphemeCluster).
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid having to apply your regular expression several times.
    @available(macOS 13.0, *)
    func replacing(regex: String, withTemplate template: String, usingSemanticLevel semanticLevel: RegexSemanticLevel) -> String {
        return self.replacing(try! Regex(regex).matchingSemantics(semanticLevel), withTemplate: template)
    }
    
}

extension RangeReplaceableCollection where SubSequence == Substring {
    
    /// Replace regex with pattern.
    @available(macOS 13.0, *)
    func replacing(
        _ regex: some RegexComponent,
        withTemplate template: String,
        maxReplacements: Int = .max
    ) -> Self {
        var result = self
        autoreleasepool {
            let numberedGroupRegex = #/\$([0-9]+)/#
                .asciiOnlyCharacterClasses()
                .matchingSemantics(.unicodeScalar)
            result = self.replacing(regex, maxReplacements: maxReplacements) { match in
                let typeErasedMatch: Regex<AnyRegexOutput>.Match = .init(match)
                return template.replacing(numberedGroupRegex) { groupMatch in
                    let groupNumber = Int(groupMatch.output.1)!
                    let replacement = typeErasedMatch[groupNumber].substring!
                    return replacement
                }
            }
        }
        return result
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
