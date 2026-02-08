import UIKit
import XCTest
import OBD2

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialization() {
        // Just verify we can instantiate the facade
        let obd = OBD2()
        XCTAssertNotNil(obd)
    }
    
}
