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
                                      generatedAt: .now)

        do {
            try snapshotStore.save(snapshot)
            WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
        } catch {
            // Widgets can fall back to empty state if write fails.
        }
    }
}
