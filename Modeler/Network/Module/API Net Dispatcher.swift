import Foundation

/// Class that handles the dispatch of requests to an environment with a given configuration.
public class APINetDispatcher: NetDispatcherProtocol {

    /// The environment configuration.
    private let environment: NetEnvironmentProtocol

    /// The network session configuration.
    private let session: NetSessionProtocol

    /// Required initializer.
    /// - Parameters:
    ///   - environment: Instance conforming to `NetEnvironmentProtocol` used to determine on which environment the requests will be executed.
    ///   - session: Instance conforming to `NetSessionProtocol` used for executing requests with a specific configuration.
    required public init(environment: NetEnvironmentProtocol, session: NetSessionProtocol) {
        self.environment = environment
        self.session = session
    }

    /// Executes a request.
    /// - Parameters:
    ///   - request: Instance conforming to `NetRequestProtocol`
    ///   - completion: Completion handler.
    public func execute(request: NetRequestProtocol, completion: @escaping (NetOperatingResult) -> Void) -> URLSessionTask? {
        // Create a URL request.
        guard var urlRequest = request.urlRequest(with: environment) else {
            completion(.error(APINetError.badRequest("Invalid URL for: \(request)"), nil))
            return nil
        }
        // Add the environment specific headers.
        environment.headers?.forEach({ (key: String, value: String) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        })

        // Create a URLSessionTask to execute the URLRequest.
        var task: URLSessionTask?
        switch request.requestType {
        case .data:
            task = session.dataTask(urlRequest)
            { [weak self] (data, response, error) in
                self?.handleJsonResponse(data: data, response: response, error: error, completion: completion)
            }
        case .download:
            task = session.downloadTask(urlRequest, progress: request.progressHandler)
            { [weak self] (fileURL, response, error) in
                self?.handleFileResponse(fileURL: fileURL, response: response, error: error, completion: completion)
            }
        case .upload:
            task = session.uploadTask(urlRequest, from: URL(fileURLWithPath: ""), progress: request.progressHandler)
            { [weak self] (data, response, error) in
                self?.handleJsonResponse(data: data, response: response, error: error, completion: completion)
            }
        }
        // Start the task.
        task?.resume()

        return task
    }

    /// Handles the data response that is expected as a JSON object output.
    /// - Parameters:
    ///   - data: The `Data` instance to be serialized into a JSON object.
    ///   - response: The received  optional `URLResponse` instance.
    ///   - error: The received  optional `Error` instance.
    ///   - completion: Completion handler.
    private func handleJsonResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping(NetOperatingResult) -> Void)
    {
        // Check if the response is valid.
        guard let response = response as? HTTPURLResponse else {
            return completion(.error(APINetError.invalidResponse, nil))
        }
        // Verify the HTTP status code.
        let result = verify(data: data, response: response, error: error)
        switch result {
        case .success(_): DispatchQueue.main.async { completion(.json(data, response)) }
        case .failure(let error): DispatchQueue.main.async { completion(.error(error, response)) }
        }
    }

    /// Handles the url response that is expected as a file saved ad the given URL.
    /// - Parameters:
    ///   - fileURL: The `URL` where the file has been downloaded.
    ///   - response: The received  optional `URLResponse` instance.
    ///   - error: The received  optional `Error` instance.
    ///   - completion: Completion handler.
    private func handleFileResponse(
        fileURL: URL?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (NetOperatingResult) -> Void)
    {
        guard let response = response as? HTTPURLResponse else {
            return completion(.error(APINetError.invalidResponse, nil))
        }
        let result = verify(data: fileURL, response: response, error: error)
        switch result {
        case .success(_): DispatchQueue.main.async { completion(.file(fileURL, response)) }
        case .failure(let error): DispatchQueue.main.async { completion(.error(error, response)) }
        }
    }

    /// Parses a `Data` object into a JSON object. Don't use it !!!
    /// - Parameter data: `Data` instance to be parsed.
    /// - Returns: A `Result` instance.
    private func parse(data: Data?) -> Result<Any?, Error> {
        guard let data = data else { return .failure(APINetError.invalidResponse) }

        do {
            let _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return .success(nil)
        } catch let exception {
            return .failure(APINetError.parse(exception.localizedDescription))
        }
    }

    /// Checks if the HTTP status code is valid and returns an error otherwise.
    /// - Parameters:
    ///   - data: The data or file  URL .
    ///   - response: The received  optional `URLResponse` instance.
    ///   - error: The received  optional `Error` instance.
    /// - Returns: A `Result` instance.
    private func verify(data: Any?, response: HTTPURLResponse, error: Error?) -> Result<Any?, Error> {
        switch response.statusCode {
        case 200...299:
            guard let _ = data else { return .failure(APINetError.noData) }
            return .success(nil)
        case 400...499:
            return .failure(APINetError.badRequest(error?.localizedDescription))
        case 500...599:
            return .failure(APINetError.server(error?.localizedDescription))
        default:
            return .failure(APINetError.unknown)
        }
    }
    
}
