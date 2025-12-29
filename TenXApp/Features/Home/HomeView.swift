import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var timeChangeListener: SignificantTimeChangeListener?

    var body: some View {
        let todayKey = DayKey.make()
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today")
                            .font(.tenxTitle)
                            .foregroundStyle(Color.tenxTextPrimary)
                        Text(todayKey)
                            .font(.tenxCaption)
                            .foregroundStyle(Color.tenxTextSecondary)
                    }
                    Spacer()
                    StreakBadgeView(streak: viewModel.streak)
                }

                if let todayEntry = viewModel.todayEntry {
                    VStack(spacing: 12) {
                        ForEach(todayEntry.sortedFocuses) { focus in
                            FocusCardView(focus: focus,
                                          goalTitle: focus.goal?.title) {
                                toggleFocus(focus)
                            }
                        }
                    }
                } else if !viewModel.unfinishedDrafts.isEmpty {
                    IncompleteDayPromptView(unfinished: viewModel.unfinishedDrafts,
                                            onContinue: {
                        viewModel.openSetup(with: viewModel.unfinishedDrafts)
                    },
                                            onFreshStart: {
                        viewModel.openSetup(with: [])
                    })
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No focuses set yet.")
                            .font(.tenxBody)
                            .foregroundStyle(Color.tenxTextSecondary)
                        Button("Set up today") {
                            viewModel.openSetup(with: [])
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(24)
        }
        .background(Color.tenxBackground)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            let store = TenXStore(context: modelContext)
            viewModel.load(store: store, todayKey: todayKey)
            timeChangeListener = SignificantTimeChangeListener {
                let store = TenXStore(context: modelContext)
                viewModel.load(store: store, todayKey: DayKey.make())
            }
        }
        .onChange(of: appState.showDailySetup) { _, show in
            if show {
                viewModel.openSetup(with: [])
                appState.showDailySetup = false
            }
        }
        .sheet(isPresented: $viewModel.showDailySetup) {
            DailySetupView(initialDrafts: viewModel.setupDrafts) {
                let store = TenXStore(context: modelContext)
                viewModel.load(store: store, todayKey: DayKey.make())
            }
        }
        .alert("Oops", isPresented: Binding(get: {
            viewModel.errorMessage != nil
        }, set: { isPresented in
            if !isPresented { viewModel.errorMessage = nil }
        })) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func toggleFocus(_ focus: DailyFocus) {
        let store = TenXStore(context: modelContext)
        do {
            try store.toggleCompletion(focus)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            viewModel.load(store: store, todayKey: DayKey.make())
            Haptics.mediumImpact()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
}
