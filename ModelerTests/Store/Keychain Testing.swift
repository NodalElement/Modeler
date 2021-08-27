import XCTest
@testable import Modeler

@available(iOS 13.0, *)
final class KeychainTesting: XCTestCase {
    
    private var sut: Keychain!
    
    // These functions get called before each test.
    override func setUpWithError() throws {
        sut = Keychain(prefix: "NodalElement")
        try super.setUpWithError()
    }
    
    // These functions get called after each test.
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Invoke this method to run the test.
    func testExample() throws {
        // MARK: - Setter / Getter
        plain(value: "String to Keychain", forKey: "stringKey") // String
        plain(value: true, forKey: "booleanKey") // Bool
        plain(value: User(name: .pavel, age: 21, city: .moscow), forKey: "dataKey") // Data
    }
    
    // Testing to examine the action of the Keychain setter / getter.
    func plain<Value: Codable>(value: Value, forKey key: String) where Value: Equatable {
        XCTAssertTrue(sut.set(value, forKey: key)) // Set value to Keychain.
        let newValue: Value? = sut.get(forKey: key) // Fetch value from Keychain.
        XCTAssert(value == newValue, "newValue: \(newValue!)")
    }
    
}
