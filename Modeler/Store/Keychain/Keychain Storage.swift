import SwiftUI

@available(iOS 13.0, *)
@propertyWrapper
public struct KeychainStorage<Value: Codable>: DynamicProperty {
    
    private let key: String
    @State private var defaultValue: Value?
    private let keychain: Keychain
    
    /// Creates a new `Keychain` property wrapper for the given key.
    /// - Parameter key: The key to use with the `Keychain` store.
    public init(key: String, defaultValue: Value? = nil, keychain: Keychain = .init()) {
        self.key = key
        self.keychain = keychain
        self._defaultValue = State(initialValue: keychain.get(forKey: key))
    }
    
    public var wrappedValue: Value? {
        get {
            defaultValue
        } nonmutating set {
            defaultValue = newValue
            saveToKeychain(forKey: key, newValue)
        }
    }
    
    public var projectedValue: Binding<Value?> {
        Binding { wrappedValue }
            set: { wrappedValue = $0 }
    }
    
    /// Set/Update object for key to `Keychain`.
    private func saveToKeychain(forKey key: String, _ newValue: Value?) {
        if newValue == nil {
            keychain.delete(forKey: key)
        } else {
            keychain.set(newValue, forKey: key)
        }
    }
    
}
