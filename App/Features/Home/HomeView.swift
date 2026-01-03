import SwiftUI
import SwiftData
import UIKit
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var theme: ThemeController
    @Environment(\.colorScheme) private var systemScheme
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var focusDraftsViewModel = HomeFocusDraftsViewModel()
    @State private var timeChangeListener: SignificantTimeChangeListener?
    @State private var shareItem: ShareItem?
    @FocusState private var focusedDraftIndex: Int?
    @State private var isCreatingEntry: Bool = false
    @State private var showYearProgress = false
    @State private var showTodayDetail = false
    @State private var focusOrder: [DailyFocus] = []
    @State private var draggedFocus: DailyFocus?
    @State private var isReordering = false

    var body: some View {
        let todayKey = DayKey.make()
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView

                Button {
                    showYearProgress = true
                } label: {
                    StreakCardView(streak: viewModel.streak)
                }
                .buttonStyle(.plain)

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
            focusOrder = viewModel.todayEntry?.sortedFocuses ?? []
            timeChangeListener = SignificantTimeChangeListener {
                let store = TenXStore(context: modelContext)
                viewModel.load(store: store, todayKey: DayKey.make())
                if !isReordering {
                    focusOrder = viewModel.todayEntry?.sortedFocuses ?? []
                }
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
        .onChange(of: currentFocusIds) { _, _ in
            guard !isReordering else { return }
            focusOrder = viewModel.todayEntry?.sortedFocuses ?? []
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .sheet(isPresented: $appState.showSettingsSheet) {
            SettingsSheetView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(theme.preferredColorScheme ?? systemScheme)
        }
        .fullScreenCover(isPresented: $showYearProgress) {
            YearProgressView()
                .preferredColorScheme(theme.preferredColorScheme ?? systemScheme)
        }
        .fullScreenCover(isPresented: $showTodayDetail) {
            TodayFocusDetailView(entry: viewModel.todayEntry, date: Date())
                .preferredColorScheme(theme.preferredColorScheme ?? systemScheme)
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

            if let todayEntry = viewModel.todayEntry {
                VStack(spacing: 12) {
                    let focuses = focusOrder.count == todayEntry.sortedFocuses.count ? focusOrder : todayEntry.sortedFocuses
                    ForEach(focuses) { focus in
                        let isDragging = draggedFocus?.uuid == focus.uuid
                        SwipeToDeleteRow(action: {
                            deleteFocus(focus)
                        }) {
                            FocusInlineEditRow(focus: focus,
                                               onToggle: { toggleFocus(focus) },
                                               onTitleCommit: { title in
                                                   updateTitle(for: focus, title: title)
                                               },
                                               onTagChange: { tag in
                                                   updateTag(for: focus, tag: tag)
                                               })
                        }
                        .scaleEffect(isDragging ? 1.02 : 1)
                        .shadow(color: isDragging ? Color.black.opacity(0.25) : .clear,
                                radius: isDragging ? 12 : 0,
                                y: isDragging ? 6 : 0)
                        .zIndex(isDragging ? 1 : 0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.85), value: isDragging)
                        .onDrag {
                            if draggedFocus?.uuid != focus.uuid {
                                Haptics.lightImpact()
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) {
                                    draggedFocus = focus
                                    isReordering = true
                                }
                            }
                            return NSItemProvider(object: focus.uuid.uuidString as NSString)
                        } preview: {
                            FocusDragPreviewRow(focus: focus)
                        }
                        .onDrop(of: [UTType.text],
                                delegate: FocusReorderDropDelegate(target: focus,
                                                                   items: $focusOrder,
                                                                   draggedItem: $draggedFocus,
                                                                   isReordering: $isReordering,
                                                                   onMoveCompleted: persistFocusOrder))
                    }

                    let remainingSlots = max(0, AppConstants.dailyFocusMax - todayEntry.focuses.count)
                    if remainingSlots > 0 {
                        ForEach(0..<remainingSlots, id: \.self) { offset in
                            NewFocusRow(placeholder: placeholder(for: todayEntry.focuses.count + offset)) { title, tag in
                                addFocus(to: todayEntry, title: title, tag: tag)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(focusDraftsViewModel.drafts.enumerated()), id: \.offset) { index, _ in
                        FocusInputRow(
                            draft: $focusDraftsViewModel.drafts[index],
                            placeholder: placeholder(for: index),
                            isFocused: focusedDraftIndex == index,
                            onCommit: handleDraftCommit
                        ) {
                            focusedDraftIndex = nil
                        }
                        .focused($focusedDraftIndex, equals: index)
                    }
                }
            }
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(Rectangle())
        .gesture(
            TapGesture()
                .onEnded {
                    guard viewModel.todayEntry != nil else { return }
                    showTodayDetail = true
                },
            including: .gesture
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var currentFocusIds: [UUID] {
        viewModel.todayEntry?.sortedFocuses.map(\.uuid) ?? []
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

    private func deleteFocus(_ focus: DailyFocus) {
        let store = TenXStore(context: modelContext)
        do {
            try store.deleteFocus(focus)
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

    private func persistFocusOrder(_ focuses: [DailyFocus]) {
        let store = TenXStore(context: modelContext)
        do {
            try store.updateFocusOrder(focuses)
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

private struct SwipeToDeleteRow<Content: View>: View {
    private let openWidth: CGFloat = 92
    private let cornerRadius: CGFloat = 16
    private let action: () -> Void
    private let content: Content

    @State private var offset: CGFloat = 0
    @State private var isOpen = false
    @State private var rowSize: CGSize = .zero

    init(action: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            actionBackground
            content
                .contentShape(Rectangle())
                .offset(x: offset)
                .background(rowSizeReader)
                .simultaneousGesture(dragGesture)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var actionBackground: some View {
        let width = max(0, min(maxDragWidth, -offset))
        return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.red)
            .frame(width: width, height: rowSize.height)
            .overlay(alignment: .trailing) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.tenxIconSmall)
                    if width > 64 {
                        Text("Delete")
                            .font(.tenxTinyBold)
                    }
                }
                .foregroundStyle(.white)
                .padding(.trailing, 14)
                .opacity(width == 0 ? 0 : 1)
            }
            .opacity(width == 0 ? 0 : 1)
    }

    private var rowSizeReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: RowSizeKey.self, value: proxy.size)
        }
        .onPreferenceChange(RowSizeKey.self) { newSize in
            if rowSize != newSize {
                rowSize = newSize
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let translation = value.translation.width
                if translation < 0 {
                    offset = max(translation, -maxDragWidth)
                } else if isOpen {
                    offset = min(translation - openWidth, 0)
                }
            }
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let translation = value.translation.width
                let fullSwipeThreshold = max(rowSize.width * 0.6, openWidth * 1.4)
                let fullSwipe = -translation > fullSwipeThreshold
                let shouldOpen = -translation > openWidth * 0.5

                if fullSwipe {
                    action()
                    resetOffset()
                } else if shouldOpen {
                    openOffset()
                } else {
                    resetOffset()
                }
            }
    }

    private func openOffset() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            isOpen = true
            offset = -openWidth
        }
    }

    private func resetOffset() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            isOpen = false
            offset = 0
        }
    }

    private var maxDragWidth: CGFloat {
        rowSize.width > 0 ? rowSize.width : openWidth
    }
}

private struct RowSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct FocusReorderDropDelegate: DropDelegate {
    let target: DailyFocus
    @Binding var items: [DailyFocus]
    @Binding var draggedItem: DailyFocus?
    @Binding var isReordering: Bool
    let onMoveCompleted: ([DailyFocus]) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedItem, draggedItem.uuid != target.uuid else { return }
        guard let fromIndex = items.firstIndex(where: { $0.uuid == draggedItem.uuid }),
              let toIndex = items.firstIndex(where: { $0.uuid == target.uuid }) else { return }
        isReordering = true
        withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
            items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        isReordering = false
        draggedItem = nil
        onMoveCompleted(items)
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

private struct FocusDragPreviewRow: View {
    let focus: DailyFocus

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .strokeBorder(
                    focus.isCompleted ? AppColors.complete : AppColors.textMuted,
                    lineWidth: 1.5
                )
                .background(
                    Circle()
                        .fill(focus.isCompleted ? AppColors.complete : Color.clear)
                )
                .frame(width: 24, height: 24)
                .overlay {
                    if focus.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.tenxTinyBold)
                            .foregroundStyle(AppColors.background)
                    }
                }

            Text(focus.title)
                .font(.tenxLargeBody)
                .foregroundStyle(focus.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 8)

            if let tag = focus.tag {
                Text(tag.label)
                    .font(.tenxTinyBold)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppColors.surface)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)
    }
}

private struct TodayFocusDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: DayEntry?
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            if let entry {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(entry.sortedFocuses) { focus in
                        HStack(spacing: 10) {
                            Circle()
                                .strokeBorder(
                                    focus.isCompleted ? AppColors.complete : AppColors.textMuted,
                                    lineWidth: 1.5
                                )
                                .background(
                                    Circle()
                                        .fill(focus.isCompleted ? AppColors.complete : Color.clear)
                                )
                                .frame(width: 18, height: 18)
                                .overlay {
                                    if focus.isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.tenxTinyBold)
                                            .foregroundStyle(AppColors.background)
                                    }
                                }

                            Text(focus.title)
                                .font(.tenxBody)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
            } else {
                Text("No focus set.")
                    .font(.tenxBody)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(24)
        .background(AppColors.background)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.tenxIconButton)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(formattedDate)
                .font(.tenxTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
