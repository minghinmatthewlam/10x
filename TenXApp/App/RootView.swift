import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Query(filter: #Predicate<TenXGoal> { $0.archivedAt == nil },
           sort: [SortDescriptor(\.createdAt, order: .forward)])
    private var activeGoals: [TenXGoal]

    var body: some View {
        if !hasCompletedOnboarding || activeGoals.isEmpty {
            OnboardingContainerView {
                hasCompletedOnboarding = true
            }
        } else {
            HomeShellView()
        }
    }
}
