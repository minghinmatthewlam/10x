import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var selection = 0
    @State private var errorMessage: String?

    let onComplete: () -> Void

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                WelcomeView()
                    .tag(0)

                GoalSetupView(viewModel: viewModel)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack(spacing: 12) {
                if selection > 0 {
                    Button("Back") {
                        withAnimation { selection -= 1 }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if selection == 0 {
                    Button("Next") {
                        withAnimation { selection = 1 }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button("Finish") {
                        completeOnboarding()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding([.horizontal, .bottom], 24)
        }
        .background(Color.tenxBackground)
        .alert("Oops", isPresented: Binding(get: {
            errorMessage != nil
        }, set: { isPresented in
            if !isPresented { errorMessage = nil }
        })) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func completeOnboarding() {
        let store = TenXStore(context: modelContext)
        do {
            try viewModel.complete(store: store)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            onComplete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
