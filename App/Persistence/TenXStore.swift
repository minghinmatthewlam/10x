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
        var tag: FocusTag?
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

    func fetchEntries(from startDayKey: String, to endDayKey: String) throws -> [DayEntry] {
        let predicate = #Predicate<DayEntry> {
            $0.dayKey >= startDayKey && $0.dayKey <= endDayKey
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.dayKey)]
        return try context.fetch(descriptor)
    }

    func fetchEntryYears() throws -> [Int] {
        let entries = try context.fetch(FetchDescriptor<DayEntry>())
        let calendar = Calendar.current
        let years = entries.compactMap { entry in
            DayKey.date(from: entry.dayKey).map { calendar.component(.year, from: $0) }
        }
        return Array(Set(years)).sorted()
    }

    func carryoverDraftsIfNeeded(todayKey: String) throws -> [FocusDraft] {
        let yesterdayKey = DayKey.previous(dayKey: todayKey)
        guard let yesterday = try fetchDayEntry(dayKey: yesterdayKey) else { return [] }

        let unfinished = yesterday.sortedFocuses.filter { !$0.isCompleted }
        guard !unfinished.isEmpty else { return [] }

        return unfinished.prefix(AppConstants.dailyFocusMax).map { focus in
            FocusDraft(title: focus.title,
                       carriedFromDayKey: yesterdayKey,
                       tag: focus.tag)
        }
    }

    func createDayEntry(todayKey: String, drafts: [FocusDraft]) throws {
        // Filter to only non-empty drafts (1 to 3 focuses).
        let validDrafts = drafts.filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        guard validDrafts.count >= AppConstants.dailyFocusMin else {
            throw StoreError.validation("Add at least one focus to begin.")
        }
        guard validDrafts.count <= AppConstants.dailyFocusMax else {
            throw StoreError.validation("Limit to \(AppConstants.dailyFocusMax) focuses.")
        }
        guard (try fetchDayEntry(dayKey: todayKey)) == nil else {
            throw StoreError.validation("Today is already set.")
        }

        // Validate all titles before inserting anything into the context.
        let trimmedDrafts = try validDrafts.map { draft -> (String, FocusDraft) in
            let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count <= AppConstants.maxFocusTitleLength else {
                throw StoreError.validation("Focus is too long.")
            }
            return (trimmed, draft)
        }

        let entry = DayEntry(dayKey: todayKey)
        context.insert(entry)

        for (index, (trimmed, draft)) in trimmedDrafts.enumerated() {
            let focus = DailyFocus(title: trimmed,
                                   sortOrder: index,
                                   carriedFromDayKey: draft.carriedFromDayKey,
                                   tagRawValue: draft.tag?.rawValue)
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

    func updateFocus(_ focus: DailyFocus, title: String, tag: FocusTag?) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StoreError.validation("Focus title is empty.")
        }
        guard trimmed.count <= AppConstants.maxFocusTitleLength else {
            throw StoreError.validation("Focus title is too long.")
        }

        focus.title = trimmed
        focus.tag = tag
        try context.save()
    }

    func updateFocusTag(_ focus: DailyFocus, tag: FocusTag?) throws {
        focus.tag = tag
        try context.save()
    }

    func addFocus(to entry: DayEntry, title: String, tag: FocusTag?) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StoreError.validation("Focus title is empty.")
        }
        guard trimmed.count <= AppConstants.maxFocusTitleLength else {
            throw StoreError.validation("Focus is too long.")
        }
        guard entry.focuses.count < AppConstants.dailyFocusMax else {
            throw StoreError.validation("Limit to \(AppConstants.dailyFocusMax) focuses.")
        }

        let sortOrder = entry.sortedFocuses.count
        let focus = DailyFocus(title: trimmed,
                               sortOrder: sortOrder,
                               tagRawValue: tag?.rawValue)
        focus.day = entry
        entry.focuses.append(focus)
        context.insert(focus)
        try context.save()
    }

    func deleteFocus(_ focus: DailyFocus) throws {
        let entry = focus.day
        guard (entry?.focuses.count ?? 0) > AppConstants.dailyFocusMin else {
            throw StoreError.validation("Can't delete your only focus.")
        }
        entry?.focuses.removeAll { $0 === focus }
        context.delete(focus)

        if let entry {
            for (index, remaining) in entry.sortedFocuses.enumerated() {
                remaining.sortOrder = index
            }
        }

        try context.save()
    }

    func updateFocusOrder(_ focuses: [DailyFocus]) throws {
        for (index, focus) in focuses.enumerated() {
            focus.sortOrder = index
        }
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
