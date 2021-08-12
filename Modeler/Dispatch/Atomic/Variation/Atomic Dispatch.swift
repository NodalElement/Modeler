import Foundation

struct AtomicDispatch<Value>: AtomicRepresentation {
    
    private let queue = DispatchQueue(label: "com.Modeler.AtomicDispatch", attributes: .concurrent)
    private var _value: Value
    
    init(_ value: Value) {
        self._value = value
    }
    
    var value: Value {
        get {
            self.queue.sync { self._value }
        }
    }
    
    mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try self.queue.sync(flags: .barrier) {
            try transform(&self._value)
        }
    }
    
}
