import XCTest
@testable import Modeler

class AtomicTesting: XCTestCase {

    private let iteration = 1_000_000
    private enum State {
        case read
        case write
    }
 
    // MARK: - Invoke this method to run the test.
    func testExample() throws {
        var atomic = Atomic(value: 0, state: .lock)
        self.testing(atomic: &atomic, state: .read)
    }
    
    /// A function that handles the selected test state.
    private func testing<T: AtomicRepresentation>(atomic: inout T, state: State) where T.Value: BinaryInteger {
        switch state {
        case .read: self.readPerformance(atomic: &atomic)
        case .write: self.writePerformance(atomic: &atomic)
        }
    }
    
    /// Measure the time of the reading method.
    private func readPerformance<T: AtomicRepresentation>(atomic: inout T) where T.Value: BinaryInteger {
        self.measure {
            atomic.mutate { $0 = 0 } // Reset
            DispatchQueue.concurrentPerform(iterations: self.iteration) { (value) in
                XCTAssertGreaterThanOrEqual(atomic.value, 0)
                guard value.isMultiple(of: 1_000) else { return }
                atomic.mutate { $0 += 1 }
            }
            XCTAssertGreaterThanOrEqual(atomic.value, 0)
        }
    }
    
    /// Measure the time of the writing method.
    private func writePerformance<T: AtomicRepresentation>(atomic: inout T) where T.Value: BinaryInteger {
        self.measure {
            atomic.mutate { $0 = 0 } // Reset
            DispatchQueue.concurrentPerform(iterations: self.iteration) { (_) in
                atomic.mutate { $0 += 1 }
            }
            XCTAssertEqual(atomic.value.description, self.iteration.description)
        }
    }
    
}
