import XCTest
@testable import Modeler

@available(iOS 13.0, *)
final class FileStorageTesting: XCTestCase {
    
    private var sut: FileStorage?
    private let object = "Hello World! By Nodal Element"
    
    // These functions get called before each test.
    override func setUpWithError() throws {
        let queue = DispatchQueue(label: "FileStorageTesting", qos: .utility, attributes: .concurrent)
        sut = FileStorage(queue: queue)
        try super.setUpWithError()
    }
    
    // These functions get called after each test.
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Invoke this method to run the test.
    func testExample() throws {
        let key = "storage.testing"
        guard let value = object.data(using: .utf8) else { fatalError() }
        
        let expectation = self.expectation(description: UUID().uuidString)
        
        sut?.save(value: value, forKey: key) { [weak self] result in
            guard case .success(_) = result else { fatalError() }
            self?.fetchValue(forKey: key, with: expectation)
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    private func fetchValue(forKey key: String, with expectation: XCTestExpectation) {
        sut?.fetchValue(forKey: key) { [weak self] result in
            guard case let .success(data) = result,
                  let value = String(data: data, encoding: .utf8) else { fatalError() }
            XCTAssert(value == self?.object, value)
            expectation.fulfill()
        }
    }
    
}
