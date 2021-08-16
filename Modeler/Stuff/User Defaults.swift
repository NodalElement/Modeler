import Foundation

public extension UserDefaults {
    /// Failures for `UserDefaults` function.
    enum Failure: String, Error {
        case encode = "An error occurred while encoding the value."
        case decode = "An error occurred while decoding the value."
        case noData = "There is no data."
    }
    
    /// Set/Update object for key to `UserDefaults`.
    func setObject<T: Encodable>(_ object: T, key: String) throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            set(data, forKey: key)
        } catch {
            throw Failure.encode
        }
    }
    
    /// Get object for key from `UserDefaults`.
    func getObject<T: Decodable>(_ type: T.Type, key: String) throws -> T? {
        guard let data = data(forKey: key) else { throw Failure.noData }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            throw Failure.decode
        }
    }
    
}
