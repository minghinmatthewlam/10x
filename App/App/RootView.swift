import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Query(filter: #Predicate<TenXGoal> { $0.archivedAt == nil },
           sort: [SortDescriptor(\.createdAt, order: .forward)])
    private var activeGoals: [TenXGoal]

    var body: some View {
        Group {
            if !hasCompletedOnboarding || activeGoals.isEmpty {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                }
            } else {
                HomeShellView()
            }
        }
        .task {
            let store = TenXStore(context: modelContext)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
        }
    }
}
