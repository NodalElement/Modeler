import Foundation

/// These options are used to determine when a `Keychain` item should be readable. The default value is `AccessibleWhenUnlocked`.
public enum KeychainAccessible {
    /// This is recommended for items that need to be accessible only while the application is in the foreground.
    /// Items with this attribute migrate to a new device when using encrypted backups.
    case accessibleWhenUnlocked
    
    /// This is recommended for items that need to be accessible only while the application is in the foreground.
    /// Items with this attribute do not migrate to a new device.
    /// Thus, after restoring from a backup of a different device, these items will not be present.
    case accessibleWhenUnlockedThisDeviceOnly
    
    /// After the first unlock, the data remains accessible until the next restart.
    /// This is recommended for items that need to be accessed by background applications.
    /// Items with this attribute migrate to a new device when using encrypted backups.
    case accessibleAfterFirstUnlock
    
    /// After the first unlock, the data remains accessible until the next restart.
    /// This is recommended for items that need to be accessed by background applications.
    /// Items with this attribute do not migrate to a new device.
    /// Thus, after restoring from a backup of a different device, these items will not be present.
    case accessibleAfterFirstUnlockThisDeviceOnly
    
    /// This is recommended for items that only need to be accessible while the application is in the foreground.
    /// Items with this attribute never migrate to a new device.
    /// After a backup is restored to a new device, these items are missing.
    /// No items can be stored in this class on devices without a passcode.
    /// Disabling the device passcode causes all items in this class to be deleted.
    case accessibleWhenPasscodeSetThisDeviceOnly
    
    /// Standard value.
    static var shared: KeychainAccessible { .accessibleWhenUnlocked }
    
    var value: String {
        switch self {
        case .accessibleWhenUnlocked:
            return String(kSecAttrAccessibleWhenUnlocked)
            
        case .accessibleWhenUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
            
        case .accessibleAfterFirstUnlock:
            return String(kSecAttrAccessibleAfterFirstUnlock)
            
        case .accessibleAfterFirstUnlockThisDeviceOnly:
            return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            
        case .accessibleWhenPasscodeSetThisDeviceOnly:
            return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        }
    }
    
}
