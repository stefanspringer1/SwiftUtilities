import Foundation

/// An error with a description.
///
/// When printing such an error, its descrition is printed.
public struct ErrorWithDescription: LocalizedError, CustomStringConvertible {

    private let message: String

    public init(_ message: String?) {
        self.message = message ?? "(unkown error))"
    }
    
    public var description: String { message }
    
    public var errorDescription: String? { message }
}

/// See `func ?!(...)`.
infix operator ?!: NilCoalescingPrecedence

/// Operator that throws the right hand side error if the left hand side optional is `nil`.
public func ?!<T>(value: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = value else {
        throw error()
    }
    return value
}
