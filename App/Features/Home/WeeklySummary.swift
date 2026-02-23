import Foundation

struct WeeklySummary {
    let completed: Int
    let total: Int
    let daysWithCompletion: Int

    @MainActor static func make(todayKey: String, entries: [DayEntry]) -> WeeklySummary? {
        let byKey = Dictionary(entries.map { ($0.dayKey, $0) }, uniquingKeysWith: { first, _ in first })
        var keys: [String] = []
        var cursor = todayKey
        for _ in 0..<7 {
            keys.append(cursor)
            cursor = DayKey.previous(dayKey: cursor)
        }

        let weekEntries = keys.compactMap { byKey[$0] }
        guard !weekEntries.isEmpty else { return nil }

        let focuses = weekEntries.flatMap(\.focuses)
        guard !focuses.isEmpty else { return nil }

        return WeeklySummary(completed: focuses.filter(\.isCompleted).count,
                             total: focuses.count,
                             daysWithCompletion: weekEntries.filter(\.maintainsStreak).count)
    }
}
