import Foundation

@MainActor
final class YearProgressViewModel: ObservableObject {
    @Published var days: [YearDayDot] = []
    @Published var availableYears: [Int] = []
    @Published var selectedYear: Int
    @Published var summary = YearProgressSummary.empty

    private let calendar: Calendar
    private let calculator: YearProgressCalculator

    init(year: Int = Calendar.current.component(.year, from: .now),
         calendar: Calendar = .current) {
        self.calendar = calendar
        self.calculator = YearProgressCalculator(calendar: calendar)
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
        let data = calculator.yearData(for: year, store: store)
        days = data.days
        summary = data.summary
    }

    func yearData(for year: Int, store: TenXStore) -> YearProgressData {
        calculator.yearData(for: year, store: store)
    }
}
