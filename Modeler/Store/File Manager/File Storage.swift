import Foundation

public typealias Handler<T> = (Result<T, Error>) -> Void
public typealias Storable = ReadableStorage & WritableStorage

public protocol ReadableStorage {
    func fetchValue(forKey key: String) throws -> Data
    func fetchValue(forKey key: String, handler: @escaping Handler<Data>)
}

public protocol WritableStorage {
    func save(value: Data, forKey key: String) throws
    func save(value: Data, forKey key: String, handler: @escaping Handler<Data>)
}

public final class FileStorage {
    
    private let queue: DispatchQueue
    private let fileManager: FileManager
    private let path: URL
    
    public enum Failure: Error {
        case notFound
        case write(Error)
    }
    
    public init(
        path: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
        queue: DispatchQueue = .init(label: "DiskStorage.DispatchQueue.NodalElement"),
        fileManager: FileManager = FileManager.default
    ) {
        self.path = path
        self.queue = queue
        self.fileManager = fileManager
    }
    
}

extension FileStorage: Storable {
    
    public func save(value: Data, forKey key: String) throws {
        let url = path.appendingPathComponent(key)
        do {
            try self.createFolder(with: url)
            try value.write(to: url, options: .atomic)
        } catch {
            throw Failure.write(error)
        }
    }
    
    public func save(value: Data, forKey key: String, handler: @escaping Handler<Data>) {
        queue.async {
            do {
                try self.save(value: value, forKey: key)
                handler(.success(value))
            } catch {
                handler(.failure(error))
            }
        }
    }
    
    public func fetchValue(forKey key: String) throws -> Data {
        let url = path.appendingPathComponent(key)
        guard let data = fileManager.contents(atPath: url.path) else { throw Failure.notFound }
        return data
    }
    
    public func fetchValue(forKey key: String, handler: @escaping Handler<Data>) {
        queue.async {
            do {
                let data = try self.fetchValue(forKey: key)
                handler(.success(data))
            } catch {
                handler(.failure(error))
            }
        }
    }
    
    private func createFolder(with url: URL) throws {
        let folderURL = url.deletingLastPathComponent()
        guard !fileManager.fileExists(atPath: folderURL.path) else { return }
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
}
