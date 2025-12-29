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

    func requestAndSchedule(hour: Int, minute: Int) {
        Task {
            let granted = await NotificationScheduler.shared.requestAuthorization()
            if granted {
                await NotificationScheduler.shared.scheduleDailyReminder(hour: hour, minute: minute)
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
