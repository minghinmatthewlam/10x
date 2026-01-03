import SwiftUI
import SwiftData

struct YearProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: YearProgressViewModel
    @State private var selectedDay: YearDayDot?

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
        .sheet(item: $selectedDay) { day in
            YearProgressDetailView(day: day)
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
                ForEach(viewModel.days) { day in
                    Button {
                        selectedDay = day
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
            .padding(.vertical, 8)
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

        let columns = 14
        let rows = Int(ceil(Double(totalDays) / Double(columns)))
        let widthDot = (size.width - spacingX * CGFloat(columns - 1)) / CGFloat(columns)
        let heightDot = (size.height - spacingYMin * CGFloat(max(rows - 1, 0))) / CGFloat(rows)
        let dotSize = max(2, floor(min(widthDot, heightDot)))

        let totalDotHeight = CGFloat(rows) * dotSize
        let availableSpacing = max(0, size.height - totalDotHeight)
        let spacingY = rows > 1 ? max(spacingYMin, availableSpacing / CGFloat(rows - 1)) : 0

        return (columns: columns, dotSize: dotSize, spacingY: spacingY)
    }

    private func dotColor(for status: YearDayStatus) -> Color {
        switch status {
        case .success:
            return AppColors.complete
        case .incomplete:
            return AppColors.accent.opacity(0.7)
        case .emptyToday:
            return AppColors.textSecondary
        case .emptyPast:
            return AppColors.textMuted
        case .future:
            return AppColors.surface
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
    let day: YearDayDot

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(formattedDate)
                .font(.tenxTitle)
                .foregroundStyle(AppColors.textPrimary)

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

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: day.date)
    }
}
