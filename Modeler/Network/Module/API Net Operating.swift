import Foundation

/// API Net Operating class that can execute and cancel a request.
public class APINetOperating: NetOperatingProtocol {
    /// The `URLSessionTask` to be executed.
    private var task: URLSessionTask?
    
    /// Instance conforming to the `NetRequestProtocol`.
    public var request: NetRequestProtocol
    
    /// Designated initializer.
    /// - Parameter request: Instance conforming to the `NetRequestProtocol`.
    public init(_ request: NetRequestProtocol) {
        self.request = request
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    public func execute(in dispatcher: NetDispatcherProtocol, completion: @escaping(NetOperatingResult) -> Void) {
        task = dispatcher.execute(request: request, completion: completion)
    }
    
}
