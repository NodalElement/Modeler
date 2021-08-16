import Foundation

/// Allows to match for optionals with generics that are defined as non-optional.
protocol Optionality {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
    
}

// MARK: - Conforming Optional to Optionality protocol.

extension Optional: Optionality {
    
    var isNil: Bool { self == nil }
    
}
