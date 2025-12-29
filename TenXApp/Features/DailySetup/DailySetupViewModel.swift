import Foundation

@MainActor
final class DailySetupViewModel: ObservableObject {
    @Published var drafts: [TenXStore.FocusDraft]
    @Published var errorMessage: String?

    init(initialDrafts: [TenXStore.FocusDraft] = []) {
        var seeded = initialDrafts
        while seeded.count < AppConstants.dailyFocusCount {
            seeded.append(TenXStore.FocusDraft(title: "", goalUUID: nil, carriedFromDayKey: nil))
        }
        drafts = Array(seeded.prefix(AppConstants.dailyFocusCount))
    }

    func startDay(store: TenXStore, todayKey: String) -> Bool {
        do {
            try store.createDayEntry(todayKey: todayKey, drafts: drafts)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: todayKey)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
