/*
 Definitons of some helpful data types.
*/

import Foundation

/// A wrapper around Set that can passed around by reference.
public class ReferencedSet<T: Hashable> {
    
    private var set = Set<T>()
    
    public init() {}
    
    public func insert(_ value: T) {
        set.insert(value)
    }
    
    public func contains(_ value: T) -> Bool {
        return set.contains(value)
    }
    
}

/// A wrapper around Array that can passed around by reference.
public class ReferencedArray<T: Any> {
    
    private var array = [T]()
    
    public init() {}
    
    public func append(_ value: T) {
        array.append(value)
    }
    
    public func getAll() -> [T] {
        return array
    }
    
}


/// A wrapper around Dictionary that can passed around by reference.
public class Index<K: Hashable,V> {
    
    private var _dictionary = [K:V]()
    
    public var dictionary: [K:V] { _dictionary }
    
    public func forEach(_ body: ((key: K, value: V)) throws -> Void) rethrows {
        try _dictionary.forEach{ (key,value) in try body((key,value)) }
    }
    
    public func forEach(_ body: ((key: K, value: V)) -> Void) {
        _dictionary.forEach{ (key,value) in body((key,value)) }
    }
    
    public init() {}
    
    public var isEmpty: Bool { _dictionary.isEmpty }
    
    public func put(key: K, value: V) {
        _dictionary[key] = value
    }
    
    public subscript(key: K) -> V? {
        
        set {
            _dictionary[key] = newValue
        }
        
        get {
            return _dictionary[key]
        }
        
    }
    
    public var keys: Dictionary<K, V>.Keys {
        return _dictionary.keys
    }
    
}

/// A map of reference-type that has pairs as keys.
public class PairedIndex<K1: Hashable,K2: Hashable,V> {
    
    private var dictionary = [K1:Index<K2,V>]()
    
    public init() {}
    
    public var isEmpty: Bool { dictionary.isEmpty }
    
    public func put(key1: K1, key2: K2, value: V?) {
        let indexForKey1 = dictionary[key1] ?? {
            let newIndex = Index<K2,V>()
            dictionary[key1] = newIndex
            return newIndex
        }()
        indexForKey1[key2] = value
        if indexForKey1.isEmpty {
            dictionary[key1] = nil
        }
    }
    
    public subscript(key1: K1, key2: K2) -> V? {
        
        set {
            put(key1: key1, key2: key2, value: newValue)
        }
        
        get {
            return dictionary[key1]?[key2]
        }
        
    }
    
}
