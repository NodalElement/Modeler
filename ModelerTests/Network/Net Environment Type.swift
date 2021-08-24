import Modeler

extension NetEnvironmentType: NetEnvironmentProtocol {
    /// The default HTTP request headers for the given environment.
    public var headers: NetRequestHeaders? {
        switch self {
        case .development:
            return ["Content-Type": "application/json"]
        case .production:
            return [:]
        }
    }
    
    /// The base URL of the given environment.
    public var baseURL: String {
        switch self {
        case .development:
            return "https://stackoverflow.com"
        case .production:
            return "https://www.deepl.com"
        }
    }
    
}
