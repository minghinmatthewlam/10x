import SwiftUI
import SwiftData

struct YearProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: YearProgressViewModel
    @State private var selectedDayIndex: Int?

    init(year: Int = Calendar.current.component(.year, from: .now)) {
        _viewModel = StateObject(wrappedValue: YearProgressViewModel(year: year))
    }

    var body: some View {
        let store = TenXStore(context: modelContext)
        VStack(spacing: 16) {
            header

            dotGrid

            footer
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .background(AppColors.background)
        .onAppear {
            viewModel.load(store: store)
        }
        .sheet(isPresented: Binding(get: {
            selectedDayIndex != nil
        }, set: { isPresented in
            if !isPresented {
                selectedDayIndex = nil
            }
        })) {
            YearProgressDetailView(days: viewModel.days, selectedIndex: $selectedDayIndex)
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
                        let store = TenXStore(context: modelContext)
                        viewModel.selectYear(year, store: store)
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

            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var dotGrid: some View {
        GeometryReader { proxy in
            let spacingX: CGFloat = 6
            let spacingYMin: CGFloat = 4
            let layout = gridLayout(for: proxy.size, totalDays: viewModel.days.count, spacingX: spacingX, spacingYMin: spacingYMin)
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacingX), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: layout.spacingY) {
                ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { index, day in
                    Button {
                        selectedDayIndex = index
                    } label: {
                        Circle()
                            .fill(dotColor(for: day.status))
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

    private var footer: some View {
        Text("\(viewModel.summary.daysLeft)d left • \(viewModel.summary.percentComplete)%")
            .font(.tenxCaption)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.top, 4)
    }

    private func dayAccessibilityLabel(for day: YearDayDot) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: day.date)
        return "\(dateString), \(statusDescription(for: day.status))"
    }

    private func gridLayout(
        for size: CGSize,
        totalDays: Int,
        spacingX: CGFloat,
        spacingYMin: CGFloat
    ) -> (columns: Int, dotSize: CGFloat, spacingY: CGFloat) {
        guard totalDays > 0 else { return (columns: 1, dotSize: 4, spacingY: spacingYMin) }

        let minColumns = 10
        let maxColumns = 20
        var bestColumns = minColumns
        var bestDotSize: CGFloat = 0
        var bestSpacingY: CGFloat = spacingYMin

        for columns in minColumns...maxColumns {
            let rows = Int(ceil(Double(totalDays) / Double(columns)))
            guard rows > 0 else { continue }
            let widthDot = (size.width - spacingX * CGFloat(columns - 1)) / CGFloat(columns)
            let heightDot = (size.height - spacingYMin * CGFloat(rows - 1)) / CGFloat(rows)
            let rawDot = min(widthDot, heightDot)
            let dotSize = max(2, floor(rawDot))
            let totalDotHeight = CGFloat(rows) * dotSize
            let availableSpacing = max(0, size.height - totalDotHeight)
            let spacingY = rows > 1 ? max(spacingYMin, availableSpacing / CGFloat(rows - 1)) : 0

            if dotSize > bestDotSize {
                bestDotSize = dotSize
                bestColumns = columns
                bestSpacingY = spacingY
            }
        }

        return (columns: bestColumns, dotSize: bestDotSize, spacingY: bestSpacingY)
    }

    private func dotColor(for status: YearDayStatus) -> Color {
        let success = Color(red: 0.22, green: 0.53, blue: 0.98)
        let incomplete = Color(red: 0.18, green: 0.38, blue: 0.78)
        let emptyToday = Color(red: 0.16, green: 0.27, blue: 0.48)
        let emptyPast = Color(red: 0.10, green: 0.18, blue: 0.32)
        let future = Color(red: 0.06, green: 0.11, blue: 0.22)
        switch status {
        case .success:
            return success
        case .incomplete:
            return incomplete
        case .emptyToday:
            return emptyToday
        case .emptyPast:
            return emptyPast
        case .future:
            return future
        }
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
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: day.date)
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
}
