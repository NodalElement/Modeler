import XCTest
import Combine
@testable import Modeler

@available(iOS 13.0, *)
final class DefaultStorageTesting: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Invoke this method to run the test.
    func testExample() throws {
        var user = DefaultStorage(key: "user", defaultValue: User(name: .pavel, age: 25, city: .petersburg))
        
        changeDefaultStorage(&user, newValue: User(name: .maria, age: 20, city: .moscow))
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

fileprivate struct User: Codable, Equatable {
    var name: Name?
    var age: Int?
    var city: City?
    
    enum Name: String, Codable {
        case pavel      = "Pavel"
        case maria      = "Maria"
        case alexandra  = "Alexandra"
    }
    
    enum City: String, Codable {
        case moscow     = "Moscow"
        case petersburg = "St. Petersburg"
        case kazan      = "Kazan"
    }
}
