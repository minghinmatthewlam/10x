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
            let spacing: CGFloat = 5
            let layout = gridLayout(for: proxy.size, totalDays: viewModel.days.count, spacing: spacing)
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacing), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(viewModel.days) { day in
                    Button {
                        selectedDay = day
                    } label: {
                        Circle()
                            .fill(day.isComplete ? AppColors.accent : AppColors.surface)
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
        let status = day.isComplete ? "completed" : "not completed"
        return "\(dateString), \(status)"
    }

    private func gridLayout(for size: CGSize, totalDays: Int, spacing: CGFloat) -> (columns: Int, dotSize: CGFloat) {
        guard totalDays > 0 else { return (columns: 1, dotSize: 4) }

        let minDotForColumns: CGFloat = 4
        let maxDotForColumns: CGFloat = 12
        let maxColumns = max(10, Int((size.width + spacing) / (minDotForColumns + spacing)))
        let minColumns = max(10, min(maxColumns, Int((size.width + spacing) / (maxDotForColumns + spacing))))
        let upperBound = max(minColumns, maxColumns)

        var bestColumns = minColumns
        var bestDotSize: CGFloat = 0

        for columns in minColumns...upperBound {
            let rows = Int(ceil(Double(totalDays) / Double(columns)))
            let widthSize = (size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            let heightSize = (size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)
            let dotSize = min(widthSize, heightSize)
            if dotSize > bestDotSize {
                bestDotSize = dotSize
                bestColumns = columns
            }
        }

        let finalDot = max(2, floor(bestDotSize))
        return (columns: bestColumns, dotSize: finalDot)
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
