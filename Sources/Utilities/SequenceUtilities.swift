import Foundation

public extension Sequence {
    
    func forEachAsync (
        _ operation: (Element) async -> Void
    ) async {
        for element in self {
            await operation(element)
        }
    }
    
    func forEachAsyncThrowing (
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
    
    func mapAsync<T>(
        _ transform: (Element) async -> T
    ) async -> [T] {
        var values = [T]()

        for element in self {
            await values.append(transform(element))
        }

        return values
    }
    
    func mapAsyncThrowing<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
    
    @inlinable func takeWhile(_ condition: (Self.Element) throws -> Bool) rethrows -> [Self.Element] {
        return try self.prefix(while: condition)
    }
    
}
