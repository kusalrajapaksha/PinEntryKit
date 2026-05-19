import XCTest
@testable import PinEntryKit

final class PinEntryKitTests: XCTestCase {

    func testDefaultConfigurationPinLength() {
        let config = PinEntryConfiguration()
        XCTAssertEqual(config.pinLength, 6)
    }

    func testCustomPinLength() {
        let config = PinEntryConfiguration(pinLength: 4)
        XCTAssertEqual(config.pinLength, 4)
    }
}
