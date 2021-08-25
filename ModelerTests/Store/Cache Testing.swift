import XCTest
@testable import Modeler

@available(iOS 13.0, *)
final class CacheTesting: XCTestCase {
    
    private var sut: Cache<String, User>!
    
    // These functions get called before each test.
    override func setUpWithError() throws {
        sut = Cache()
        try super.setUpWithError()
    }
    
    // These functions get called after each test.
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    /// Invoke this method to run the test.
    func testExample() throws {
        let maria = User(name: .maria, age: 20, city: .kazan)
        let pavel = User(name: .pavel, age: 21, city: .moscow)
        let alexandra = User(name: .alexandra, age: 22, city: .petersburg)
        
        insertValue(maria)
        insertValue(pavel)
        insertValue(alexandra)
        isEqual(3)
        
        try sut.saveToDisk(withName: "NodalElement")
        
        removeValue(maria)
        removeValue(pavel)
        removeValue(alexandra)
        isEqual(0)
        
        sut = try sut.fetchFromDisk(withName: "NodalElement")
        isEqual(3)
    }
    
    private func insertValue(_ user: User) {
        sut[forKey: user.id] = user
        XCTAssert(sut[forKey: user.id] == user)
    }
    
    private func removeValue(_ user: User) {
        sut[forKey: user.id] = nil
        XCTAssertNil(sut[forKey: user.id])
    }
    
    private func isEqual(_ count: Int) {
        XCTAssert(sut.count == count, "count: \(sut.count)")
    }
    
}
