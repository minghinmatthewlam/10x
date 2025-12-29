import Foundation

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
    public let theme: String?
    public let generatedAt: Date

    public init(state: State,
                dayKey: String,
                streak: Int,
                completedCount: Int,
                focuses: [Focus],
                theme: String? = nil,
                generatedAt: Date) {
        self.state = state
        self.dayKey = dayKey
        self.streak = streak
        self.completedCount = completedCount
        self.focuses = focuses
        self.theme = theme
        self.generatedAt = generatedAt
    }
}
