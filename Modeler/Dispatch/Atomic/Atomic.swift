import Foundation

public struct Atomic<Value>: AtomicRepresentation {
    
    private let anyAtomic: AnyAtomic<Value>
    
    public enum State {
        case dispatch
        case semaphore
        case lock
    }
    
    public init(value: Value, state: State = .lock) {
        switch state {
        case .dispatch:
            self.anyAtomic = AnyAtomic(AtomicDispatch(value))
        case .semaphore:
            self.anyAtomic = AnyAtomic(AtomicSemaphore(value))
        case .lock:
            self.anyAtomic = AnyAtomic(AtomicLock(value))
        }
    }
    
    public var value: Value {
        get {
            return self.anyAtomic.value
        }
    }
    
    public mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try self.anyAtomic.mutate(transform)
    }
    
}
