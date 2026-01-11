import Foundation
import SwiftData
import TenXShared
import WidgetKit

@MainActor
final class WidgetSnapshotService {
    private let store: TenXStore
    private let snapshotStore: WidgetSnapshotStore
    private let userDefaults: UserDefaults

    init(store: TenXStore,
         snapshotStore: WidgetSnapshotStore = WidgetSnapshotStore(),
         userDefaults: UserDefaults = .standard) {
        self.store = store
        self.snapshotStore = snapshotStore
        self.userDefaults = userDefaults
    }

    func refreshSnapshot(todayKey: String) {
        let hasCompletedOnboarding = userDefaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        let todayEntry = try? store.fetchDayEntry(dayKey: todayKey)
        let recentEntries = (try? store.fetchRecentDayEntries()) ?? []
        let yearPreview = makeYearPreview()

        let state: WidgetSnapshot.State
        if !hasCompletedOnboarding {
            state = .needsOnboarding
        } else if todayEntry == nil {
            state = .needsSetup
        } else if todayEntry?.isFullyComplete == true {
            state = .complete
        } else {
            state = .inProgress
        }

        let focuses: [WidgetSnapshot.Focus]
        if let todayEntry {
            focuses = todayEntry.sortedFocuses.map {
                WidgetSnapshot.Focus(title: $0.title, isCompleted: $0.isCompleted)
            }
        } else if hasCompletedOnboarding {
            focuses = []
        } else {
            focuses = []
        }

        let snapshot = WidgetSnapshot(state: state,
                                      dayKey: todayKey,
                                      streak: StreakEngine.currentStreak(todayKey: todayKey, entries: recentEntries),
                                      completedCount: todayEntry?.completedCount ?? 0,
                                      focuses: focuses,
                                      yearPreview: yearPreview,
                                      generatedAt: .now)

        do {
            try snapshotStore.save(snapshot)
            WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
        } catch {
            // Widgets can fall back to empty state if write fails.
        }
    }

    private func makeYearPreview() -> WidgetYearPreview? {
        let currentYear = Calendar.current.component(.year, from: .now)
        let yearData = YearProgressCalculator(calendar: Calendar.current).yearData(for: currentYear, store: store)
        let statuses = yearData.days.map { WidgetYearDayStatus(from: $0.status) }
        return WidgetYearPreview(year: currentYear,
                                 totalDays: yearData.summary.totalDays,
                                 completedDays: yearData.summary.completedDays,
                                 daysLeft: yearData.summary.daysLeft,
                                 yearCompletionPercent: yearData.summary.yearCompletionPercent,
                                 statuses: statuses)
    }
}

private extension WidgetYearDayStatus {
    init(from status: YearDayStatus) {
        switch status {
        case .success:
            self = .success
        case .incomplete:
            self = .incomplete
        case .emptyToday:
            self = .emptyToday
        case .emptyPast:
            self = .emptyPast
        case .future:
            self = .future
        }
    }
}
