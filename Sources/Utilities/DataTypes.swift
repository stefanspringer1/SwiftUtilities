/*
 Definitons of some helpful data types.
*/

import Foundation

/// A wrapper around Set that can passed around by reference.
public class Referenced<T> {
    
    public var referenced: T
    
    public init(_ referenced: T) {
        self.referenced = referenced
    }
    
}

/// A map of reference-type that has keys on two levels.
public class TieredDictionary<K1: Hashable,K2: Hashable,V> {
    
    private var dictionary = [K1:Referenced<[K2:V]>]()
    
    public init() {}
    
    public var isEmpty: Bool { dictionary.isEmpty }
    
    public func put(key1: K1, key2: K2, value: V?) {
        let indexForKey1 = dictionary[key1] ?? {
            let newIndex = Referenced([K2:V]())
            dictionary[key1] = newIndex
            return newIndex
        }()
        indexForKey1.referenced[key2] = value
        if indexForKey1.referenced.isEmpty {
            dictionary[key1] = nil
        }
    }
    
    public subscript(key1: K1, key2: K2) -> V? {
        
        set {
            put(key1: key1, key2: key2, value: newValue)
        }
        
        get {
            return dictionary[key1]?.referenced[key2]
        }
        
    }
    
    public subscript(key1: K1) -> [K2:V]? {
        
        get {
            return dictionary[key1]?.referenced
        }
        
    }
    
    public var leftKeys: Dictionary<K1, Referenced<Dictionary<K2, V>>>.Keys { dictionary.keys }
    
    public func rightKeys(forLeftKey leftKey: K1) -> Dictionary<K2, V>.Keys? {
        return dictionary[leftKey]?.referenced.keys
    }
    
    public var rightKeys: Set<K2> {
        var keys = Set<K2>()
        leftKeys.forEach { leftKey in
            rightKeys(forLeftKey: leftKey)?.forEach { rightKey in
                keys.insert(rightKey)
            }
        }
        return keys
    }
}

/// An `Index` can hold several values for one key.
public class Index<K: Hashable,V: Hashable> {
    
    private var dictionary = [K:Referenced<Set<V>>]()
    
    public init() {}
    
    public var isEmpty: Bool { dictionary.isEmpty }
    
    public func put(key: K, value: V) {
        let setForKey = dictionary[key] ?? {
            let newSet = Referenced(Set<V>())
            dictionary[key] = newSet
            return newSet
        }()
        setForKey.referenced.insert(value)
    }
    
    public func remove(forKey key: K, value: V) {
        if let setForKey = dictionary[key] {
            setForKey.referenced.remove(value)
        }
    }
    
    public func removeAll(forKey key: K, value: V) {
        dictionary[key] = nil
    }
    
    var keys: Dictionary<K, Referenced<Set<V>>>.Keys {
        return dictionary.keys
    }
    
    public subscript(key: K) -> Set<V>? {
        
        get {
            return dictionary[key]?.referenced
        }
        
    }
    
}

/// An `Index` can hold several values for one key.
public class IndexWithNonHashableValues<K: Hashable,V> {
    
    private var dictionary = [K:Referenced<[V]>]()
    
    public init() {}
    
    public var isEmpty: Bool { dictionary.isEmpty }
    
    public func put(key: K, value: V) {
        let setForKey = dictionary[key] ?? {
            let newSet = Referenced([V]())
            dictionary[key] = newSet
            return newSet
        }()
        setForKey.referenced.append(value)
    }
    
    public func removeAll(forKey key: K, value: V) {
        dictionary[key] = nil
    }
    
    public subscript(key: K) -> [V]? {
        
        get {
            return dictionary[key]?.referenced
        }
        
    }
    
}
