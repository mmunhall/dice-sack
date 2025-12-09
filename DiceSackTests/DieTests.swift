import XCTest
@testable import DiceSack

final class DieTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDieInitAllParams() throws {
        let die = Die(sides: 6, value: 1, locked: false)
        XCTAssertEqual(die.sides, 6)
        XCTAssertEqual(die.value, 1)
        XCTAssertEqual(die.locked, false)
    }
    
    func testDieInitSidesParam() throws {
        let die = Die(sides: 6)
        XCTAssertEqual(die.sides, 6)
        XCTAssertLessThanOrEqual(die.value, die.sides)
        XCTAssertEqual(die.locked, false)
    }

}
