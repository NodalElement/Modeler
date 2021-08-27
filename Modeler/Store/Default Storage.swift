import Combine

@available(iOS 13.0, *)
@propertyWrapper
public struct DefaultStorage<Value: Codable> {
    
    private let key: String
    private let container: UserDefaults
    private let defaultValue: Value
    private let subject = PassthroughSubject<Value, Never>()
    
    /// Creates a new `UserDefaults` property wrapper for the given key.
    /// - Parameter key: The key to use with the `UserDefaults` store.
    public init(key: String, defaultValue: Value, _ container: UserDefaults = .standard) {
        self.key = key
        self.container = container
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value {
        get { getter() }
        set { setter(newValue) }
    }
    
    public var projectedValue: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    
    /// Get object for key from `UserDefaults`.
    private func getter() -> Value {
        let value = try? container.getObject(Value.self, key: key)
        return value ?? defaultValue
    }
    
    /// Set/Update object for key to `UserDefaults`.
    private func setter(_ newValue: Value) {
        // Check whether we're dealing with an optional and remove the object if the new value is nil.
        if let optional = newValue as? Optionality, optional.isNil {
            container.removeObject(forKey: key)
        } else {
            try? container.setObject(newValue, key: key)
        }
        subject.send(newValue)
    }
    
}

// MARK: - DefaultStorage where 'Value' is NilLiteral.

@available(iOS 13.0, *)
extension DefaultStorage where Value: ExpressibleByNilLiteral {
    /// Creates a new `UserDefaults` property wrapper for the given key.
    /// - Parameter key: The key to use with the `UserDefaults` store.
    public init(key: String, _ container: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, container)
    }
    
}
