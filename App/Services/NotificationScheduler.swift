import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private var pendingReschedule: Task<Void, Never>?
    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifiers = [
        "tenx.reminder.morning",
        "tenx.reminder.midday",
        "tenx.reminder.evening"
    ]
    private let weeklyIdentifier = "tenx.reminder.weekly"

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge])
        } catch {
            return false
        }
    }

    func requestAndScheduleReminders(for drafts: [TenXStore.FocusDraft],
                                     preferences: NotificationPreferences = .current()) async {
        let focuses = FocusDrafts.focusModels(from: drafts)
        let granted = await requestAuthorization()
        guard granted else { return }
        await scheduleReminders(focuses: focuses,
                                morningHour: preferences.morningHour,
                                morningMinute: preferences.morningMinute,
                                middayEnabled: preferences.middayEnabled,
                                eveningEnabled: preferences.eveningEnabled)
    }

    func debouncedScheduleReminders(focuses: [DailyFocus],
                                     morningHour: Int,
                                     morningMinute: Int,
                                     middayEnabled: Bool,
                                     eveningEnabled: Bool) {
        // Snapshot model data before the debounce yield to avoid
        // accessing SwiftData objects after they may have been deleted.
        let focusSnapshots = focuses.map { FocusSnapshot(title: $0.title, isCompleted: $0.isCompleted) }
        pendingReschedule?.cancel()
        pendingReschedule = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await scheduleRemindersFromSnapshots(focusSnapshots,
                                                 morningHour: morningHour,
                                                 morningMinute: morningMinute,
                                                 middayEnabled: middayEnabled,
                                                 eveningEnabled: eveningEnabled)
        }
    }

    private struct FocusSnapshot {
        let title: String
        let isCompleted: Bool
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
        do {
            try await center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)

            if !incomplete.isEmpty {
                let content = reminderContent(for: incomplete)
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
            }

            try await center.add(weeklyReminderRequest())
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

    private func weeklyReminderRequest() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "10x Weekly Review"
        content.body = "Your weekly review is ready."
        content.sound = nil

        var components = DateComponents()
        components.weekday = AppConstants.weeklyReminderWeekday
        components.hour = AppConstants.weeklyReminderHour
        components.minute = AppConstants.weeklyReminderMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        return UNNotificationRequest(identifier: weeklyIdentifier,
                                     content: content,
                                     trigger: trigger)
    }

    private func scheduleRemindersFromSnapshots(_ snapshots: [FocusSnapshot],
                                                  morningHour: Int,
                                                  morningMinute: Int,
                                                  middayEnabled: Bool,
                                                  eveningEnabled: Bool) async {
        let incomplete = snapshots.filter { !$0.isCompleted }
        do {
            center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)

            if !incomplete.isEmpty {
                let content = reminderContent(forTitles: incomplete.map(\.title))
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
            }

            try await center.add(weeklyReminderRequest())
        } catch {
            // Intentionally no-op; settings view surfaces status.
        }
    }

    private func reminderContent(forTitles titles: [String]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "10x"
        if let first = titles.first {
            let remaining = titles.count - 1
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

    private func reminderContent(for focuses: [DailyFocus]) -> UNMutableNotificationContent {
        reminderContent(forTitles: focuses.map(\.title))
    }
}
