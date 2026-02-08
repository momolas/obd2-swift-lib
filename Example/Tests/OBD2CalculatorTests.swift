import XCTest
import OBD2

class OBD2CalculatorTests: XCTestCase {

    func testCalcInt() {
        let data = Data([0x0A])
        XCTAssertEqual(OBD2Calculator.calcInt(data: data), 10.0)

        let emptyData = Data()
        XCTAssertEqual(OBD2Calculator.calcInt(data: emptyData), 0.0)
    }

    func testCalcEngineRPM() {
        // Formula: ((A * 256) + B) / 4
        // A=10, B=20 => ((10*256)+20)/4 = (2560+20)/4 = 2580/4 = 645
        let data = Data([0x0A, 0x14])
        XCTAssertEqual(OBD2Calculator.calcEngineRPM(data: data), 645.0)

        // Edge case: empty data
        XCTAssertEqual(OBD2Calculator.calcEngineRPM(data: Data()), 0.0)

        // Edge case: single byte (should guard and return 0)
        XCTAssertEqual(OBD2Calculator.calcEngineRPM(data: Data([0xFF])), 0.0)
    }

    func testConvertTemp() {
        // 100 C -> 212 F
        // Formula: (value * 9/5) + 32
        XCTAssertEqual(OBD2Calculator.convertTemp(value: 100.0), 212.0)
        // 0 C -> 32 F
        XCTAssertEqual(OBD2Calculator.convertTemp(value: 0.0), 32.0)
    }

    func testCalcTemp() {
        // Formula: A - 40
        let data = Data([0x64]) // 100
        XCTAssertEqual(OBD2Calculator.calcTemp(data: data), 60.0)
    }

    func testCalcSpeed() {
        // Speed uses calcInt
        let data = Data([0x32]) // 50
        XCTAssertEqual(OBD2Calculator.calcInt(data: data), 50.0)

        // Convert speed kmh to mph
        // 100 kmh * 0.621371 = 62.1371
        let mph = OBD2Calculator.convertSpeed(value: 100.0)
        XCTAssertEqual(mph, 62.1371, accuracy: 0.001)
    }
}
