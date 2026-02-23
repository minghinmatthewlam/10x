import Foundation

@MainActor
struct YearProgressCalculator {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func yearData(for year: Int, store: TenXStore, today: Date = .now) -> YearProgressData {
        guard let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else {
            return YearProgressData(days: [], summary: .empty)
        }
        let daysInYear = calendar.range(of: .day, in: .year, for: startDate)?.count ?? 365
        let endDate = calendar.date(byAdding: .day, value: daysInYear - 1, to: startDate) ?? startDate

        let startKey = DayKey.make(for: startDate)
        let endKey = DayKey.make(for: endDate)
        let entries = (try? store.fetchEntries(from: startKey, to: endKey)) ?? []
        let entriesByKey = Dictionary(entries.map { ($0.dayKey, $0) }, uniquingKeysWith: { first, _ in first })

        let todayStart = calendar.startOfDay(for: today)
        let days: [YearDayDot] = (0..<daysInYear).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
            let dayKey = DayKey.make(for: date)
            let entry = entriesByKey[dayKey]
            let status = status(for: date, entry: entry, today: todayStart)
            return YearDayDot(date: date, dayKey: dayKey, status: status, entry: entry)
        }

        let completedDays = days.filter { $0.status == .success }.count
        let daysLeft = daysRemaining(in: year, totalDays: daysInYear, today: today)
        let yearCompletionPercent = yearProgressPercent(in: year, totalDays: daysInYear, today: today)
        let summary = YearProgressSummary(
            totalDays: daysInYear,
            completedDays: completedDays,
            daysLeft: daysLeft,
            yearCompletionPercent: yearCompletionPercent
        )
        return YearProgressData(days: days, summary: summary)
    }

    private func daysRemaining(in year: Int, totalDays: Int, today: Date) -> Int {
        let currentYear = calendar.component(.year, from: today)
        if year < currentYear {
            return 0
        }
        if year > currentYear {
            return totalDays
        }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 0
        return max(0, totalDays - dayOfYear)
    }

    private func yearProgressPercent(in year: Int, totalDays: Int, today: Date) -> Double {
        guard totalDays > 0 else { return 0 }
        let currentYear = calendar.component(.year, from: today)
        if year < currentYear {
            return 100
        }
        if year > currentYear {
            return 0
        }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 0
        return (Double(dayOfYear) / Double(totalDays)) * 100
    }

    private func status(for date: Date, entry: DayEntry?, today: Date) -> YearDayStatus {
        if date > today {
            return .future
        }
        if let entry {
            return entry.maintainsStreak ? .success : .incomplete
        }
        if date == today {
            return .emptyToday
        }
        return .emptyPast
    }
}

struct YearProgressData {
    let days: [YearDayDot]
    let summary: YearProgressSummary
}

struct YearProgressSummary {
    let totalDays: Int
    let completedDays: Int
    let daysLeft: Int
    let yearCompletionPercent: Double

    var percentComplete: Int {
        guard totalDays > 0 else { return 0 }
        return Int((Double(completedDays) / Double(totalDays)) * 100)
    }

    static let empty = YearProgressSummary(totalDays: 0, completedDays: 0, daysLeft: 0, yearCompletionPercent: 0)
}

struct YearDayDot: Identifiable {
    let date: Date
    let dayKey: String
    let status: YearDayStatus
    let entry: DayEntry?

    var id: String { dayKey }
}

enum YearDayStatus {
    case success
    case incomplete
    case emptyToday
    case emptyPast
    case future
}
