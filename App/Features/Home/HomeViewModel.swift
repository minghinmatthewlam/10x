import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayEntry: DayEntry?
    @Published var unfinishedDrafts: [TenXStore.FocusDraft] = []
    @Published var streak: Int = 0
    @Published var weeklySummary: WeeklySummary?
    @Published var weeklyProgressDays: [WeeklyProgressDay] = []
    @Published var errorMessage: String?

    func load(store: TenXStore, todayKey: String) {
        todayEntry = try? store.fetchDayEntry(dayKey: todayKey)
        unfinishedDrafts = []
        let entries = (try? store.fetchRecentDayEntries()) ?? []
        streak = StreakEngine.currentStreak(todayKey: todayKey, entries: entries)
        weeklySummary = WeeklySummary.make(todayKey: todayKey, entries: entries)
        weeklyProgressDays = WeeklyProgressDay.makeWeek(todayKey: todayKey, entries: entries)
    }
}
