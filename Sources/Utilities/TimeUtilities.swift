import Foundation

public func formattedTime(forFilename: Bool = false) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd\(forFilename ? "_" : " ")HH\(forFilename ? "_" : ":")mm\(forFilename ? "_" : ":")ss\(forFilename ? "_" : ".")SSS"
    return formatter.string(from: Date())
}

public func elapsedSeconds(start: DispatchTime, current: DispatchTime = DispatchTime.now()) -> Double {
    return Double(current.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
}

public class Time {
    
    private var _time: DispatchTime
    
    public init(withOffset offset: Int = 0) {
        _time = DispatchTime.now() + DispatchTimeInterval.seconds(offset)
    }
    
    public func set() {
        _time = DispatchTime.now()
    }
    
    public var value: DispatchTime {
        get {
            return _time
        }
    }
}
