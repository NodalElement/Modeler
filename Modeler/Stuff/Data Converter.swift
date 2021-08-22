import Foundation

/// An error that may occur during the conversion process.
public enum DataConvertibleError: String, Error {
    case decode = "An error occurred while decoding the value."
    case noData = "There is no data."
}

/// Protocol that a custom structure or class must conform to to create a converter.
public protocol DataConvertible {
    associatedtype Model: Decodable
    func convert(from data: Data?) throws -> Model?
}

/// Data converter for custom structure or class.
public struct DataConverter<T: Decodable>: DataConvertible {
    
    public init(_ entity: T.Type) { }
    
    public func convert(from data: Data?) throws -> T? {
        guard let data = data else { throw DataConvertibleError.noData }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw DataConvertibleError.decode
        }
    }
    
}

// MARK: - String Converter.
extension String: DataConvertible {
    /// Data to string converter.
    public func convert(from data: Data?) throws -> String? {
        guard let data = data else { throw DataConvertibleError.noData }
        guard let string = String(data: data, encoding: .utf8) else { throw DataConvertibleError.decode }
        
        return string
    }
    
}
