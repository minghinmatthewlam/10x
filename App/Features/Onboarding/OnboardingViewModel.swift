import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var goalTitles: [String] = [""]

    var canAddGoal: Bool {
        goalTitles.count < AppConstants.maxActiveGoals
    }

    func addGoal() {
        guard canAddGoal else { return }
        goalTitles.append("")
    }

    func removeGoal(at offsets: IndexSet) {
        goalTitles.remove(atOffsets: offsets)
    }

    func nonEmptyGoals() -> [String] {
        goalTitles.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func complete(store: TenXStore) throws {
        let goals = nonEmptyGoals()
        guard !goals.isEmpty else {
            throw StoreError.validation("Add at least one goal to continue.")
        }
        for title in goals {
            try store.createGoal(title: title)
        }
    }
}
