import Foundation

/// Protocol to which environments must conform.
public protocol NetEnvironmentProtocol {
    /// The default HTTP request headers for the environment.
    var headers: NetRequestHeaders? { get }
    
    /// The base URL of the environment.
    var baseURL: String { get }
}

public enum NetEnvironmentType {
    /// The development environment.
    case development
    /// The production environment.
    case production
}
