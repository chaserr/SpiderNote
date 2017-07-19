
//
//  UserDefaults.swift
//  Spider
//
//  Created by 童星 on 16/7/5.
//  Copyright © 2016年 oOatuo. All rights reserved.
//

import UIKit

public let Defaults = UserDefaults.standard

public extension UserDefaults {
    class Proxy {
        fileprivate let defaults: UserDefaults
        fileprivate let key: String
        
        fileprivate init(_ defaults: UserDefaults, _ key: String) {
            self.defaults = defaults
            self.key = key
        }
        
        // MARK: Getters
        
        open var object: NSObject? {
            return defaults.object(forKey: key) as? NSObject
        }
        
        open var string: String? {
            return defaults.string(forKey: key)
        }
        
        open var array: NSArray? {
            return defaults.array(forKey: key) as! NSArray
        }
        
        open var dictionary: NSDictionary? {
            return defaults.dictionary(forKey: key) as! NSDictionary
        }
        
        open var data: Data? {
            return defaults.data(forKey: key)
        }
        
        open var date: Date? {
            return object as? Date
        }
        
        open var number: NSNumber? {
            return defaults.numberForKey(key)
        }
        
        open var int: Int? {
            return number?.intValue
        }
        
        open var double: Double? {
            return number?.doubleValue
        }
        
        open var bool: Bool? {
            return number?.boolValue
        }
        
        // MARK: Non-Optional Getters
        
        open var stringValue: String {
            return string ?? ""
        }
        
        open var arrayValue: NSArray {
            return array ?? []
        }
        
        open var dictionaryValue: NSDictionary {
            return dictionary ?? NSDictionary()
        }
        
        open var dataValue: Data {
            return data ?? Data()
        }
        
        open var numberValue: NSNumber {
            return number ?? 0
        }
        
        open var intValue: Int {
            return int ?? 0
        }
        
        open var doubleValue: Double {
            return double ?? 0
        }
        
        open var boolValue: Bool {
            return bool ?? false
        }
    }
    
    /// `NSNumber` representation of a user default
    
    func numberForKey(_ key: String) -> NSNumber? {
        return object(forKey: key) as? NSNumber
    }
    
    /// Returns getter proxy for `key`
    
    public subscript(key: String) -> Proxy {
        return Proxy(self, key)
    }
    
    /// Sets value for `key`
    
    public subscript(key: String) -> Any? {
        get {
            return self[key]
        }
        set {
            switch newValue {
            case let v as Int: self.set(v, forKey: key)
            case let v as Double: self.set(v, forKey: key)
            case let v as Bool: self.set(v, forKey: key)
            case let v as URL: self.set(v, forKey: key)
            case let v as NSObject: self.set(v, forKey: key)
            case nil: removeObject(forKey: key)
            default: assertionFailure("Invalid value type")
            }
        }
    }
    
    /// Returns `true` if `key` exists
    
    public func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    /// Removes value for `key`
    
    public func remove(_ key: String) {
        removeObject(forKey: key)
    }
}

/// Global shortcut for NSUserDefaults.standardUserDefaults()

// MARK: - Static keys

/// Extend this class and add your user defaults keys as static constants
/// so you can use the shortcut dot notation (e.g. `Defaults[.yourKey]`)

open class DefaultsKeys {
    fileprivate init() {}
}

/// Base class for static user defaults keys. Specialize with value type type
/// and pass key name to the initializer to create a key.

open class DefaultsKey<ValueType>: DefaultsKeys {
    // TODO: Can we use protocols to ensure ValueType is a compatible type?
    open let _key: String
    
    public init(_ key: String) {
        self._key = key
    }
}

extension UserDefaults {
    func set<T>(_ key: DefaultsKey<T>, _ value: Any?) {
        self[key._key] = value
    }
}

extension UserDefaults {
    /// Returns `true` if `key` exists
    
    public func hasKey<T>(_ key: DefaultsKey<T>) -> Bool {
        return object(forKey: key._key) != nil
    }
    
    /// Removes value for `key`
    
    public func remove<T>(_ key: DefaultsKey<T>) {
        removeObject(forKey: key._key)
    }
}

// MARK: Static subscripts for standard types

// TODO: Use generic subscripts when they become available

extension UserDefaults {
    public subscript(key: DefaultsKey<String?>) -> String? {
        get { return string(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<String>) -> String {
        get { return string(forKey: key._key) ?? "" }
        set { set(key, newValue) }
    }
    public subscript(key: DefaultsKey<NSString?>) -> NSString? {
        get { return string(forKey: key._key) as! NSString }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<NSString>) -> NSString {
        get { return string(forKey: key._key) as! NSString ?? "" }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Int?>) -> Int? {
        get { return numberForKey(key._key)?.intValue }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Int>) -> Int {
        get { return numberForKey(key._key)?.intValue ?? 0 }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Double?>) -> Double? {
        get { return numberForKey(key._key)?.doubleValue }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Double>) -> Double {
        get { return numberForKey(key._key)?.doubleValue ?? 0.0 }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Bool?>) -> Bool? {
        get { return numberForKey(key._key)?.boolValue }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return numberForKey(key._key)?.boolValue ?? false }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<AnyObject?>) -> AnyObject? {
        get { return object(forKey: key._key) as AnyObject }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<NSObject?>) -> NSObject? {
        get { return object(forKey: key._key) as? NSObject }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Data?>) -> Data? {
        get { return data(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Data>) -> Data {
        get { return data(forKey: key._key) ?? Data() }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<Date?>) -> Date? {
        get { return object(forKey: key._key) as? Date }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<URL?>) -> URL? {
        get { return url(forKey: key._key) }
        set { set(key, newValue) }
    }
    
    // TODO: It would probably make sense to have support for statically typed dictionaries (e.g. [String: String])
    
    public subscript(key: DefaultsKey<[String: AnyObject]?>) -> [String: AnyObject]? {
        get { return dictionary(forKey: key._key) as! [String : AnyObject] }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[String: AnyObject]>) -> [String: AnyObject] {
        get { return dictionary(forKey: key._key)! as [String : AnyObject] ?? [:] }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<NSDictionary?>) -> NSDictionary? {
        get { return dictionary(forKey: key._key) as! NSDictionary }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<NSDictionary>) -> NSDictionary {
        get { return dictionary(forKey: key._key) as! NSDictionary ?? [:] }
        set { set(key, newValue) }
    }
}

// MARK: Static subscripts for array types

extension UserDefaults {
    public subscript(key: DefaultsKey<NSArray?>) -> NSArray? {
        get { return array(forKey: key._key) as! NSArray }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<NSArray>) -> NSArray {
        get { return array(forKey: key._key) as! NSArray ?? [] }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[AnyObject]?>) -> [AnyObject]? {
        get { return array(forKey: key._key) as! [AnyObject] }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[AnyObject]>) -> [AnyObject] {
        get { return array(forKey: key._key) as! [AnyObject] ?? [] }
        set { set(key, newValue) }
    }
}

// We need the <T: AnyObject> and <T: _ObjectiveCBridgeable> variants to
// suppress compiler warnings about NSArray not being convertible to [T]
// AnyObject is for NSData and NSDate, _ObjectiveCBridgeable is for value
// types bridge-able to Foundation types (String, Int, ...)

extension UserDefaults {
    public func getArray<T: _ObjectiveCBridgeable>(_ key: DefaultsKey<[T]>) -> [T] {
        return array(forKey: key._key) as NSArray? as? [T] ?? []
    }
    
    public func getArray<T: _ObjectiveCBridgeable>(_ key: DefaultsKey<[T]?>) -> [T]? {
        return array(forKey: key._key) as NSArray? as? [T]
    }
    
    public func getArray<T: AnyObject>(_ key: DefaultsKey<[T]>) -> [T] {
        return array(forKey: key._key) as NSArray? as? [T] ?? []
    }
    
    public func getArray<T: AnyObject>(_ key: DefaultsKey<[T]?>) -> [T]? {
        return array(forKey: key._key) as NSArray? as? [T]
    }
}

extension UserDefaults {
    public subscript(key: DefaultsKey<[String]?>) -> [String]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[String]>) -> [String] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Int]?>) -> [Int]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Int]>) -> [Int] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Double]?>) -> [Double]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Double]>) -> [Double] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Bool]?>) -> [Bool]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Bool]>) -> [Bool] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Data]?>) -> [Data]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Data]>) -> [Data] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Date]?>) -> [Date]? {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
    
    public subscript(key: DefaultsKey<[Date]>) -> [Date] {
        get { return getArray(key) }
        set { set(key, newValue) }
    }
}

// MARK: Archiving complex types

extension UserDefaults {
    // TODO: Can we simplify this and ensure that T is NSCoding compliant?
    
    public func archive<T>(_ key: DefaultsKey<T>, _ value: T) {
        if let value: AnyObject = value as? AnyObject {
            set(key, NSKeyedArchiver.archivedData(withRootObject: value))
        } else {
            assertionFailure("Invalid value type")
        }
    }
    
    public func archive<T>(_ key: DefaultsKey<T?>, _ value: T?) {
        if let value: AnyObject = value as? AnyObject {
            set(key, NSKeyedArchiver.archivedData(withRootObject: value))
        } else if value == nil {
            remove(key)
        } else {
            assertionFailure("Invalid value type")
        }
    }
    
    public func unarchive<T>(_ key: DefaultsKey<T?>) -> T? {
        return data(forKey: key._key).flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) } as? T
    }
    
    public func unarchive<T>(_ key: DefaultsKey<T>) -> T? {
        return data(forKey: key._key).flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) } as? T
    }
}

// MARK: - Deprecations

infix operator ?= {
associativity right
precedence 90
}

/// If key doesn't exist, sets its value to `expr`
/// Note: This isn't the same as `Defaults.registerDefaults`. This method saves the new value to disk, whereas `registerDefaults` only modifies the defaults in memory.
/// Note: If key already exists, the expression after ?= isn't evaluated

@available(*, deprecated: 1, message: "Please migrate to static keys and use this gist: https://gist.github.com/radex/68de9340b0da61d43e60")
public func ?= (proxy: UserDefaults.Proxy, expr: @autoclosure () -> Any) {
    if !proxy.defaults.hasKey(proxy.key) {
        proxy.defaults[proxy.key] = expr()
    }
}

/// Adds `b` to the key (and saves it as an integer)
/// If key doesn't exist or isn't a number, sets value to `b`

@available(*, deprecated: 1, message: "Please migrate to static keys to use this.")
public func += (proxy: UserDefaults.Proxy, b: Int) {
    let a = proxy.defaults[proxy.key].intValue
    proxy.defaults[proxy.key] = a + b
}

@available(*, deprecated: 1, message: "Please migrate to static keys to use this.")
public func += (proxy: UserDefaults.Proxy, b: Double) {
    let a = proxy.defaults[proxy.key].doubleValue
    proxy.defaults[proxy.key] = a + b
}

/// Icrements key by one (and saves it as an integer)
/// If key doesn't exist or isn't a number, sets value to 1

@available(*, deprecated: 1, message: "Please migrate to static keys to use this.")
public postfix func ++ (proxy: UserDefaults.Proxy) {
    proxy += 1
}


