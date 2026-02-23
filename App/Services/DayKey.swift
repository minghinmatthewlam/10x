import Foundation

@MainActor
enum DayKey {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func make(for date: Date = .now) -> String {
        formatter.string(from: date)
    }

    static func date(from dayKey: String) -> Date? {
        formatter.date(from: dayKey)
    }

    static func previous(dayKey: String) -> String {
        guard let date = date(from: dayKey) else { return dayKey }
        let calendar = Calendar.current
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else {
            return dayKey
        }
        return make(for: previousDate)
    }
}
