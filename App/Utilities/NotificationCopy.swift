import Foundation

@MainActor
enum NotificationCopy {
    static func weeklyReminderText(calendar: Calendar = .autoupdatingCurrent) -> String {
        let weekdaySymbols = calendar.weekdaySymbols
        let weekdayIndex = max(0, min(AppConstants.weeklyReminderWeekday - 1, weekdaySymbols.count - 1))
        let weekday = weekdaySymbols.isEmpty ? "Sunday" : weekdaySymbols[weekdayIndex]
        var components = DateComponents()
        components.hour = AppConstants.weeklyReminderHour
        components.minute = AppConstants.weeklyReminderMinute
        let date = calendar.date(from: components) ?? Date()
        let time = DateFormatters.shortTime.string(from: date)
        return "Weekly review reminder: \(weekday)s at \(time)"
    }
}
