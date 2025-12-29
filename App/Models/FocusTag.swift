import Foundation

enum FocusTag: String, CaseIterable, Identifiable {
    case work
    case health
    case relationships
    case learning
    case personal
    case admin

    var id: String { rawValue }

    var label: String {
        switch self {
        case .work: return "Work"
        case .health: return "Health"
        case .relationships: return "Relationships"
        case .learning: return "Learning"
        case .personal: return "Personal"
        case .admin: return "Admin"
        }
    }
}
