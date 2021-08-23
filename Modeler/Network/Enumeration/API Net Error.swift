import Foundation

/// Enumeration of API Net Errors.
enum APINetError: Error {
    /// No data received from the server.
    case noData
    /// The server response was invalid (unexpected format).
    case invalidResponse
    /// The request was rejected: 400-499
    case badRequest(String?)
    /// Encountered a server error.
    case server(String?)
    /// There was an error parsing the data.
    case parse(String?)
    /// Unknown error.
    case unknown
}
