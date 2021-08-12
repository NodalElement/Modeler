import Foundation

protocol AtomicRepresentation {
    associatedtype Value
    init(_ value: Value)
    var value: Value { get }
    mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T
}

extension AtomicRepresentation {
    
    init(_ value: Value) {
        fatalError()
    }
    
}
