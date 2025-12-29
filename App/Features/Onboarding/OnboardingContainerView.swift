import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext

    let onComplete: () -> Void

    var body: some View {
        WelcomeView {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        let store = TenXStore(context: modelContext)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
        onComplete()
    }
}
