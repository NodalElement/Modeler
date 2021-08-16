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
            anyAtomic = AnyAtomic(AtomicDispatch(value))
        case .semaphore:
            anyAtomic = AnyAtomic(AtomicSemaphore(value))
        case .lock:
            anyAtomic = AnyAtomic(AtomicLock(value))
        }
    }
    
    public var value: Value { anyAtomic.value }
    
    public mutating func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try anyAtomic.mutate(transform)
    }
    
}
