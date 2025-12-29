import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var timeChangeListener: SignificantTimeChangeListener?
    @State private var editingFocus: DailyFocus?
    @State private var shareItem: ShareItem?
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        let todayKey = DayKey.make()
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(formattedDate)
                            .font(.tenxCaption)
                            .foregroundStyle(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        Text("Today")
                            .font(.tenxHero)
                            .foregroundStyle(theme.textPrimary)
                    }
                    Spacer()
                    StreakBadgeView(streak: viewModel.streak)
                }

                // Content
                if let todayEntry = viewModel.todayEntry {
                    VStack(spacing: 12) {
                        ForEach(todayEntry.sortedFocuses) { focus in
                            FocusCardView(focus: focus,
                                          onToggle: { toggleFocus(focus) },
                                          onTagChange: { tag in
                                              updateTag(for: focus, tag: tag)
                                          })
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

                if let summary = viewModel.weeklySummary {
                    WeeklyReviewCardView(summary: summary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 48)
        }
        .background(theme.background)
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
        .onChange(of: viewModel.streak) { _, streak in
            handleStreakShare(streak)
        }
        .sheet(isPresented: $viewModel.showDailySetup) {
            DailySetupView(initialDrafts: viewModel.setupDrafts) {
                let store = TenXStore(context: modelContext)
                viewModel.load(store: store, todayKey: DayKey.make())
            }
        }
        .sheet(item: $editingFocus) { focus in
            FocusEditView(focus: focus) { title, tag in
                let store = TenXStore(context: modelContext)
                try store.updateFocus(focus, title: title, tag: tag)
                WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
                viewModel.load(store: store, todayKey: DayKey.make())
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
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
                .foregroundStyle(theme.textSecondary)
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
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            viewModel.load(store: store, todayKey: DayKey.make())
            Haptics.mediumImpact()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func updateTag(for focus: DailyFocus, tag: FocusTag?) {
        let store = TenXStore(context: modelContext)
        do {
            try store.updateFocusTag(focus, tag: tag)
            viewModel.load(store: store, todayKey: DayKey.make())
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func rescheduleReminders(for entry: DayEntry) {
        let defaults = UserDefaults.standard
        let hour = defaults.object(forKey: UserDefaultsKeys.notificationHour) as? Int ?? AppConstants.defaultNotificationHour
        let minute = defaults.object(forKey: UserDefaultsKeys.notificationMinute) as? Int ?? AppConstants.defaultNotificationMinute
        let middayEnabled = defaults.object(forKey: UserDefaultsKeys.middayReminderEnabled) as? Bool ?? AppConstants.defaultMiddayReminderEnabled
        let eveningEnabled = defaults.object(forKey: UserDefaultsKeys.eveningReminderEnabled) as? Bool ?? AppConstants.defaultEveningReminderEnabled

        Task {
            await NotificationScheduler.shared.scheduleReminders(
                focuses: entry.sortedFocuses,
                morningHour: hour,
                morningMinute: minute,
                middayEnabled: middayEnabled,
                eveningEnabled: eveningEnabled
            )
        }
    }

    private func handleStreakShare(_ streak: Int) {
        guard AppConstants.streakMilestones.contains(streak) else { return }
        let defaults = UserDefaults.standard
        let lastShared = defaults.integer(forKey: UserDefaultsKeys.lastSharedStreak)
        guard streak > lastShared else { return }
        guard let image = renderShareImage(streak: streak) else { return }
        shareItem = ShareItem(image: image)
        defaults.set(streak, forKey: UserDefaultsKeys.lastSharedStreak)
    }

    private func renderShareImage(streak: Int) -> UIImage? {
        let renderer = ImageRenderer(content: StreakShareCardView(streak: streak, theme: theme))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
