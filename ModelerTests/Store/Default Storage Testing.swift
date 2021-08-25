import XCTest
import Combine
@testable import Modeler

@available(iOS 13.0, *)
final class DefaultStorageTesting: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Invoke this method to run the test.
    func testExample() throws {
        var user = DefaultStorage(key: "user", defaultValue: User(name: .pavel, age: 25, city: .petersburg))
        let newValue = User(name: .maria, age: 20, city: .moscow)
        
        changeDefaultStorage(&user, newValue: newValue)
        
        XCTAssert(user.wrappedValue.name == newValue.name, "Test failed!")
    }
    
    private func changeDefaultStorage<Value: Equatable>(_ defaultStorage: inout DefaultStorage<Value>, newValue: Value) {
        // Receive a notification about the change.
        defaultStorage.projectedValue.sink { value in
            XCTAssert(value == newValue, "Received value: \(value)")
        }.store(in: &cancellables)
        // Change the value.
        defaultStorage.wrappedValue = newValue
    }
    
}

struct User: Codable, Equatable {
    var id = UUID().uuidString
    var name: Name?
    var age: Int?
    var city: City?
    
    enum Name: String, Codable {
        case pavel      = "Pavel"
        case nikita     = "Nikita"
        case maria      = "Maria"
        case alexandra  = "Alexandra"
    }
    
    enum City: String, Codable {
        case london     = "London"
        case moscow     = "Moscow"
        case petersburg = "St. Petersburg"
        case kazan      = "Kazan"
    }
}
