import Foundation

/// The expected result of the network API.
public enum NetOperatingResult {
    /// JSON response.
    case json(_ : Data?, _ : HTTPURLResponse?)
    /// A downloaded file with an URL.
    case file(_ : URL?, _ : HTTPURLResponse?)
    /// An error.
    case error(_ : Error?, _ : HTTPURLResponse?)
}
