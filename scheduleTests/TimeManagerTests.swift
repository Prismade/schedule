import XCTest
@testable import Расписание

final class MockedTimeManager: TimeManager {
    override func getCurrentDate() -> Date {
        return Date(timeIntervalSince1970: 1582890282)
    }
}


class TimeManagerTests: XCTestCase {

    func testTomorrowDate() {
        let tomorrow = MockedTimeManager.shared.getNextDay()
        XCTAssert(tomorrow.timeIntervalSince1970 == 1582934400)
    }

}
