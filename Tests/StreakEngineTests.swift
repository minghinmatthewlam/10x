import XCTest
@testable import TenX

final class StreakEngineTests: XCTestCase {
    func testPendingTodayDoesNotBreakStreak() {
        let todayKey = DayKey.make()
        let yesterdayKey = DayKey.previous(dayKey: todayKey)

        let yesterday = makeEntry(dayKey: yesterdayKey, completedCount: 1)
        let today = makeEntry(dayKey: todayKey, completedCount: 0)

        let streak = StreakEngine.currentStreak(todayKey: todayKey, entries: [today, yesterday])
        XCTAssertEqual(streak, 1)
    }

    func testMissingDayBreaksStreak() {
        let todayKey = DayKey.make()
        let twoDaysAgo = DayKey.previous(dayKey: DayKey.previous(dayKey: todayKey))

        let entry = makeEntry(dayKey: twoDaysAgo, completedCount: 2)
        let streak = StreakEngine.currentStreak(todayKey: todayKey, entries: [entry])
        XCTAssertEqual(streak, 0)
    }

    func testStreakStartDayKey() {
        let todayKey = DayKey.make()
        let yesterdayKey = DayKey.previous(dayKey: todayKey)

        let yesterday = makeEntry(dayKey: yesterdayKey, completedCount: 1)
        let today = makeEntry(dayKey: todayKey, completedCount: 1)

        let startKey = StreakEngine.streakStartDayKey(todayKey: todayKey, entries: [today, yesterday])
        XCTAssertEqual(startKey, yesterdayKey)
    }

    private func makeEntry(dayKey: String, completedCount: Int) -> DayEntry {
        let entry = DayEntry(dayKey: dayKey)
        for index in 0..<AppConstants.dailyFocusCount {
            let focus = DailyFocus(title: "Focus \(index)", sortOrder: index)
            focus.isCompleted = index < completedCount
            entry.focuses.append(focus)
        }
        return entry
    }
}
