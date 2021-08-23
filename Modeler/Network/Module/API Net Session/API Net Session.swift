import Foundation

/// Class handling the creation of URLSessionTask and responding to URLSessionDelegate callbacks.
public class APINetSession: NSObject {
    /// The URLSession handing the URLSessionTaks.
    var session: URLSession!
    
    /// A typealias describing a progress and completion handle tuple.
    typealias ProgressAndCompletion = (progress: NetProgressHandler?, completion: URLTaskCompletion?)
    
    /// Dictionary containing associations of `ProgressAndCompletion` to `URLSessionTask` instances.
    var association: [URLSessionTask: ProgressAndCompletion] = [:]
    
    /// Convenience initializer.
    public override convenience init() {
        // Configure the default URLSessionConfiguration.
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = 30
        sessionConfiguration.waitsForConnectivity = true
        
        // Create a `OperationQueue` instance for scheduling the delegate calls and completion handlers.
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInitiated
        
        // Call the designated initializer.
        self.init(configuration: sessionConfiguration, delegateQueue: queue)
    }
    
    /// Designated initializer.
    /// - Parameters:
    ///   - configuration: `URLSessionConfiguration` instance.
    ///   - delegateQueue: `OperationQueue` instance for scheduling the delegate calls and completion handlers.
    public init(configuration: URLSessionConfiguration, delegateQueue: OperationQueue) {
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }
    
    /// Associates a `URLSessionTask` instance with its `ProgressAndCompletion`
    /// - Parameters:
    ///   - handlers:   `ProgressAndCompletion` tuple.
    ///   - task:       `URLSessionTask` instance.
    func set(handler: ProgressAndCompletion?, for task: URLSessionTask) {
        association[task] = handler
    }
    
    /// Fetches the `ProgressAndCompletion` for a given `URLSessionTask`.
    /// - Parameter task:   `URLSessionTask` instance.
    /// - Returns:          `ProgressAndCompletion` optional instance.
    func getHandler(for task: URLSessionTask) -> ProgressAndCompletion? {
        return association[task]
    }
    
    // We have to invalidate the session because URLSession strongly retains its delegate.
    deinit {
        session.invalidateAndCancel()
        session = nil
    }
    
}
