import Foundation

@MainActor
final class HomeFocusDraftsViewModel: ObservableObject {
    @Published var drafts: [TenXStore.FocusDraft]
    @Published var errorMessage: String?

    var hasValidFocus: Bool {
        let filled = drafts.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return filled.count >= AppConstants.dailyFocusMin
    }

    init(initialDrafts: [TenXStore.FocusDraft] = []) {
        drafts = HomeFocusDraftsViewModel.seedDrafts(from: initialDrafts)
    }

    func applyDrafts(_ newDrafts: [TenXStore.FocusDraft]) {
        drafts = HomeFocusDraftsViewModel.seedDrafts(from: newDrafts)
    }

    func createEntry(store: TenXStore, todayKey: String) -> Bool {
        do {
            try store.createDayEntry(todayKey: todayKey, drafts: drafts)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: todayKey)
            scheduleReminderIfNeeded(using: drafts)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func scheduleReminderIfNeeded(using drafts: [TenXStore.FocusDraft]) {
        let defaults = UserDefaults.standard
        let hour = defaults.object(forKey: UserDefaultsKeys.notificationHour) as? Int ?? AppConstants.defaultNotificationHour
        let minute = defaults.object(forKey: UserDefaultsKeys.notificationMinute) as? Int ?? AppConstants.defaultNotificationMinute
        let middayEnabled = defaults.object(forKey: UserDefaultsKeys.middayReminderEnabled) as? Bool ?? AppConstants.defaultMiddayReminderEnabled
        let eveningEnabled = defaults.object(forKey: UserDefaultsKeys.eveningReminderEnabled) as? Bool ?? AppConstants.defaultEveningReminderEnabled

        let focusTitles = drafts
            .map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let focusModels = focusTitles.enumerated().map { DailyFocus(title: $0.element, sortOrder: $0.offset) }

        Task {
            let granted = await NotificationScheduler.shared.requestAuthorization()
            if granted {
                await NotificationScheduler.shared.scheduleReminders(
                    focuses: focusModels,
                    morningHour: hour,
                    morningMinute: minute,
                    middayEnabled: middayEnabled,
                    eveningEnabled: eveningEnabled
                )
            }
        }
    }

    private static func seedDrafts(from drafts: [TenXStore.FocusDraft]) -> [TenXStore.FocusDraft] {
        var seeded = drafts
        while seeded.count < AppConstants.dailyFocusMax {
            seeded.append(TenXStore.FocusDraft(title: "", carriedFromDayKey: nil, tag: nil))
        }
        return Array(seeded.prefix(AppConstants.dailyFocusMax))
    }
}
