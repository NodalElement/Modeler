import Foundation

/// Protocol to which a net dispatcher must conform to.
public protocol NetDispatcherProtocol {
    /// Required initializer.
    /// - Parameters:
    ///   - environment: Instance conforming to `NetEnvironmentProtocol` used to determine on which environment the requests will be executed.
    ///   - session: Instance conforming to `NetSessionProtocol` used for executing requests with a specific configuration.
    init(environment: NetEnvironmentProtocol, session: NetSessionProtocol)
    
    /// Executes a request.
    /// - Parameters:
    ///   - request: Instance conforming to `NetRequestProtocol`
    ///   - completion: Completion handler.
    func execute(request: NetRequestProtocol, completion: @escaping(NetOperatingResult) -> Void) -> URLSessionTask?
}
