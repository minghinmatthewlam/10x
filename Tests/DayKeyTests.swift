import XCTest
@testable import TenX

final class DayKeyTests: XCTestCase {
    func testPreviousDayKey() throws {
        let calendar = Calendar.current
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12)))
        let todayKey = DayKey.make(for: date)
        let previousKey = DayKey.previous(dayKey: todayKey)
        let previousDate = try XCTUnwrap(calendar.date(byAdding: .day, value: -1, to: date))
        XCTAssertEqual(previousKey, DayKey.make(for: previousDate))
    }

    func testMakeAndParseRoundTrip() {
        let date = Date()
        let key = DayKey.make(for: date)
        let parsed = DayKey.date(from: key)
        XCTAssertNotNil(parsed)
    }
}
