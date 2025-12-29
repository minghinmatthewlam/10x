import Foundation
import SwiftData

@Model
final class DailyFocus {
    @Attribute(.unique) var uuid: UUID

    var title: String
    var sortOrder: Int

    var isCompleted: Bool
    var completedAt: Date?

    var carriedFromDayKey: String?
    var createdAt: Date

    @Relationship var day: DayEntry?

    init(uuid: UUID = UUID(),
         title: String,
         sortOrder: Int,
         isCompleted: Bool = false,
         completedAt: Date? = nil,
         carriedFromDayKey: String? = nil,
         createdAt: Date = .now) {
        self.uuid = uuid
        self.title = title
        self.sortOrder = sortOrder
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.carriedFromDayKey = carriedFromDayKey
        self.createdAt = createdAt
    }

    func setCompleted(_ completed: Bool, now: Date = .now) {
        isCompleted = completed
        completedAt = completed ? now : nil
    }
}
