import Foundation

struct AtomicSemaphore<Value>: AtomicRepresentation {
    
    private let semaphore = DispatchSemaphore(value: 1)
    private var _value: Value
    
    init(_ value: Value) {
        _value = value
    }
    
    var value: Value {
        semaphore.lock { _value }
    }
    
    mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try semaphore.lock {
            try transform(&_value)
        }
    }
    
}

private extension DispatchSemaphore {
    
    func lock<T>(execute task: () throws -> T) rethrows -> T {
        wait()
        defer { signal() }
        return try task()
    }
    
}
