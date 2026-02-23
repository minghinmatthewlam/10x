import Foundation

struct WeeklyProgressDay: Identifiable {
    let dayKey: String
    let date: Date
    let completed: Int
    let total: Int

    var id: String { dayKey }

    var maintainsStreak: Bool {
        guard total > 0 else { return false }
        return completed >= min(2, total)
    }

    static func makeWeek(todayKey: String, entries: [DayEntry]) -> [WeeklyProgressDay] {
        let byKey = Dictionary(entries.map { ($0.dayKey, $0) }, uniquingKeysWith: { first, _ in first })
        let todayDate = DayKey.date(from: todayKey) ?? Date()
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: todayDate)?.start ?? todayDate

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else {
                return nil
            }
            let dayKey = DayKey.make(for: date)
            let entry = byKey[dayKey]
            let total = entry?.focuses.count ?? 0
            let completed = entry?.completedCount ?? 0
            return WeeklyProgressDay(dayKey: dayKey, date: date, completed: completed, total: total)
        }
    }
}
