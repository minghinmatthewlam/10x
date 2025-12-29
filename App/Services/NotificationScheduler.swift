import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifiers = [
        "tenx.reminder.morning",
        "tenx.reminder.midday",
        "tenx.reminder.evening"
    ]

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

    func scheduleReminders(focuses: [DailyFocus],
                           morningHour: Int,
                           morningMinute: Int,
                           middayEnabled: Bool,
                           eveningEnabled: Bool) async {
        let incomplete = focuses.filter { !$0.isCompleted }
        guard !incomplete.isEmpty else {
            await removeReminders()
            return
        }

        let content = reminderContent(for: incomplete)
        do {
            try await center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)

            try await center.add(
                reminderRequest(identifier: "tenx.reminder.morning",
                                content: content,
                                hour: morningHour,
                                minute: morningMinute)
            )

            if middayEnabled {
                try await center.add(
                    reminderRequest(identifier: "tenx.reminder.midday",
                                    content: content,
                                    hour: AppConstants.middayReminderHour,
                                    minute: AppConstants.middayReminderMinute)
                )
            }

            if eveningEnabled {
                try await center.add(
                    reminderRequest(identifier: "tenx.reminder.evening",
                                    content: content,
                                    hour: AppConstants.eveningReminderHour,
                                    minute: AppConstants.eveningReminderMinute)
                )
            }
        } catch {
            // Intentionally no-op; settings view surfaces status.
        }
    }

    #if DEBUG
    func scheduleTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "10x Test"
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

    private func reminderRequest(identifier: String,
                                 content: UNNotificationContent,
                                 hour: Int,
                                 minute: Int) -> UNNotificationRequest {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private func reminderContent(for focuses: [DailyFocus]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "10x"
        if let first = focuses.first?.title {
            let remaining = focuses.count - 1
            if remaining > 0 {
                content.body = "Focus: \(first) +\(remaining) more"
            } else {
                content.body = "Focus: \(first)"
            }
        } else {
            content.body = "Check your focuses."
        }
        content.sound = nil
        return content
    }

    private func removeReminders() async {
        do {
            try await center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        } catch {
            // Ignore; best effort cleanup.
        }
    }
}
