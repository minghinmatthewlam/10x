import Foundation

@MainActor
final class YearProgressViewModel: ObservableObject {
    @Published var days: [YearDayDot] = []
    @Published var availableYears: [Int] = []
    @Published var selectedYear: Int
    @Published var summary = YearProgressSummary.empty

    private let calendar = Calendar.current

    init(year: Int = Calendar.current.component(.year, from: .now)) {
        selectedYear = year
    }

    func load(store: TenXStore) {
        let currentYear = calendar.component(.year, from: .now)
        let years = (try? store.fetchEntryYears()) ?? []
        let uniqueYears = Array(Set(years + [currentYear])).sorted(by: >)
        availableYears = uniqueYears
        if !uniqueYears.contains(selectedYear) {
            selectedYear = currentYear
        }
        loadYear(store: store, year: selectedYear)
    }

    func selectYear(_ year: Int, store: TenXStore) {
        guard selectedYear != year else { return }
        selectedYear = year
        loadYear(store: store, year: year)
    }

    private func loadYear(store: TenXStore, year: Int) {
        let data = yearData(for: year, store: store)
        days = data.days
        summary = data.summary
    }

    func yearData(for year: Int, store: TenXStore) -> YearProgressData {
        guard let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else {
            return YearProgressData(days: [], summary: .empty)
        }
        let daysInYear = calendar.range(of: .day, in: .year, for: startDate)?.count ?? 365
        let endDate = calendar.date(byAdding: .day, value: daysInYear - 1, to: startDate) ?? startDate

        let startKey = DayKey.make(for: startDate)
        let endKey = DayKey.make(for: endDate)
        let entries = (try? store.fetchEntries(from: startKey, to: endKey)) ?? []
        let entriesByKey = Dictionary(uniqueKeysWithValues: entries.map { ($0.dayKey, $0) })

        let today = calendar.startOfDay(for: .now)
        let days: [YearDayDot] = (0..<daysInYear).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
            let dayKey = DayKey.make(for: date)
            let entry = entriesByKey[dayKey]
            let status = status(for: date, entry: entry, today: today)
            return YearDayDot(date: date, dayKey: dayKey, status: status, entry: entry)
        }

        let completedDays = days.filter { $0.status == .success }.count
        let daysLeft = daysRemaining(in: year, totalDays: daysInYear)
        let yearCompletionPercent = yearProgressPercent(in: year, totalDays: daysInYear)
        let summary = YearProgressSummary(
            totalDays: daysInYear,
            completedDays: completedDays,
            daysLeft: daysLeft,
            yearCompletionPercent: yearCompletionPercent
        )
        return YearProgressData(days: days, summary: summary)
    }

    private func daysRemaining(in year: Int, totalDays: Int) -> Int {
        let currentYear = calendar.component(.year, from: .now)
        if year < currentYear {
            return 0
        }
        if year > currentYear {
            return totalDays
        }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: .now) ?? 0
        return max(0, totalDays - dayOfYear)
    }

    private func yearProgressPercent(in year: Int, totalDays: Int) -> Double {
        guard totalDays > 0 else { return 0 }
        let currentYear = calendar.component(.year, from: .now)
        if year < currentYear {
            return 100
        }
        if year > currentYear {
            return 0
        }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: .now) ?? 0
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
