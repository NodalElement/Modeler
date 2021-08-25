import Foundation

public final class CodableStorage {
    
    private let storage: Storable
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(
        storage: Storable,
        decoder: JSONDecoder = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.storage = storage
        self.decoder = decoder
        self.encoder = encoder
    }
    
    public func fetchValue<T: Decodable>(forKey key: String) throws -> T {
        let data = try storage.fetchValue(forKey: key)
        return try decoder.decode(T.self, from: data)
    }
    
    public func save<T: Encodable>(value: T, forKey key: String) throws {
        let data = try encoder.encode(value)
        try storage.save(value: data, forKey: key)
    }
    
}
