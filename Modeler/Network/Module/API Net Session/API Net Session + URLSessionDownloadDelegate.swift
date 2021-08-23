import Foundation

extension APINetSession: URLSessionDownloadDelegate {
    
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        
        guard let handler = getHandler(for: downloadTask) else { return }
        
        DispatchQueue.main.async { handler.completion?(location, downloadTask.response, downloadTask.error) }
        // Remove the associated handler.
        set(handler: nil, for: downloadTask)
    }
    
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        
        guard let handler = getHandler(for: downloadTask) else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async { handler.progress?(progress) }
    }
    
}
