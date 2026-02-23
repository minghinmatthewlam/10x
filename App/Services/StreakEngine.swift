import Foundation

@MainActor
enum StreakEngine {
    static func currentStreak(todayKey: String, entries: [DayEntry]) -> Int {
        let byKey = Dictionary(entries.map { ($0.dayKey, $0) }, uniquingKeysWith: { first, _ in first })

        let startKey: String = {
            if let today = byKey[todayKey], today.maintainsStreak {
                return todayKey
            }
            return DayKey.previous(dayKey: todayKey)
        }()

        var streak = 0
        var cursor = startKey
        while true {
            guard let entry = byKey[cursor] else { break }
            guard entry.maintainsStreak else { break }
            streak += 1
            cursor = DayKey.previous(dayKey: cursor)
        }
        return streak
    }

    static func streakStartDayKey(todayKey: String, entries: [DayEntry]) -> String? {
        let byKey = Dictionary(entries.map { ($0.dayKey, $0) }, uniquingKeysWith: { first, _ in first })
        let streak = currentStreak(todayKey: todayKey, entries: entries)
        guard streak > 0 else { return nil }

        let startKey = (byKey[todayKey]?.maintainsStreak == true) ? todayKey : DayKey.previous(dayKey: todayKey)

        var cursor = startKey
        var remaining = streak - 1
        while remaining > 0 {
            cursor = DayKey.previous(dayKey: cursor)
            remaining -= 1
        }
        return cursor
    }
}
