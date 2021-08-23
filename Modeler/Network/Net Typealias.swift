import Foundation

/// Type alias used for HTTP request headers.
public typealias NetRequestHeaders = [String: String]

/// Type alias used for HTTP request parameters. Used for query parameters for GET requests and in the HTTP body for POST, PUT and PATCH requests.
public typealias NetRequestParameters = [String: Any?]

/// Type alias used for the HTTP request download/upload progress.
public typealias NetProgressHandler = (Float) -> Void

/// Type alias used for the HTTP request completion.
public typealias DataTaskCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

/// Type alias used for the HTTP request download completion.
public typealias URLTaskCompletion = (_ url: URL?, _ response: URLResponse?, _ error: Error?) -> Void
