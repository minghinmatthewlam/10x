import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Query private var allGoals: [TenXGoal]

    var body: some View {
        if !hasCompletedOnboarding || allGoals.isEmpty {
            OnboardingContainerView {
                hasCompletedOnboarding = true
            }
        } else {
            HomeShellView()
        }
    }
}
