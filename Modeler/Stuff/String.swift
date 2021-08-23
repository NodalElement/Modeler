import Foundation

extension String {
    /// Used to validate if a given string matches a pattern.
    func validate(with pattern: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
    
}
