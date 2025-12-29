import Foundation
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

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
            await NotificationScheduler.shared.scheduleTestNotification()
        }
    }
    #endif
}
