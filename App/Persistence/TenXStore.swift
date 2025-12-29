import Foundation
import SwiftData

@MainActor
final class TenXStore {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    struct FocusDraft: Equatable {
        var title: String
        var goalUUID: UUID?
        var carriedFromDayKey: String?
    }

    func fetchActiveGoals() throws -> [TenXGoal] {
        var descriptor = FetchDescriptor<TenXGoal>(predicate: #Predicate { $0.archivedAt == nil })
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        return try context.fetch(descriptor)
    }

    func fetchAllGoals() throws -> [TenXGoal] {
        var descriptor = FetchDescriptor<TenXGoal>()
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        return try context.fetch(descriptor)
    }

    func createGoal(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StoreError.validation("Goal title is empty.")
        }
        guard trimmed.count <= AppConstants.maxGoalTitleLength else {
            throw StoreError.validation("Goal title is too long.")
        }

        let activeCount = try fetchActiveGoals().count
        guard activeCount < AppConstants.maxActiveGoals else {
            throw StoreError.validation("You can only have \(AppConstants.maxActiveGoals) active goals.")
        }

        context.insert(TenXGoal(title: trimmed))
        try context.save()
    }

    func archiveGoal(_ goal: TenXGoal) throws {
        let activeCount = try fetchActiveGoals().count
        guard activeCount > 1 else {
            throw StoreError.validation("You need at least 1 active goal.")
        }
        goal.archive()
        try context.save()
    }

    func unarchiveGoal(_ goal: TenXGoal) throws {
        let activeCount = try fetchActiveGoals().count
        guard activeCount < AppConstants.maxActiveGoals else {
            throw StoreError.validation("You already have \(AppConstants.maxActiveGoals) active goals.")
        }
        goal.unarchive()
        try context.save()
    }

    func fetchDayEntry(dayKey: String) throws -> DayEntry? {
        let descriptor = FetchDescriptor<DayEntry>(predicate: #Predicate { $0.dayKey == dayKey })
        return try context.fetch(descriptor).first
    }

    func fetchRecentDayEntries(limit: Int? = nil) throws -> [DayEntry] {
        var descriptor = FetchDescriptor<DayEntry>()
        descriptor.sortBy = [SortDescriptor(\.dayKey, order: .reverse)]
        if let limit {
            descriptor.fetchLimit = limit
        }
        return try context.fetch(descriptor)
    }

    func carryoverDraftsIfNeeded(todayKey: String) throws -> [FocusDraft] {
        let yesterdayKey = DayKey.previous(dayKey: todayKey)
        guard let yesterday = try fetchDayEntry(dayKey: yesterdayKey) else { return [] }

        let unfinished = yesterday.sortedFocuses.filter { !$0.isCompleted }
        guard !unfinished.isEmpty else { return [] }

        return unfinished.prefix(AppConstants.dailyFocusCount).map { focus in
            FocusDraft(title: focus.title,
                       goalUUID: focus.goal?.uuid,
                       carriedFromDayKey: yesterdayKey)
        }
    }

    func createDayEntry(todayKey: String, drafts: [FocusDraft]) throws {
        // Filter to only non-empty drafts (user can set 1-3 focuses)
        let validDrafts = drafts.filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        guard !validDrafts.isEmpty else {
            throw StoreError.validation("Add at least one focus to begin.")
        }
        guard (try fetchDayEntry(dayKey: todayKey)) == nil else {
            throw StoreError.validation("Today is already set.")
        }

        let entry = DayEntry(dayKey: todayKey)
        context.insert(entry)

        for (index, draft) in validDrafts.enumerated() {
            let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count <= AppConstants.maxFocusTitleLength else {
                throw StoreError.validation("Focus is too long.")
            }

            let focus = DailyFocus(title: trimmed,
                                   sortOrder: index,
                                   carriedFromDayKey: draft.carriedFromDayKey)
            focus.day = entry

            entry.focuses.append(focus)
            context.insert(focus)
        }

        try context.save()
    }

    func toggleCompletion(_ focus: DailyFocus) throws {
        focus.setCompleted(!focus.isCompleted)
        try context.save()
    }

    func updateFocus(_ focus: DailyFocus, title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StoreError.validation("Focus title is empty.")
        }
        guard trimmed.count <= AppConstants.maxFocusTitleLength else {
            throw StoreError.validation("Focus title is too long.")
        }

        focus.title = trimmed
        try context.save()
    }
}

enum StoreError: Error, LocalizedError {
    case validation(String)

    var errorDescription: String? {
        switch self {
        case .validation(let message):
            return message
        }
    }
}
