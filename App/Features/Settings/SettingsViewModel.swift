import Foundation
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
#if DEBUG
    @Published var testNotificationMessage: String?
#endif

    func refreshStatus() {
        Task {
            authorizationStatus = await NotificationScheduler.shared.notificationStatus()
        }
    }

    func requestAndSchedule(store: TenXStore,
                            todayKey: String,
                            hour: Int,
                            minute: Int,
                            middayEnabled: Bool,
                            eveningEnabled: Bool) {
        Task {
            let granted = await NotificationScheduler.shared.requestAuthorization()
            if granted {
                let entry = try? store.fetchDayEntry(dayKey: todayKey)
                let focuses = entry?.sortedFocuses ?? []
                await NotificationScheduler.shared.scheduleReminders(
                    focuses: focuses,
                    morningHour: hour,
                    morningMinute: minute,
                    middayEnabled: middayEnabled,
                    eveningEnabled: eveningEnabled
                )
            }
            refreshStatus()
        }
    }

    #if DEBUG
    func scheduleTest() {
        Task {
            let granted = await NotificationScheduler.shared.requestAuthorization()
            if granted {
                await NotificationScheduler.shared.scheduleTestNotification()
                testNotificationMessage = "Test notification scheduled."
            } else {
                testNotificationMessage = "Notifications are disabled. Enable them in Settings."
            }
        }
    }
    #endif
}
