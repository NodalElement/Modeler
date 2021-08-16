import Foundation

final class AtomicLock<Value>: AtomicRepresentation {
    
    private var mutex = os_unfair_lock_s()
    private var _value: Value
    
    required init(_ value: Value) {
        _value = value
    }
    
    var value: Value {
        lock { _value }
    }
    
    func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try lock {
            try transform(&_value)
        }
    }
    
    /// Tries to acquire a lock, blocking the thread until the process is done, and then releases the previously acquired lock.
    private func lock<T>(execute task: () throws -> T) rethrows -> T {
        os_unfair_lock_lock(&mutex)
        defer { os_unfair_lock_unlock(&mutex) }
        return try task()
    }
    
}
