import Foundation

public enum WidgetYearDayStatus: String, Codable, Equatable {
    case success
    case incomplete
    case emptyToday
    case emptyPast
    case future
}

public struct WidgetYearPreview: Codable, Equatable {
    public let year: Int
    public let totalDays: Int
    public let completedDays: Int
    public let daysLeft: Int
    public let yearCompletionPercent: Double
    public let statuses: [WidgetYearDayStatus]

    public init(year: Int,
                totalDays: Int,
                completedDays: Int,
                daysLeft: Int,
                yearCompletionPercent: Double,
                statuses: [WidgetYearDayStatus]) {
        self.year = year
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.daysLeft = daysLeft
        self.yearCompletionPercent = yearCompletionPercent
        self.statuses = statuses
    }

    public var percentComplete: Int {
        guard totalDays > 0 else { return 0 }
        return Int((Double(completedDays) / Double(totalDays)) * 100)
    }
}

public struct WidgetSnapshot: Codable, Equatable {
    public enum State: String, Codable {
        case needsOnboarding
        case needsSetup
        case inProgress
        case complete
    }

    public struct Focus: Codable, Equatable {
        public let title: String
        public let isCompleted: Bool

        public init(title: String, isCompleted: Bool) {
            self.title = title
            self.isCompleted = isCompleted
        }
    }

    public let state: State
    public let dayKey: String
    public let streak: Int
    public let completedCount: Int
    public let focuses: [Focus]
    public let yearPreview: WidgetYearPreview?
    public let generatedAt: Date

    public init(state: State,
                dayKey: String,
                streak: Int,
                completedCount: Int,
                focuses: [Focus],
                yearPreview: WidgetYearPreview? = nil,
                generatedAt: Date) {
        self.state = state
        self.dayKey = dayKey
        self.streak = streak
        self.completedCount = completedCount
        self.focuses = focuses
        self.yearPreview = yearPreview
        self.generatedAt = generatedAt
    }
}
