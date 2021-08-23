import Foundation

/// Protocol to which network session handling classes must conform to. The caller is responsible for calling resume().
/// - Parameters:
///   - request: `URLRequest` object.
///   - fileURL: The source file `URL`.
///   - progress: Optional `NetProgressHandler` callback.
///   - completion: The completion handler for the upload task.
public protocol NetSessionProtocol {
    /// Create  a URLSessionDataTask.
    func dataTask(_ request : URLRequest, completion: @escaping DataTaskCompletion) -> URLSessionDataTask?
    
    /// Create  a URLSessionDownloadTask.
    func downloadTask(
        _ request: URLRequest,
        progress: NetProgressHandler?,
        completion: @escaping URLTaskCompletion
    ) -> URLSessionDownloadTask?
    
    /// Create  a URLSessionUploadTask.
    func uploadTask(
        _ request: URLRequest,
        from fileURL: URL,
        progress: NetProgressHandler?,
        completion: @escaping DataTaskCompletion
    ) -> URLSessionUploadTask?
    
}
