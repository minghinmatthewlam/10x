import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge])
        } catch {
            return false
        }
    }

    func notificationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "TenX"
        content.body = "Set today’s three focuses."
        content.sound = nil

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "tenx.dailyReminder",
                                            content: content,
                                            trigger: trigger)

        do {
            try await center.removePendingNotificationRequests(withIdentifiers: ["tenx.dailyReminder"])
            try await center.add(request)
        } catch {
            // Intentionally no-op; settings view surfaces status.
        }
    }

    #if DEBUG
    func scheduleTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "TenX Test"
        content.body = "This is a test notification."
        content.sound = nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "tenx.test",
                                            content: content,
                                            trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            // Ignore for debug only.
        }
    }
    #endif

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
