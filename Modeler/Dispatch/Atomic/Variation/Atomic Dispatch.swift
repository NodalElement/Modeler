import Foundation

struct AtomicDispatch<Value>: AtomicRepresentation {
    
    private let queue = DispatchQueue(label: "com.Modeler.AtomicDispatch", attributes: .concurrent)
    private var _value: Value
    
    init(_ value: Value) {
        _value = value
    }
    
    var value: Value {
        queue.sync { _value }
    }
    
    mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try queue.sync(flags: .barrier) {
            try transform(&_value)
        }
    }
    
}
