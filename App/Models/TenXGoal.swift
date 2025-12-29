import Foundation
import SwiftData

@Model
final class TenXGoal {
    @Attribute(.unique) var uuid: UUID
    var title: String
    var createdAt: Date
    var archivedAt: Date?

    @Relationship(inverse: \DailyFocus.goal)
    var focuses: [DailyFocus] = []

    init(uuid: UUID = UUID(),
         title: String,
         createdAt: Date = .now,
         archivedAt: Date? = nil) {
        self.uuid = uuid
        self.title = title
        self.createdAt = createdAt
        self.archivedAt = archivedAt
    }

    var isArchived: Bool { archivedAt != nil }

    func archive(now: Date = .now) {
        archivedAt = now
    }

    func unarchive() {
        archivedAt = nil
    }
}
