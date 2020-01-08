//
//  UserDefaultsExtension.swift
//  Fluor
//
//

import Foundation

public protocol DefaultCodable: Codable { }

public extension UserDefaults {
    
    /// Sets the value of the specified default key to the specified `RawReprensantable` value.
    /// - Parameters:
    ///   - value: The value to store in the defaults database.
    ///   - defaultName: The key with which to associate the value.
    func set<T: RawRepresentable>(_ value: T, forKey defaultName: String) {
        self.set(value.rawValue, forKey: defaultName)
    }
    
    /// Returns the `RawReprensentable` value associated with the specified key.
    /// - Parameter defaultName: A key in the current user‘s defaults database.
    func rawReprensentable<T: RawRepresentable>(forKey defaultName: String) -> T? {
        (self.value(forKey: defaultName) as? T.RawValue).flatMap { T(rawValue: $0) }
    }
    
    func encode<T: DefaultCodable>(_ value: T, forKey defaultName: String) {
        self.set(UserDefaults.encodeToData(value), forKey: defaultName)
    }
    
    func decode<T: DefaultCodable>(forKey defaultName: String) -> T? {
        self.data(forKey: defaultName).flatMap { try? JSONDecoder().decode(T.self, from: $0) }
    }
    
    func register(_ value: Any, forKey defaultName: String) {
        self.register(defaults: [defaultName: value])
    }
    
    func register<T: DefaultCodable>(_ value: T, forKey defaultName: String) {
        self.register(UserDefaults.encodeToData(value), forKey: defaultName)
    }
    
    private static func encodeToData<T: Encodable>(_ value: T) -> Data {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(value)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}

@propertyWrapper
public struct DefaultValue<Element> {
    public typealias DefaultValueProvider = () -> Element
    
    private let getter: () -> Element
    private let setter: (Element) -> ()
    
    public var wrappedValue: Element {
        get { self.getter() }
        nonmutating set { self.setter(newValue) }
    }
    
    public init(key: String, defaultValue: @escaping @autoclosure DefaultValueProvider, defaults: UserDefaults = .standard) {
        let defaultName = key
        
        self.getter = { defaults.object(forKey: defaultName) as? Element ?? defaultValue() }
        self.setter = { defaults.set($0, forKey: defaultName) }
        
        defaults.register(defaultValue(), forKey: defaultName)
    }
    
    public init<KeyType: RawRepresentable>(key: KeyType, defaultValue: @escaping @autoclosure DefaultValueProvider, defaults: UserDefaults = .standard) where KeyType.RawValue == String {
        let defaultName = key.rawValue
        
        self.getter = { defaults.object(forKey: defaultName) as? Element ?? defaultValue() }
        self.setter = { defaults.set($0, forKey: defaultName) }
        
        defaults.register(defaultValue(), forKey: defaultName)
    }
}

public extension DefaultValue where Element: RawRepresentable {
    init(key: String, defaultValue: @escaping @autoclosure DefaultValueProvider, defaults: UserDefaults = .standard) {
        let defaultName = key
        
        self.getter = { defaults.rawReprensentable(forKey: defaultName) ?? defaultValue() }
        self.setter = { defaults.set($0, forKey: defaultName) }
        
        defaults.register(defaultValue().rawValue, forKey: defaultName)
    }
    
    init<KeyType: RawRepresentable>(key: KeyType, defaultValue: @escaping @autoclosure DefaultValueProvider, defaults: UserDefaults = .standard) where KeyType.RawValue == String {
        let defaultName = key.rawValue
        
        self.getter = { defaults.rawReprensentable(forKey: defaultName) ?? defaultValue() }
        self.setter = { defaults.set($0, forKey: defaultName) }
        
        defaults.register(defaultValue().rawValue, forKey: defaultName)
    }
}

public extension DefaultValue where Element: DefaultCodable {
    init(key: String, defaultValue: @escaping @autoclosure DefaultValueProvider, defaults: UserDefaults = .standard) {
        let defaultName = key
        
        self.getter = { defaults.decode(forKey: defaultName) ?? defaultValue() }
        self.setter = { defaults.encode($0, forKey: defaultName) }
        
        defaults.register(defaultValue(), forKey: defaultName)
    }
    
    init<KeyType: RawRepresentable>(key: KeyType, defaultValue: @escaping @autoclosure DefaultValueProvider, defaults: UserDefaults = .standard) where KeyType.RawValue == String {
        let defaultName = key.rawValue
        
        self.getter = { defaults.decode(forKey: defaultName) ?? defaultValue() }
        self.setter = { defaults.encode($0, forKey: defaultName) }
        
        defaults.register(defaultValue(), forKey: defaultName)
    }
}
