import Foundation

/*
 One thing to keep in mind is if we pass a completion handler to either downloadTask(with: ) or uploadTask(with: ) and we implement the corresponding completion delegate methods, both the delegate completion method and the completion closures will be called by iOS.
 */

extension APINetSession: NetSessionProtocol {
    
    public func dataTask(_ request: URLRequest, completion: @escaping DataTaskCompletion) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        return dataTask
    }
    
    public func uploadTask(
        _ request: URLRequest,
        from fileURL: URL,
        progress: NetProgressHandler?,
        completion: @escaping DataTaskCompletion
    ) -> URLSessionUploadTask? {
        
        let uploadTask = session.uploadTask(with: request, fromFile: fileURL) { (data, response, error) in
            completion(data, response, error)
        }
        // Set the associated progress handler for this task.
        set(handler: (progress, nil), for: uploadTask)
        return uploadTask
    }
    
    public func downloadTask(
        _ request: URLRequest,
        progress: NetProgressHandler?,
        completion: @escaping URLTaskCompletion
    ) -> URLSessionDownloadTask? {
        
        let downloadTask = session.downloadTask(with: request)
        // Set the associated progress and completion handlers for this task.
        set(handler: (progress, completion), for: downloadTask)
        return downloadTask
    }
    
}
