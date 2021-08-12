import Foundation

struct AtomicSemaphore<Value>: AtomicRepresentation {
    
    private let semaphore = DispatchSemaphore(value: 1)
    private var _value: Value
    
    init(_ value: Value) {
        self._value = value
    }
    
    var value: Value {
        get {
            self.semaphore.lock { self._value }
        }
    }
    
    mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try self.semaphore.lock {
            try transform(&self._value)
        }
    }
    
}

private extension DispatchSemaphore {
    
    func lock<T>(execute task: () throws -> T) rethrows -> T {
        self.wait()
        defer { self.signal() }
        return try task()
    }
    
}
