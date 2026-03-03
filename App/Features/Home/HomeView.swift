import SwiftUI
import SwiftData
import StoreKit
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var theme: ThemeController
    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @AppStorage(UserDefaultsKeys.hasRequestedReview) private var hasRequestedReview = false
    @StateObject var viewModel = HomeViewModel()
    @StateObject var focusDraftsViewModel = HomeFocusDraftsViewModel()
    @StateObject var yearProgressViewModel = YearProgressViewModel()
    @State private var timeChangeListener: SignificantTimeChangeListener?
    @State var shareItem: ShareItem?
    @FocusState var focusedDraftIndex: Int?
    @State var isCreatingEntry: Bool = false
    @State private var showYearProgress = false
    @State private var showTodayDetail = false
    @State private var focusOrder: [DailyFocus] = []
    @State private var draggedFocus: DailyFocus?
    @State private var isReordering = false
    @State private var lastRescheduleDate: Date = .distantPast

    var body: some View {
        let todayKey = DayKey.make()
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FocusStatusCardView(status: focusStatus, streak: viewModel.streak, onShare: shareStreak)

                Button {
                    showYearProgress = true
                } label: {
                    YearProgressPreviewTileView(
                        year: yearProgressViewModel.selectedYear,
                        days: yearProgressViewModel.days,
                        summary: yearProgressViewModel.summary
                    )
                }
                .buttonStyle(.plain)

                entrySection

                if let yesterdayEntry = viewModel.yesterdayEntry {
                    yesterdaySection(entry: yesterdayEntry)
                }

                WeeklyProgressGridView(days: viewModel.weeklyProgressDays)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 48)
        }
        .background(AppColors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 4) {
                    Text("10x")
                        .font(.tenxTitle)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(formattedDate)
                        .font(.tenxCaption)
                        .foregroundStyle(AppColors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.showSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.tenxIconMedium)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .onAppear {
            let store = TenXStore(context: modelContext)
            reloadData(using: store, todayKey: todayKey)
            focusOrder = viewModel.todayEntry?.sortedFocuses ?? []
            timeChangeListener = SignificantTimeChangeListener {
                let store = TenXStore(context: modelContext)
                let currentDayKey = DayKey.make()
                reloadData(using: store, todayKey: currentDayKey)
                WidgetSnapshotService(store: store).refreshSnapshot(todayKey: currentDayKey)
                NotificationScheduler.shared.debouncedRescheduleAll(store: store)
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
            if streak >= 3, !hasRequestedReview {
                hasRequestedReview = true
                requestReview()
            }
        }
        .onChange(of: currentFocusIds) { _, _ in
            guard !isReordering else { return }
            focusOrder = viewModel.todayEntry?.sortedFocuses ?? []
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            guard Date.now.timeIntervalSince(lastRescheduleDate) > 60 else { return }
            let store = TenXStore(context: modelContext)
            NotificationScheduler.shared.debouncedRescheduleAll(store: store)
            lastRescheduleDate = .now
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
        .sheet(isPresented: $showYearProgress) {
            YearProgressView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(theme.preferredColorScheme ?? systemScheme)
        }
        .sheet(isPresented: $showTodayDetail) {
            DayFocusDetailView(startDate: .now)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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

    private var entrySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Focuses")
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                if viewModel.todayEntry != nil {
                    Button {
                        showTodayDetail = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.tenxIconSmall)
                            Text("Details")
                                .font(.tenxTinySemibold)
                        }
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.surface.opacity(0.7))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if let todayEntry = viewModel.todayEntry {
                VStack(spacing: 12) {
                    let focuses = focusOrder.count == todayEntry.sortedFocuses.count ? focusOrder : todayEntry.sortedFocuses
                    ForEach(focuses) { focus in
                        let isDragging = draggedFocus?.uuid == focus.uuid
                        SwipeToDeleteRow(action: {
                            deleteFocus(focus)
                        }, content: {
                            FocusInlineEditRow(focus: focus,
                                               onToggle: { toggleFocus(focus) },
                                               onTitleCommit: { title in
                                                   updateTitle(for: focus, title: title)
                                               })
                        })
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
                            NewFocusRow(placeholder: placeholder(for: todayEntry.focuses.count + offset)) { title in
                                addFocus(to: todayEntry, title: title, tag: nil)
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
    }

    private func yesterdaySection(entry: DayEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Yesterday")
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textSecondary)

                Text("Mark what you completed")
                    .font(.tenxSmall)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))
            }

            VStack(spacing: 12) {
                ForEach(entry.sortedFocuses) { focus in
                    HStack(spacing: 12) {
                        Button { toggleYesterdayFocus(focus) } label: {
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
                        }
                        .buttonStyle(.plain)

                        Text(focus.title)
                            .font(.tenxLargeBody)
                            .foregroundStyle(focus.isCompleted ? AppColors.textSecondary : AppColors.textSecondary.opacity(0.8))
                            .strikethrough(focus.isCompleted, color: AppColors.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColors.surface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(AppColors.textMuted.opacity(0.1), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(20)
        .background(AppColors.card.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
