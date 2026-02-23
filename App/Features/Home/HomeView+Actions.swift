import SwiftUI
import UIKit

extension HomeView {
    var formattedDate: String {
        DateFormatters.homeHeader.string(from: .now)
    }

    var currentFocusIds: [UUID] {
        viewModel.todayEntry?.sortedFocuses.map(\.uuid) ?? []
    }

    var errorMessage: String {
        viewModel.errorMessage ?? focusDraftsViewModel.errorMessage ?? ""
    }

    var focusStatus: FocusStatus {
        guard let entry = viewModel.todayEntry else {
            return FocusStatus(
                message: "Set focuses to start your streak."
            )
        }

        let total = entry.focuses.count
        let completed = entry.completedCount

        if total == 0 {
            return FocusStatus(
                message: "Add focuses to begin."
            )
        }

        if completed == 0 {
            return FocusStatus(
                message: "Finish one to start."
            )
        }

        let neededForStreak = min(2, total)
        if completed < neededForStreak {
            return FocusStatus(
                message: "One more to keep streak."
            )
        }

        if total == 2, completed == 2 {
            return FocusStatus(
                message: "Streak secured — add one more."
            )
        }

        if total == 3, completed == 2 {
            return FocusStatus(
                message: "Two down — finish the last."
            )
        }

        if total == 3, completed == 3 {
            return FocusStatus(
                message: "Perfect day — streak locked."
            )
        }

        if total == 1, completed == 1 {
            return FocusStatus(
                message: "Streak locked."
            )
        }

        if completed >= total {
            return FocusStatus(
                message: "All done — streak locked."
            )
        }

        if completed >= neededForStreak {
            return FocusStatus(
                message: "Streak secured — keep going."
            )
        }

        return FocusStatus(
            message: "Keep going."
        )
    }

    func reloadData(using store: TenXStore, todayKey: String) {
        viewModel.load(store: store, todayKey: todayKey)
        yearProgressViewModel.load(store: store)
        let currentYear = Calendar.current.component(.year, from: .now)
        if yearProgressViewModel.selectedYear != currentYear {
            yearProgressViewModel.selectYear(currentYear, store: store)
        }
    }

    func toggleFocus(_ focus: DailyFocus) {
        let store = TenXStore(context: modelContext)
        do {
            try store.toggleCompletion(focus)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            reloadData(using: store, todayKey: DayKey.make())
            Haptics.mediumImpact()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    func updateTag(for focus: DailyFocus, tag: FocusTag?) {
        let store = TenXStore(context: modelContext)
        do {
            try store.updateFocusTag(focus, tag: tag)
            reloadData(using: store, todayKey: DayKey.make())
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    func addFocus(to entry: DayEntry, title: String, tag: FocusTag?) {
        let store = TenXStore(context: modelContext)
        do {
            try store.addFocus(to: entry, title: title, tag: tag)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            reloadData(using: store, todayKey: DayKey.make())
            Haptics.mediumImpact()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    func updateTitle(for focus: DailyFocus, title: String) {
        let store = TenXStore(context: modelContext)
        do {
            try store.updateFocus(focus, title: title, tag: focus.tag)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            reloadData(using: store, todayKey: DayKey.make())
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    func deleteFocus(_ focus: DailyFocus) {
        let store = TenXStore(context: modelContext)
        do {
            try store.deleteFocus(focus)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            reloadData(using: store, todayKey: DayKey.make())
            Haptics.mediumImpact()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    func persistFocusOrder(_ focuses: [DailyFocus]) {
        let store = TenXStore(context: modelContext)
        do {
            try store.updateFocusOrder(focuses)
            WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
            if let todayEntry = try? store.fetchDayEntry(dayKey: DayKey.make()) {
                rescheduleReminders(for: todayEntry)
            }
            reloadData(using: store, todayKey: DayKey.make())
            Haptics.mediumImpact()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    func createEntry() {
        guard !isCreatingEntry else { return }
        isCreatingEntry = true
        let store = TenXStore(context: modelContext)
        let success = focusDraftsViewModel.createEntry(store: store, todayKey: DayKey.make())
        if success {
            Haptics.mediumImpact()
            reloadData(using: store, todayKey: DayKey.make())
            focusedDraftIndex = nil
        } else if let error = focusDraftsViewModel.errorMessage {
            viewModel.errorMessage = error
        }
        isCreatingEntry = false
    }

    func handleDraftCommit() {
        guard viewModel.todayEntry == nil else { return }
        guard focusDraftsViewModel.hasValidFocus else { return }
        createEntry()
    }

    func placeholder(for index: Int) -> String {
        FocusDrafts.placeholder(for: index)
    }

    func rescheduleReminders(for entry: DayEntry) {
        let preferences = NotificationPreferences.current()
        NotificationScheduler.shared.debouncedScheduleReminders(
            focuses: entry.sortedFocuses,
            morningHour: preferences.morningHour,
            morningMinute: preferences.morningMinute,
            middayEnabled: preferences.middayEnabled,
            eveningEnabled: preferences.eveningEnabled
        )
    }

    func handleStreakShare(_ streak: Int) {
        guard AppConstants.streakMilestones.contains(streak) else { return }
        let defaults = UserDefaults.standard
        let lastShared = defaults.integer(forKey: UserDefaultsKeys.lastSharedStreak)
        guard streak > lastShared else { return }
        guard let image = renderShareImage(streak: streak) else { return }
        shareItem = ShareItem(image: image)
        defaults.set(streak, forKey: UserDefaultsKeys.lastSharedStreak)
    }

    func shareStreak() {
        guard let image = renderShareImage(streak: viewModel.streak) else { return }
        shareItem = ShareItem(image: image)
    }

    func renderShareImage(streak: Int) -> UIImage? {
        let renderer = ImageRenderer(content: StreakShareCardView(streak: streak))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
