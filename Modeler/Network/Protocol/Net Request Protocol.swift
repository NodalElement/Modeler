import Foundation

/// Protocol to which the HTTP requests must conform.
public protocol NetRequestProtocol {
    /// The path that will be appended to API's base URL.
    var path: String { get }
    
    /// The HTTP method.
    var method: NetRequestMethod { get }
    
    /// The HTTP headers.
    var headers: NetRequestHeaders? { get }
    
    /// The request parameters used for query parameters for GET requests and in the HTTP body for POST, PUT and PATCH requests.
    var parameters: NetRequestParameters? { get }
    
    /// The request type.
    var requestType: NetRequestType { get }
    
    /// The expected response type.
    var responseType: NetResponseType { get }
    
    /// Upload/download progress handler.
    var progressHandler: NetProgressHandler? { get set }
}

extension NetRequestProtocol {
    /// Creates a URLRequest from this instance.
    /// - Parameter environment: The environment against which the `URLRequest` must be constructed.
    /// - Returns: An optional `URLRequest`.
    public func urlRequest(with environment: NetEnvironmentProtocol) -> URLRequest? {
        // Create the base URL.
        guard let url = url(with: environment.baseURL) else { return nil }
        // Create a request with that URL.
        var request = URLRequest(url: url)
        // Append all related properties.
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonBody
        
        return request
    }
    
    /// Creates a URL with the given base URL.
    /// - Parameter baseURL: The base URL string.
    /// - Returns: An optional `URL`.
    private func url(with baseURL: String) -> URL? {
        // Create a URLComponents instance to compose the url.
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        // Add the request path to the existing base URL path
        urlComponents.path = urlComponents.path + path
        // Add query items to the request URL
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
    
    /// Returns the URLRequest `URLQueryItem`.
    private var queryItems: [URLQueryItem]? {
        // Check if it is a GET method.
        guard method == .get,
              let parameters = self.parameters else { return nil }
        // Convert parameters to query items.
        return parameters.map { (key: String, value: Any?) -> URLQueryItem in
            let stringValue = String(describing: value)
            return URLQueryItem(name: key, value: stringValue)
        }
    }
    
    /// Returns the URLRequest body `Data`.
    private var jsonBody: Data? {
        // The body data should be used for POST, PUT and PATCH only.
        guard [.post, .put, .patch].contains(method),
              let parameters = self.parameters else { return nil }
        // Convert parameters to JSON data.
        do {
            return try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            return nil
        }
    }
    
}
