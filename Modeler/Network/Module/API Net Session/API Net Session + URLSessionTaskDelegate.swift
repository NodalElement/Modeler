import Foundation

extension APINetSession: URLSessionTaskDelegate {

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        
        guard let handler = getHandler(for: task) else { return }
        
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        DispatchQueue.main.async { handler.progress?(progress) }
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        
        if let downloadTask = task as? URLSessionDownloadTask,
           let handler = getHandler(for: downloadTask) {
            DispatchQueue.main.async { handler.completion?(nil, downloadTask.response, downloadTask.error) }
        }
        // Remove the associated handler.
        set(handler: nil, for: task)
    }
    
}
