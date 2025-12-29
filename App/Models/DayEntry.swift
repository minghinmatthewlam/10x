import Foundation
import SwiftData

@Model
final class DayEntry {
    @Attribute(.unique) var dayKey: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \DailyFocus.day)
    var focuses: [DailyFocus] = []

    init(dayKey: String, createdAt: Date = .now) {
        self.dayKey = dayKey
        self.createdAt = createdAt
    }

    var sortedFocuses: [DailyFocus] {
        focuses.sorted { $0.sortOrder < $1.sortOrder }
    }

    var completedCount: Int {
        focuses.filter(\.isCompleted).count
    }

    var maintainsStreak: Bool { completedCount >= 1 }
    var isFullyComplete: Bool { completedCount == AppConstants.dailyFocusCount }
}
