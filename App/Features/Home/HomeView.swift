import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var timeChangeListener: SignificantTimeChangeListener?
    @State private var editingFocus: DailyFocus?

    var body: some View {
        let todayKey = DayKey.make()
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(formattedDate)
                            .font(.tenxCaption)
                            .foregroundStyle(Color.tenxTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        Text("Today")
                            .font(.tenxHero)
                            .foregroundStyle(Color.tenxTextPrimary)
                    }
                    Spacer()
                    StreakBadgeView(streak: viewModel.streak)
                }

                // Content
                if let todayEntry = viewModel.todayEntry {
                    VStack(spacing: 12) {
                        ForEach(todayEntry.sortedFocuses) { focus in
                            FocusCardView(focus: focus) {
                                toggleFocus(focus)
                            }
                            .contextMenu {
                                Button("Edit") {
                                    editingFocus = focus
                                }
                            }
                        }
                    }
                } else if !viewModel.unfinishedDrafts.isEmpty {
                    IncompleteDayPromptView(
                        unfinished: viewModel.unfinishedDrafts,
                        onContinue: {
                            viewModel.openSetup(with: viewModel.unfinishedDrafts)
                        },
                        onFreshStart: {
                            viewModel.openSetup(with: [])
                        }
                    )
                } else {
                    emptyStateView
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 48)
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
        .sheet(item: $editingFocus) { focus in
            FocusEditView(focus: focus) { title in
                let store = TenXStore(context: modelContext)
                try store.updateFocus(focus, title: title)
                WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
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

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What would make\ntoday extraordinary?")
                .font(.tenxTitle)
                .foregroundStyle(Color.tenxTextSecondary)
                .lineSpacing(4)

            Button("Set your focuses") {
                viewModel.openSetup(with: [])
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, 24)
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
