/*
 Definitons of some helpful data types.
*/

import Foundation

/// A wrapper around Set that can passed around by reference.
public class Referenced<T> {
    
    public var referenced: T
    
    public init(for referenced: T) {
        self.referenced = referenced
    }
    
}

/// A map of reference-type that has pairs as keys.
public class ReferencedDictionaryForPairs<K1: Hashable,K2: Hashable,V> {
    
    private var dictionary = [K1:Referenced<Dictionary<K2,V>>]()
    
    public init() {}
    
    public var isEmpty: Bool { dictionary.isEmpty }
    
    public func put(key1: K1, key2: K2, value: V?) {
        let indexForKey1 = dictionary[key1] ?? {
            let newIndex = Referenced(for: [K2:V]())
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
