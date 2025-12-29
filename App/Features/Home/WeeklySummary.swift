import Foundation

struct WeeklyTagSummary: Identifiable {
    let id: String
    let label: String
    let completed: Int
    let total: Int
}

struct WeeklySummary {
    let tagSummaries: [WeeklyTagSummary]
    let completed: Int
    let total: Int
    let daysWithCompletion: Int

    static func make(todayKey: String, entries: [DayEntry]) -> WeeklySummary? {
        let byKey = Dictionary(uniqueKeysWithValues: entries.map { ($0.dayKey, $0) })
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

        var summaries: [WeeklyTagSummary] = []
        for tag in FocusTag.allCases {
            let tagged = focuses.filter { $0.tag == tag }
            guard !tagged.isEmpty else { continue }
            summaries.append(WeeklyTagSummary(id: tag.rawValue,
                                              label: tag.label,
                                              completed: tagged.filter(\.isCompleted).count,
                                              total: tagged.count))
        }

        let untagged = focuses.filter { $0.tag == nil }
        if !untagged.isEmpty {
            summaries.append(WeeklyTagSummary(id: "untagged",
                                              label: "Untagged",
                                              completed: untagged.filter(\.isCompleted).count,
                                              total: untagged.count))
        }

        summaries.sort { $0.total > $1.total }

        return WeeklySummary(tagSummaries: summaries,
                             completed: focuses.filter(\.isCompleted).count,
                             total: focuses.count,
                             daysWithCompletion: weekEntries.filter(\.maintainsStreak).count)
    }
}
