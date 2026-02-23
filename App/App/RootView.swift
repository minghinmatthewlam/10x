import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(ModelContainerFactory.isRunningInMemoryOnly) private var isMemoryOnly = false

    var body: some View {
        VStack(spacing: 0) {
            if isMemoryOnly {
                Text("Data won't persist — storage unavailable")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.red)
            }

            Group {
                if !hasCompletedOnboarding {
                    OnboardingContainerView {
                        completeOnboarding()
                    }
                } else {
                    HomeShellView()
                }
            }
        }
        .task {
            let store = TenXStore(context: modelContext)
            try? store.repairOrphanedEntries()
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
