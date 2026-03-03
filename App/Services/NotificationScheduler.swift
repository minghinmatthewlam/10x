import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private var pendingReschedule: Task<Void, Never>?
    private var weeklyRegistered = false
    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifiers = [
        "tenx.reminder.morning",
        "tenx.reminder.midday",
        "tenx.reminder.evening"
    ]
    private let fallbackIdentifiers = (1...6).map { "tenx.reminder.fallback.\($0)" }
    private let weeklyIdentifier = "tenx.reminder.weekly"

    // MARK: - Public API

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge])
        } catch {
            return false
        }
    }

    func rescheduleAll(store: TenXStore) async {
        pendingReschedule?.cancel()
        pendingReschedule = nil

        let granted = await requestAuthorization()
        guard granted else { return }

        let todayKey = DayKey.make()
        let todayEntry = try? store.fetchDayEntry(dayKey: todayKey)
        let entries = (try? store.fetchRecentDayEntries()) ?? []
        let streak = StreakEngine.currentStreak(todayKey: todayKey, entries: entries)
        let prefs = NotificationPreferences.current()

        await scheduleReminders(
            todayEntry: todayEntry,
            streak: streak,
            prefs: prefs
        )
    }

    func debouncedRescheduleAll(store: TenXStore) {
        pendingReschedule?.cancel()
        pendingReschedule = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await rescheduleAll(store: store)
        }
    }

    func notificationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
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

    // MARK: - Scheduling

    private func scheduleReminders(
        todayEntry: DayEntry?,
        streak: Int,
        prefs: NotificationPreferences
    ) async {
        center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers + fallbackIdentifiers)

        let now = Date.now
        let calendar = Calendar.current

        do {
            // Morning — personalized for today/tomorrow
            if let body = reminderBody(todayEntry: todayEntry, noEntryMessage: "Time to set your focuses for today.") {
                let request = makeRequest(
                    identifier: "tenx.reminder.morning",
                    body: body,
                    hour: prefs.morningHour,
                    minute: prefs.morningMinute,
                    now: now,
                    calendar: calendar
                )
                try await center.add(request)
            }

            // Midday
            if prefs.middayEnabled, let body = reminderBody(todayEntry: todayEntry, noEntryMessage: "Set your focuses — the day is half over.") {
                let request = makeRequest(
                    identifier: "tenx.reminder.midday",
                    body: body,
                    hour: AppConstants.middayReminderHour,
                    minute: AppConstants.middayReminderMinute,
                    now: now,
                    calendar: calendar
                )
                try await center.add(request)
            }

            // Evening
            if prefs.eveningEnabled, let body = eveningBody(todayEntry: todayEntry, streak: streak) {
                let request = makeRequest(
                    identifier: "tenx.reminder.evening",
                    body: body,
                    hour: AppConstants.eveningReminderHour,
                    minute: AppConstants.eveningReminderMinute,
                    now: now,
                    calendar: calendar
                )
                try await center.add(request)
            }

            // Fallback morning reminders for days 2–7
            // Generic content ensures notifications continue if the user doesn't open the app.
            // Replaced with personalized content on next app open.
            try await scheduleFallbackReminders(prefs: prefs, now: now, calendar: calendar)

            // Weekly — register once per app session
            if !weeklyRegistered {
                try await center.add(weeklyReminderRequest())
                weeklyRegistered = true
            }
        } catch {
            // Intentionally no-op; settings view surfaces status.
        }
    }

    private func makeRequest(
        identifier: String,
        body: String,
        hour: Int,
        minute: Int,
        now: Date,
        calendar: Calendar
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "10x"
        content.body = body
        content.sound = nil

        var target = calendar.dateComponents([.year, .month, .day], from: now)
        target.hour = hour
        target.minute = minute
        target.second = 0

        // If time already passed today, schedule for tomorrow
        if let targetDate = calendar.date(from: target), targetDate <= now {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: targetDate) {
                target = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: tomorrow)
            }
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: false)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private func scheduleFallbackReminders(
        prefs: NotificationPreferences,
        now: Date,
        calendar: Calendar
    ) async throws {
        let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        for dayOffset in 1...6 {
            guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfTomorrow) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: futureDate)
            components.hour = prefs.morningHour
            components.minute = prefs.morningMinute
            components.second = 0

            let content = UNMutableNotificationContent()
            content.title = "10x"
            content.body = "Time to set your focuses for today."
            content.sound = nil

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "tenx.reminder.fallback.\(dayOffset)",
                content: content,
                trigger: trigger
            )
            try await center.add(request)
        }
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

    // MARK: - Content

    private func reminderBody(todayEntry: DayEntry?, noEntryMessage: String) -> String? {
        guard let entry = todayEntry else { return noEntryMessage }
        guard !entry.isFullyComplete else { return nil }
        return incompleteFocusSummary(entry)
    }

    private func eveningBody(todayEntry: DayEntry?, streak: Int) -> String? {
        guard let entry = todayEntry else {
            return "Day's almost over — set your focuses."
        }
        guard !entry.isFullyComplete else { return nil }
        guard !entry.focuses.isEmpty else { return nil }

        let total = entry.focuses.count
        let completed = entry.completedCount
        let needed = min(2, total) - completed

        if needed > 0, streak > 0 {
            return "Complete \(needed) more to keep your \(streak)-day streak!"
        }
        if needed > 0 {
            let noun = needed == 1 ? "focus" : "focuses"
            return "Complete \(needed) more \(noun) to start a streak."
        }
        return "Streak safe — finish your last focus for a perfect day."
    }

    private func incompleteFocusSummary(_ entry: DayEntry) -> String? {
        let incomplete = entry.sortedFocuses.filter { !$0.isCompleted }
        guard let first = incomplete.first else { return nil }
        let remaining = incomplete.count - 1
        if remaining > 0 {
            return "Focus: \(first.title) +\(remaining) more"
        }
        return "Focus: \(first.title)"
    }
}
