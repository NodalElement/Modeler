import Foundation

public final class Cache<Key: Hashable, Value> {
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date // Dependency injection with function.
    private let entryLifetime: TimeInterval // Default value of 12 hours.
    private let keyTracker = KeyTracker()
    
    public init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifetime: TimeInterval = 12 * 60 * 60,
        maximumEntryCount: Int = 50
    ) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    public subscript(forKey key: Key) -> Value? {
        get {
            return value(forKey: key)
        } set {
            // If nil was assigned using subscript, then we remove any value for that key.
            guard let value = newValue else { return removeValue(forKey: key) }
            
            insertValue(value, forKey: key)
        }
    }
    
}

private extension Cache {
    
    private func insertValue(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        insert(entry)
    }
    
    private func value(forKey key: Key) -> Value? {
        return entry(forKey: key)?.value
    }
    
    private func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
}

private extension Cache {
    // `WrappedKey` type will wrap our `Key` values in order to make them `NSCache` compatible.
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        override var hash: Int {
            key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }
    
    // The only requirement is that `Entry` needs to be a class.
    // It store a `Value` instance.
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
    
    // Dedicated `KeyTracker` type will become the delegate of our underlying `NSCache`,
    // in order to get notified whenever an entry was removed.
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry else { return }
            keys.remove(entry.key)
        }
    }
    
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable { }

private extension Cache {
    
    private func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }
        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired.
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    private func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
    
}

extension Cache: Codable where Key: Codable, Value: Codable {

    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }

}

extension Cache where Key: Codable, Value: Codable {
    
    public func saveToDisk(withName name: String, _ fileManager: FileManager = .default) throws {
        let folderURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        
        guard let fileURL = folderURL.first?.appendingPathComponent(name + ".cache") else { fatalError() }
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        try data.write(to: fileURL)
    }
    
}
