import Foundation

// MARK: - Any Atomic Box
private class AnyAtomicBox<Value>: AtomicRepresentation {
    // fatalError(): used to plug any hole in type signatures
    var value: Value {
        fatalError()
    }
    
    func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        fatalError()
    }
    
}

// MARK: - Atomic Box
private class AtomicBox<U: AtomicRepresentation>: AnyAtomicBox<U.Value> {
    
    private var representation: U
    
    init(_ representation: U) {
        self.representation = representation
    }
    
    override var value: Value {
        get {
            return self.representation.value
        }
    }
    
    override func mutate<T>(_ transform: (inout U.Value) throws -> T) rethrows -> T {
        try self.representation.mutate(transform)
    }
    
}

// MARK: - Any Atomic - (Atomic Erasure)
class AnyAtomic<Value>: AtomicRepresentation {
    
    private let atomicBox: AnyAtomicBox<Value>
    
    init<U: AtomicRepresentation>(_ representation: U) where U.Value == Value {
        self.atomicBox = AtomicBox(representation)
    }
    
    var value: Value {
        get {
            return self.atomicBox.value
        }
    }
    
    func mutate<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try self.atomicBox.mutate(transform)
    }
    
}
