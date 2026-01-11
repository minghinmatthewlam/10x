import SwiftUI
import SwiftData
import UIKit

struct YearProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: YearProgressViewModel
    @State private var selectedDayIndex: Int?
    @State private var shareItem: ShareItem?
    @State private var dragOffset: CGFloat = 0
    @State private var dragNeighborYear: Int?
    @State private var dragNeighborData: YearProgressData?

    init(year: Int = Calendar.current.component(.year, from: .now)) {
        _viewModel = StateObject(wrappedValue: YearProgressViewModel(year: year))
    }

    var body: some View {
        let store = TenXStore(context: modelContext)
        VStack(spacing: 16) {
            header

            yearContent
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .background(AppColors.background)
        .onAppear {
            viewModel.load(store: store)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .sheet(isPresented: Binding(get: {
            selectedDayIndex != nil
        }, set: { isPresented in
            if !isPresented {
                selectedDayIndex = nil
            }
        })) {
            YearProgressDetailView(days: viewModel.days, selectedIndex: $selectedDayIndex)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
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

            Menu {
                ForEach(viewModel.availableYears, id: \.self) { year in
                    Button {
                        selectYear(year)
                    } label: {
                        Text(verbatim: String(year))
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(verbatim: String(viewModel.selectedYear))
                        .font(.tenxTitle)
                        .foregroundStyle(AppColors.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.tenxMicroSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            Button {
                shareYearProgress()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.tenxIconMedium)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var yearContent: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack {
                if let dragNeighborData, let neighborYear = dragNeighborYear {
                    yearContentView(days: dragNeighborData.days, summary: dragNeighborData.summary)
                        .offset(x: dragOffset + (dragOffset > 0 ? -width : width))
                        .allowsHitTesting(false)
                        .accessibilityLabel("Year \(neighborYear)")
                }

                yearContentView(days: viewModel.days, summary: viewModel.summary)
                    .offset(x: dragOffset)
            }
            .clipped()
            .gesture(yearDragGesture(width: width))
        }
        .frame(maxHeight: .infinity)
    }

    private func yearContentView(days: [YearDayDot], summary: YearProgressSummary) -> some View {
        VStack(spacing: 16) {
            dotGrid(days: days)
            footer(summary: summary)
        }
    }

    private func dotGrid(days: [YearDayDot]) -> some View {
        GeometryReader { proxy in
            let spacingX: CGFloat = 6
            let spacingYMin: CGFloat = 4
            let layout = YearProgressGridLayout.layout(
                for: proxy.size,
                totalDays: days.count,
                spacingX: spacingX,
                spacingYMin: spacingYMin
            )
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacingX), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: layout.spacingY) {
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    Button {
                        selectedDayIndex = index
                    } label: {
                        Circle()
                            .fill(day.status.color)
                            .frame(width: layout.dotSize, height: layout.dotSize)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(dayAccessibilityLabel(for: day))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity)
    }

    private func footer(summary: YearProgressSummary) -> some View {
        Text("\(summary.daysLeft)d left • \(String(format: "%.1f%%", summary.yearCompletionPercent))")
            .font(.tenxCaption)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.top, 4)
    }

    private func dayAccessibilityLabel(for day: YearDayDot) -> String {
        let dateString = DateFormatters.mediumDate.string(from: day.date)
        return "\(dateString), \(statusDescription(for: day.status))"
    }

    private func statusDescription(for status: YearDayStatus) -> String {
        switch status {
        case .success:
            return "success"
        case .incomplete:
            return "incomplete"
        case .emptyToday:
            return "no entry yet"
        case .emptyPast:
            return "missed"
        case .future:
            return "future"
        }
    }

    private func yearDragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let translation = value.translation.width
                guard let neighborYear = neighborYear(for: translation) else {
                    dragOffset = translation * 0.2
                    return
                }
                if dragNeighborYear != neighborYear {
                    dragNeighborYear = neighborYear
                    let store = TenXStore(context: modelContext)
                    dragNeighborData = viewModel.yearData(for: neighborYear, store: store)
                }
                dragOffset = translation
            }
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    resetYearDrag()
                    return
                }
                let threshold = width * 0.25
                let shouldMove = abs(value.translation.width) > threshold
                guard shouldMove, let targetYear = dragNeighborYear else {
                    resetYearDrag()
                    return
                }
                let targetOffset = value.translation.width > 0 ? width : -width
                withAnimation(.easeOut(duration: 0.2)) {
                    dragOffset = targetOffset
                }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    selectYear(targetYear)
                    dragOffset = 0
                    dragNeighborYear = nil
                    dragNeighborData = nil
                }
            }
    }

    private func moveYear(by delta: Int) {
        guard let currentIndex = viewModel.availableYears.firstIndex(of: viewModel.selectedYear) else { return }
        let newIndex = currentIndex + delta
        guard viewModel.availableYears.indices.contains(newIndex) else { return }
        selectYear(viewModel.availableYears[newIndex])
    }

    private func selectYear(_ year: Int) {
        selectedDayIndex = nil
        let store = TenXStore(context: modelContext)
        viewModel.selectYear(year, store: store)
    }

    private func neighborYear(for translation: CGFloat) -> Int? {
        guard let currentIndex = viewModel.availableYears.firstIndex(of: viewModel.selectedYear) else { return nil }
        let nextIndex = translation < 0 ? currentIndex - 1 : currentIndex + 1
        guard viewModel.availableYears.indices.contains(nextIndex) else { return nil }
        return viewModel.availableYears[nextIndex]
    }

    private func resetYearDrag() {
        withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = 0
        }
        dragNeighborYear = nil
        dragNeighborData = nil
    }

    private func shareYearProgress() {
        guard let image = renderShareImage() else { return }
        shareItem = ShareItem(image: image)
    }

    private func renderShareImage() -> UIImage? {
        let renderer = ImageRenderer(content: YearProgressShareCardView(year: viewModel.selectedYear,
                                                                        summary: viewModel.summary,
                                                                        days: viewModel.days))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

private struct YearProgressDetailView: View {
    let days: [YearDayDot]
    @Binding var selectedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            if let entry = day.entry {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(entry.sortedFocuses) { focus in
                        FocusChecklistRow(title: focus.title, isCompleted: focus.isCompleted)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .simultaneousGesture(daySwipeGesture)
    }

    private var header: some View {
        HStack {
            Button {
                moveSelection(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.tenxIconMedium)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!canMoveBackward)
            .opacity(canMoveBackward ? 1 : 0.3)

            Spacer()

            Text(formattedDate)
                .font(.tenxTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button {
                moveSelection(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.tenxIconMedium)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!canMoveForward)
            .opacity(canMoveForward ? 1 : 0.3)
        }
    }

    private var formattedDate: String {
        DateFormatters.fullDate.string(from: day.date)
    }

    private var day: YearDayDot {
        let index = selectedIndex ?? 0
        return days[max(0, min(index, days.count - 1))]
    }

    private var canMoveBackward: Bool {
        guard let selectedIndex else { return false }
        return selectedIndex > 0
    }

    private var canMoveForward: Bool {
        guard let selectedIndex else { return false }
        return selectedIndex < days.count - 1
    }

    private func moveSelection(by delta: Int) {
        guard let selectedIndex else { return }
        let newIndex = max(0, min(selectedIndex + delta, days.count - 1))
        self.selectedIndex = newIndex
    }

    private var daySwipeGesture: some Gesture {
        DragGesture(minimumDistance: 24, coordinateSpace: .local)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < -60 {
                    moveSelection(by: 1)
                } else if value.translation.width > 60 {
                    moveSelection(by: -1)
                }
            }
    }
}
