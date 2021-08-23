import Foundation

/// The type to which all operations must conform in order to execute and cancel a request.
public protocol NetOperatingProtocol {
    associatedtype Output
    
    /// The request to be executed.
    var request: NetRequestProtocol { get }
    
    /// Execute a request using a dispatcher.
    /// - Parameters:
    ///   - dispatcher: `NetDispatcherProtocol` object that will execute the request.
    ///   - completion: Completion block.
    func execute(in dispatcher: NetDispatcherProtocol, completion: @escaping(Output) -> Void)
    
    /// Cancel the operation.
    func cancel()
}
