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
                    Button("\(year)") {
                        let store = TenXStore(context: modelContext)
                        viewModel.selectYear(year, store: store)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text("\(viewModel.selectedYear)")
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
            let columns = 14
            let spacing: CGFloat = 6
            let totalSpacing = spacing * CGFloat(columns - 1)
            let dotSize = max(4, (proxy.size.width - totalSpacing) / CGFloat(columns))
            let gridItems = Array(repeating: GridItem(.fixed(dotSize), spacing: spacing), count: columns)

            ScrollView {
                LazyVGrid(columns: gridItems, spacing: spacing) {
                    ForEach(viewModel.days) { day in
                        Button {
                            selectedDay = day
                        } label: {
                            Circle()
                                .fill(day.isComplete ? AppColors.accent : AppColors.surface)
                                .frame(width: dotSize, height: dotSize)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(dayAccessibilityLabel(for: day))
                    }
                }
                .padding(.vertical, 8)
            }
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
