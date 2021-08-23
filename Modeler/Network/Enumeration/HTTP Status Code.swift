import Foundation

public enum HTTPStatusCode: Int {
    // MARK: - Success
    case ok                     = 200 // OK
    
    // MARK: - Client errors
    case badRequest             = 400 // Bad Request
    case unauthorized           = 401 // Unauthorized
    case forbidden              = 403 // Forbidden
    case notFound               = 404 // Not Found
    
    // MARK: - Server errors
    case internalServerError    = 500 // Internal Server Error
}
