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
        var carriedFromDayKey: String?
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
                       carriedFromDayKey: yesterdayKey)
        }
    }

    func createDayEntry(todayKey: String, drafts: [FocusDraft]) throws {
        // Filter to only non-empty drafts (must set 3 focuses)
        let validDrafts = drafts.filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        guard validDrafts.count == AppConstants.dailyFocusCount else {
            throw StoreError.validation("Add \(AppConstants.dailyFocusCount) focuses to begin.")
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
