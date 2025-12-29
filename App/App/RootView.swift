import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingContainerView {
                    completeOnboarding()
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

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        appState.showDailySetup = true

        let store = TenXStore(context: modelContext)
        WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
    }
}
