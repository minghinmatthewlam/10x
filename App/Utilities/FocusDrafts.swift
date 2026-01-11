import Foundation

enum FocusDrafts {
    static func placeholder(for index: Int) -> String {
        switch index {
        case 0: return "Your most important focus..."
        case 1: return "What else matters today?"
        default: return "One more thing..."
        }
    }

    static func seed(from drafts: [TenXStore.FocusDraft]) -> [TenXStore.FocusDraft] {
        var seeded = drafts
        while seeded.count < AppConstants.dailyFocusMax {
            seeded.append(TenXStore.FocusDraft(title: "", carriedFromDayKey: nil, tag: nil))
        }
        return Array(seeded.prefix(AppConstants.dailyFocusMax))
    }

    static func hasValidFocus(_ drafts: [TenXStore.FocusDraft]) -> Bool {
        let filled = trimmedTitles(from: drafts)
        return filled.count >= AppConstants.dailyFocusMin
    }

    static func focusModels(from drafts: [TenXStore.FocusDraft]) -> [DailyFocus] {
        trimmedTitles(from: drafts).enumerated().map { DailyFocus(title: $0.element, sortOrder: $0.offset) }
    }

    private static func trimmedTitles(from drafts: [TenXStore.FocusDraft]) -> [String] {
        drafts
            .map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
