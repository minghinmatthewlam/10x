import Foundation
import SwiftData
import TenXShared
import WidgetKit
import os

@MainActor
final class WidgetSnapshotService {
    private static let logger = Logger(subsystem: "com.matthewlam.tenx", category: "WidgetSnapshotService")
    private let store: TenXStore
    private let snapshotStore: WidgetSnapshotStore
    private let userDefaults: UserDefaults

    private struct YearPreviewCacheKey: Equatable {
        let dayKey: String
        let completedCount: Int
        let totalFocuses: Int
    }

    private static var cachedYearPreview: (key: YearPreviewCacheKey, preview: WidgetYearPreview)?

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
        let completedCount = todayEntry?.completedCount ?? 0
        let totalFocuses = todayEntry?.focuses.count ?? 0
        let yearPreview = makeYearPreview(todayKey: todayKey, completedCount: completedCount, totalFocuses: totalFocuses)

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
                                      completedCount: completedCount,
                                      focuses: focuses,
                                      yearPreview: yearPreview,
                                      generatedAt: .now)

        do {
            try snapshotStore.save(snapshot)
            WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
        } catch {
            Self.logger.error("Failed to write widget snapshot: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func makeYearPreview(todayKey: String, completedCount: Int, totalFocuses: Int) -> WidgetYearPreview? {
        let cacheKey = YearPreviewCacheKey(dayKey: todayKey, completedCount: completedCount, totalFocuses: totalFocuses)
        if let cached = Self.cachedYearPreview, cached.key == cacheKey {
            return cached.preview
        }
        let currentYear = Calendar.current.component(.year, from: .now)
        let yearData = YearProgressCalculator(calendar: Calendar.current).yearData(for: currentYear, store: store)
        let statuses = yearData.days.map { WidgetYearDayStatus(from: $0.status) }
        let preview = WidgetYearPreview(year: currentYear,
                                        totalDays: yearData.summary.totalDays,
                                        completedDays: yearData.summary.completedDays,
                                        daysLeft: yearData.summary.daysLeft,
                                        yearCompletionPercent: yearData.summary.yearCompletionPercent,
                                        statuses: statuses)
        Self.cachedYearPreview = (key: cacheKey, preview: preview)
        return preview
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
