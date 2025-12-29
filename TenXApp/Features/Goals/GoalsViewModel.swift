import Foundation

@MainActor
final class GoalsViewModel: ObservableObject {
    @Published var errorMessage: String?

    func createGoal(title: String, store: TenXStore) {
        do {
            try store.createGoal(title: title)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func archiveGoal(_ goal: TenXGoal, store: TenXStore) {
        do {
            try store.archiveGoal(goal)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func unarchiveGoal(_ goal: TenXGoal, store: TenXStore) {
        do {
            try store.unarchiveGoal(goal)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
