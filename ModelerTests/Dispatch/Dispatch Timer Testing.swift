import XCTest
import Combine
@testable import Modeler

@available(iOS 13.0, *)
class DispatchTimerTesting: XCTestCase {
    /// System under test: `DispatchTimer`.
    private var sut: DispatchTimer!
    private var countdown = 5
    private var subscriber: AnyCancellable?
    
    // These functions get called before each test.
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DispatchTimer(0, repeating: 1)
    }
    
    // These functions get called after each test.
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Invoke this method to run the test.
    func testExample() throws {
        let expectation = self.expectation(description: UUID().uuidString)
        let expectedValue = 1
        
        subscriber = sut.sink(receiveCompletion: { [weak expectation] completion in
            guard case .failure(_) = completion else { return }
            expectation?.fulfill()
        }, receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.countdown -= 1
            if self.countdown == expectedValue { self.sut.cancel() }
        })
        messing()
        
        let timeInterval = TimeInterval(countdown)
        wait(for: [expectation], timeout: timeInterval)
        XCTAssertEqual(countdown, expectedValue)
    }
    
    private func messing() {
        sut.activate()
        suspend()
        resume()
    }
    
    /// Suspend `DispatchTimer`.
    private func suspend() {
        for _ in 0...4 { sut.suspend() }
    }
    
    /// Resume `DispatchTimer`.
    private func resume() {
        for _ in 0 ... 4 { sut.resume() }
    }
    
}
