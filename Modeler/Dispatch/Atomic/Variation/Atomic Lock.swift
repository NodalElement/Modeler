import Foundation

class AtomicLock<Value>: AtomicRepresentation {
    
    private var mutex = os_unfair_lock_s()
    private var _value: Value
    
    required init(_ value: Value) {
        self._value = value
    }
    
    var value: Value {
        get {
            self.lock { self._value }
        }
    }
    
    func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try self.lock {
            try transform(&self._value)
        }
    }
    
    /// Tries to acquire a lock, blocking the thread until the process is done, and then releases the previously acquired lock.
    private func lock<T>(execute task: () throws -> T) rethrows -> T {
        os_unfair_lock_lock(&self.mutex)
        defer { os_unfair_lock_unlock(&self.mutex) }
        return try task()
    }
    
}
