/*
 Definitions useful when working with sequences.
 */

import Foundation

public extension Sequence {
    
    /// Async version of for each.
    func forEachAsync (
        _ operation: (Element) async -> Void
    ) async {
        for element in self {
            await operation(element)
        }
    }
    
    /// Async version of for each (throwing).
    func forEachAsync (
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
    
    /// Async version of for map.
    func mapAsync<T>(
        _ transform: (Element) async -> T
    ) async -> [T] {
        var values = [T]()

        for element in self {
            await values.append(transform(element))
        }

        return values
    }
    
    /// Async version of for map (throwing).
    func mapAsync<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
    
    /// Take from a sequence while condition is fullfilled (corresponds to `prefix` from Swift Foundation).
    @inlinable func takeWhile(_ condition: (Self.Element) throws -> Bool) rethrows -> [Self.Element] {
        return try self.prefix(while: condition)
    }
    
}
