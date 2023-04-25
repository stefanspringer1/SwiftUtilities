/*
 Some definitions useful when working with time, e.g. for measuring durations.
 */

import Foundation

/// Get a string representation of the current time.
///
/// `avoidSpace` avoid space by setting an `T` after the date instead of a space.
///
/// `forFilename` indicates if the result is to be used as the part of a file name,
///  it then only contains characters being allowed in a file names on all
///  eligible platforms, and it also does not contain any whitespace (the setting incudes `avoidSpace = true`).
func formattedTime(avoidSpace: Bool = false, forFilename: Bool = false) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZZZZZ"
    var result = formatter.string(from: Date())
    if avoidSpace || forFilename {
        result = result.replacingOccurrences(of: " ", with: "T")
    }
    if forFilename {
        result = result.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: ".", with: "_")
    }
    return result
}

/// Get the ellapsed seconds since `start`.
///
/// The time to compare to is either the current time or the value of the argument `reference`.
public func elapsedSeconds(start: DispatchTime, reference: DispatchTime = DispatchTime.now()) -> Double {
    return Double(reference.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
}

/// A class tracking a time value.
public class Time {
    
    private var _time: DispatchTime
    
    /// The time set as value is the current time plus the offset (default for the offset is 0).
    public init(withOffset offset: Int = 0) {
        _time = DispatchTime.now() + DispatchTimeInterval.seconds(offset)
    }
    
    /// Set the time value to the current time.
    public func set() {
        _time = DispatchTime.now()
    }
    
    /// Get the value.
    public var value: DispatchTime {
        get {
            return _time
        }
    }
}
