import Combine
import SwiftUI

/// Pattern Validation is useful for situation like check in user e-mail.
/// You should keep a reference to this object like this: Set of AnyCancellable.
@available(iOS 13.0, *)
public final class PatternValidation: ObservableObject {
    
    public enum Pattern {
        case mail
        case value(String)
        
        fileprivate var text: String {
            switch self {
            case .mail:
                return "^[\\w!#$%&'*+/=?`{|}~^-]+(?:\\.[\\w!#$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}$"
            case .value(let value):
                return value
            }
        }
    }
    
    @Published public var text: String
    private let pattern: Pattern
    
    /// - Parameters:
    ///     - text: Text value for validation.
    ///     - pattern: Pattern value for text matching.
    public init(_ text: String = "", pattern: Pattern = .mail) {
        self.text = text
        self.pattern = pattern
    }
    
    public var publisher: AnyPublisher<Bool, Never> {
        $text.debounce(for: 0.6, scheduler: RunLoop.main)
            .map { [weak self] input in
                guard let self = self else { return false }
                return self.text.validate(with: self.pattern.text)
            }.removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}

/// Equal Validation is useful for situations such as validating two passwords.
/// You should keep a reference to this object like this: Set of AnyCancellable.
@available(iOS 13.0, *)
public final class EqualValidation<U: Comparable>: ObservableObject {
    
    @Published public var first: U
    @Published public var second: U
    
    /// - Parameters:
    ///     - first: First comparable value to validate on comparison.
    ///     - second: Second comparable value to validate on comparison.
    public init(_ first: U, _ second: U) {
        self.first = first
        self.second = second
    }
    
    public var publisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($first, $second)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
}

/// Count Validation is useful for situation like check in user name characters count.
/// You should keep a reference to this object like this: Set of AnyCancellable.
@available(iOS 13.0, *)
public final class CountValidation: ObservableObject {
    
    @Published public var text: String
    private let boundary: (min: Int, max: Int)
    
    /// - Parameters:
    ///     - text: Text value for validation.
    ///     - min: minimum number of characters in the text.
    ///     - max: maximum number of characters in the text.
    public init(_ text: String = "", min: Int = 3, max: Int = 255) {
        self.text = text
        boundary = (min: min, max: max)
    }
    
    public var publisher: AnyPublisher<Bool, Never> {
        $text.debounce(for: 0.6, scheduler: RunLoop.main)
            .map { [weak self] input in
                guard let self = self else { return false }
                return input.count >= self.boundary.min && input.count <= self.boundary.max
            }.removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
