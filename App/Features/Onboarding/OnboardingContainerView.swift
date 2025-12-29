import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext

    let onComplete: () -> Void

    @StateObject private var viewModel = OnboardingViewModel()
    @State private var step: Step = .welcome
    @State private var errorMessage: String?

    var body: some View {
        Group {
            switch step {
            case .welcome:
                WelcomeView {
                    step = .goals
                }
            case .goals:
                GoalSetupView(viewModel: viewModel)
                    .safeAreaInset(edge: .bottom) {
                        Button("Continue") {
                            completeOnboarding()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .background(Color.tenxBackground)
                    }
            }
        }
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

    private enum Step {
        case welcome
        case goals
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
