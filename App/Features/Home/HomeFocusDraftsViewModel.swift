import Foundation

@MainActor
final class HomeFocusDraftsViewModel: ObservableObject {
    @Published var drafts: [TenXStore.FocusDraft]
    @Published var errorMessage: String?

    var hasValidFocus: Bool {
        FocusDrafts.hasValidFocus(drafts)
    }

    init(initialDrafts: [TenXStore.FocusDraft] = []) {
        drafts = FocusDrafts.seed(from: initialDrafts)
    }

    func applyDrafts(_ newDrafts: [TenXStore.FocusDraft]) {
        drafts = FocusDrafts.seed(from: newDrafts)
    }

    func createEntry(store: TenXStore, todayKey: String) -> Bool {
        do {
            try store.createDayEntry(todayKey: todayKey, drafts: drafts)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: todayKey)
            scheduleReminderIfNeeded(store: store)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func scheduleReminderIfNeeded(store: TenXStore) {
        Task {
            await NotificationScheduler.shared.rescheduleAll(store: store)
        }
    }
}
