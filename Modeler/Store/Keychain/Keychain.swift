import Foundation

typealias KeychainDictionary = [String: Any]

/// A collection of helper functions for saving text and data in the `Keychain`.
open class Keychain {
    /// Contains result code from the last operation. Value is `noErr` for a successful result.
    open var resultCode: OSStatus = noErr
    
    /// Specify an access group that will be used to access keychain items.
    /// Access groups can be used to share keychain items between applications.
    open var accessGroup: String?
    
    /// Specifies whether the items can be synchronized with other devices through iCloud.
    open var synchronizable: Bool = false
    
    /// The lock prevents the code to be run simultaneously from multiple threads which may result in crashing.
    private var lock = os_unfair_lock_s()
    
    /// A prefix that is added before the key in get/set methods.
    let prefix: String
    
    /// Check the latest query parameters.
    var lastQuery: KeychainDictionary?
    
    /// Instantiate a `Keychain` object.
    /// - Parameter prefix: A prefix that is added before the key in get/set methods. Note that `clear` method still clears everything from the Keychain.
    public init(prefix: String = "") {
        self.prefix = prefix
    }
    
    /// Stores the data in the keychain item under the given key.
    /// - Parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .accessibleWhenUnlocked.
    /// - Returns: True if the value was successfully written to the keychain.
    @discardableResult
    open func set<Value: Codable>(_ value: Value, forKey key: String, withAccess access: KeychainAccessible? = nil) -> Bool {
        lock {
            guard let data = try? JSONEncoder().encode(value) else { return false }
            
            delete(key) // Delete any existing key before saving it.
            
            var query: KeychainDictionary = [
                KeychainProperties.object: kSecClassGenericPassword,
                KeychainProperties.account: adjustKey(key),
                KeychainProperties.valueData: data,
                KeychainProperties.accessible: access?.value ?? KeychainAccessible.shared.value
            ]
            adjustQuery(&query, isSynchronized: true)
            
            resultCode = SecItemAdd(query as CFDictionary, nil)
            return resultCode == noErr
        }
    }
    
    /// Retrieves the data from the keychain that corresponds to the given key.
    /// - Returns: The data value from the keychain. Returns nil if unable to read the item.
    open func get<Value: Codable>(forKey key: String) -> Value? {
        lock {
            var query: KeychainDictionary = [
                KeychainProperties.object: kSecClassGenericPassword,
                KeychainProperties.account: adjustKey(key),
                KeychainProperties.matchLimit: kSecMatchLimitOne
            ]
            query[KeychainProperties.returnData] = kCFBooleanTrue // To avoid the kCFBooleanTrue warning.
            
            var result: AnyObject?
            guard handler(&query, result: &result), let data = result as? Data else { return nil }
            
            guard let value = try? JSONDecoder().decode(Value.self, from: data) else {
                resultCode = errSecInvalidEncoding
                return nil
            }
            return value
        }
    }
    
    /// Return all keys from keychain.
    /// - Returns: A string array with all keys from the keychain.
    open var allKeys: [String]? {
        lock {
            var query: KeychainDictionary = [
                KeychainProperties.object: kSecClassGenericPassword,
                KeychainProperties.returnData: true,
                KeychainProperties.returnAttributes: true,
                KeychainProperties.returnPersistentReference: true,
                KeychainProperties.matchLimit: KeychainProperties.matchLimitAll
            ]
            
            var result: AnyObject?
            guard handler(&query, result: &result), let result = result as? [KeychainDictionary] else { return nil }
            
            return result.compactMap { $0[KeychainProperties.account] as? String }
        }
    }
    
    /// Deletes all Keychain items used by the app. Note that this method deletes all items regardless of the prefix settings used for initializing the class.
    /// - Returns: True if the keychain items were successfully deleted.
    @discardableResult
    open func clear() -> Bool {
        lock { delete() }
    }
    
    /// Deletes the single keychain item specified by the key.
    /// - Returns: True if the item was successfully deleted.
    @discardableResult
    open func delete(forKey key: String) -> Bool {
        lock { delete(key) }
    }
        
}

extension Keychain {
    /// Returns the key with currently set prefix.
    func adjustKey(_ key: String) -> String {
        String(describing: prefix + key)
    }
    
    /// Additional adjustments for a given `KeychainDictionary`.
    /// - Parameter isSynchronized: Use `true` when the query will be used with `SecItemAdd` method (adding a keychain item).
    func adjustQuery(_ query: inout KeychainDictionary, isSynchronized: Bool = false) {
        defer { lastQuery = query }
        
        if let accessGroup = accessGroup { query[KeychainProperties.accessGroup] = accessGroup }
        
        if synchronizable { query[KeychainProperties.synchronizable] = isSynchronized ? true : kSecAttrSynchronizableAny }
    }
    
    private func handler(_ query: inout KeychainDictionary, result: inout AnyObject?) -> Bool {
        adjustQuery(&query)
        
        resultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        return resultCode == noErr
    }
    
    /// Same as `delete` but is only accessed internally, since it is not thread safe.
    /// - Parameter key: Use `nil` when you want to delete all data.
    /// - Returns: True if the delete function succeeded.
    @discardableResult
    private func delete(_ key: String? = nil) -> Bool {
        var query: KeychainDictionary = [KeychainProperties.object: kSecClassGenericPassword]
        if let key = key { query[KeychainProperties.account] = adjustKey(key) }
        adjustQuery(&query)
        
        resultCode = SecItemDelete(query as CFDictionary)
        return resultCode == noErr
    }
    
    private func lock<T>(execute task: () -> T) -> T {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return task()
    }
    
}
