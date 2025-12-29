import Foundation

@MainActor
final class DailySetupViewModel: ObservableObject {
    @Published var drafts: [TenXStore.FocusDraft]
    @Published var errorMessage: String?

    var hasValidFocus: Bool {
        let filled = drafts.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return filled.count >= AppConstants.dailyFocusMin
    }

    init(initialDrafts: [TenXStore.FocusDraft] = []) {
        var seeded = initialDrafts
        while seeded.count < AppConstants.dailyFocusMax {
            seeded.append(TenXStore.FocusDraft(title: "", carriedFromDayKey: nil))
        }
        drafts = Array(seeded.prefix(AppConstants.dailyFocusMax))
    }

    func startDay(store: TenXStore, todayKey: String) -> Bool {
        do {
            try store.createDayEntry(todayKey: todayKey, drafts: drafts)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: todayKey)
            scheduleReminderIfNeeded()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func scheduleReminderIfNeeded() {
        let defaults = UserDefaults.standard
        let hour = defaults.object(forKey: UserDefaultsKeys.notificationHour) as? Int ?? AppConstants.defaultNotificationHour
        let minute = defaults.object(forKey: UserDefaultsKeys.notificationMinute) as? Int ?? AppConstants.defaultNotificationMinute

        Task {
            let granted = await NotificationScheduler.shared.requestAuthorization()
            if granted {
                await NotificationScheduler.shared.scheduleDailyReminder(hour: hour, minute: minute)
            }
        }
    }
}
