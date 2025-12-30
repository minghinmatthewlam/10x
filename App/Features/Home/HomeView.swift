import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var focusDraftsViewModel = HomeFocusDraftsViewModel()
    @State private var timeChangeListener: SignificantTimeChangeListener?
    @State private var shareItem: ShareItem?
    @FocusState private var focusedDraftIndex: Int?
    @State private var isCreatingEntry: Bool = false

    var body: some View {
        let todayKey = DayKey.make()
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView

                StreakCardView(streak: viewModel.streak)

                if let todayEntry = viewModel.todayEntry, !todayEntry.focuses.isEmpty {
                    ProgressSummaryCardView(completed: todayEntry.completedCount, total: todayEntry.focuses.count)
                }

                entrySection

                WeeklyProgressGridView(days: viewModel.weeklyProgressDays)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 48)
        }
        .background(AppColors.background)
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
                focusDraftsViewModel.applyDrafts([])
                focusedDraftIndex = 0
                appState.showDailySetup = false
            }
        }
        .onChange(of: viewModel.streak) { _, streak in
            handleStreakShare(streak)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .sheet(isPresented: $appState.showSettingsSheet) {
            SettingsSheetView()
        }
        .alert("Oops", isPresented: Binding(get: {
            viewModel.errorMessage != nil || focusDraftsViewModel.errorMessage != nil
        }, set: { isPresented in
            if !isPresented {
                viewModel.errorMessage = nil
                focusDraftsViewModel.errorMessage = nil
            }
        })) {
            Button("OK") {
                viewModel.errorMessage = nil
                focusDraftsViewModel.errorMessage = nil
            }
        } message: {
            Text(errorMessage)
        }
    }

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("10x Goals")
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text(formattedDate)
                    .font(.tenxCaption)
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            Spacer()
            Button {
                appState.showSettingsSheet = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.tenxIconMedium)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var entrySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focuses")
                .font(.tenxTitle)
                .foregroundStyle(AppColors.textPrimary)

            if let todayEntry = viewModel.todayEntry, !todayEntry.focuses.isEmpty {
                VStack(spacing: 12) {
                    ForEach(todayEntry.sortedFocuses) { focus in
                        FocusInlineEditRow(focus: focus,
                                           onToggle: { toggleFocus(focus) },
                                           onTitleCommit: { title in
                                               updateTitle(for: focus, title: title)
                                           },
                                           onTagChange: { tag in
                                               updateTag(for: focus, tag: tag)
                                           })
                    }

                    if todayEntry.focuses.count < AppConstants.dailyFocusMax {
                        NewFocusRow(
                            placeholder: placeholder(for: todayEntry.focuses.count),
                            onAdd: { title, tag in
                                addFocus(to: todayEntry, title: title, tag: tag)
                            }
                        )
                    }
                }
            } else {
                if !viewModel.unfinishedDrafts.isEmpty {
                    IncompleteDayPromptView(
                        unfinished: viewModel.unfinishedDrafts,
                        onContinue: {
                            focusDraftsViewModel.applyDrafts(viewModel.unfinishedDrafts)
                            focusedDraftIndex = 0
                        },
                        onFreshStart: {
                            focusDraftsViewModel.applyDrafts([])
                            focusedDraftIndex = 0
                        }
                    )
                }

                VStack(spacing: 16) {
                    ForEach(Array(focusDraftsViewModel.drafts.enumerated()), id: \.offset) { index, _ in
                        FocusInputRow(
                            draft: $focusDraftsViewModel.drafts[index],
                            placeholder: placeholder(for: index),
                            isFocused: focusedDraftIndex == index,
                            onCommit: handleDraftCommit
                        )
                        .focused($focusedDraftIndex, equals: index)
                    }
                }
            }
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var errorMessage: String {
        viewModel.errorMessage ?? focusDraftsViewModel.errorMessage ?? ""
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

    private func addFocus(to entry: DayEntry, title: String, tag: FocusTag?) {
        let store = TenXStore(context: modelContext)
        do {
            try store.addFocus(to: entry, title: title, tag: tag)
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

    private func updateTitle(for focus: DailyFocus, title: String) {
        let store = TenXStore(context: modelContext)
        do {
            try store.updateFocus(focus, title: title, tag: focus.tag)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            viewModel.load(store: store, todayKey: DayKey.make())
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func createEntry() {
        guard !isCreatingEntry else { return }
        isCreatingEntry = true
        let store = TenXStore(context: modelContext)
        let success = focusDraftsViewModel.createEntry(store: store, todayKey: DayKey.make())
        if success {
            Haptics.mediumImpact()
            viewModel.load(store: store, todayKey: DayKey.make())
            focusedDraftIndex = nil
        } else if let error = focusDraftsViewModel.errorMessage {
            viewModel.errorMessage = error
        }
        isCreatingEntry = false
    }

    private func handleDraftCommit() {
        guard viewModel.todayEntry == nil else { return }
        guard focusDraftsViewModel.hasValidFocus else { return }
        createEntry()
    }

    private func placeholder(for index: Int) -> String {
        switch index {
        case 0: return "Your most important focus..."
        case 1: return "What else matters today?"
        default: return "One more thing..."
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
        let renderer = ImageRenderer(content: StreakShareCardView(streak: streak))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
