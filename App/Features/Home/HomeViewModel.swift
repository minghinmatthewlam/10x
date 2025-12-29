import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayEntry: DayEntry?
    @Published var unfinishedDrafts: [TenXStore.FocusDraft] = []
    @Published var streak: Int = 0
    @Published var showDailySetup: Bool = false
    @Published var setupDrafts: [TenXStore.FocusDraft] = []
    @Published var errorMessage: String?

    func load(store: TenXStore, todayKey: String) {
        todayEntry = try? store.fetchDayEntry(dayKey: todayKey)
        unfinishedDrafts = (try? store.carryoverDraftsIfNeeded(todayKey: todayKey)) ?? []
        let entries = (try? store.fetchRecentDayEntries()) ?? []
        streak = StreakEngine.currentStreak(todayKey: todayKey, entries: entries)
    }

    func openSetup(with drafts: [TenXStore.FocusDraft]) {
        setupDrafts = drafts
        showDailySetup = true
    }
}
