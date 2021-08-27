import Foundation

/// Properties used by the `Keychain` library.
public struct KeychainProperties {
    /// A key whose value is a string indicating the access group an item is in.
    public static var accessGroup: String { String(kSecAttrAccessGroup) }
    
    /// A key whose value indicates when a keychain item is accessible.
    public static var accessible: String { String(kSecAttrAccessible) }
    
    /// A key whose value is a string indicating the item's account name.
    public static var account: String { String(kSecAttrAccount) }
    
    /// A key whose value is a string indicating whether the item is synchronized through iCloud.
    public static var synchronizable: String { String(kSecAttrSynchronizable) }
    
    /// A dictionary key whose value is the item's class.
    public static var object: String { String(kSecClass) }
    
    /// A key whose value indicates the match limit.
    public static var matchLimit: String { String(kSecMatchLimit) }
    
    /// A key whose value is a Boolean indicating whether or not to return item data.
    public static var returnData: String { String(kSecReturnData) }
    
    /// A key whose value is the item's data.
    public static var valueData: String { String(kSecValueData) }
    
    /// A key whose value is a Boolean indicating whether or not to return a persistent reference to an item.
    public static var returnPersistentReference: String { String(kSecReturnPersistentRef) }
    
    /// A key whose value is a Boolean indicating whether or not to return item attributes.
    public static var returnAttributes: String { String(kSecReturnAttributes) }
    
    /// A value that corresponds to matching an unlimited number of items.
    public static var matchLimitAll: String { String(kSecMatchLimitAll) }
    
}
