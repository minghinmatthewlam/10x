import SwiftUI

struct YearProgressShareCardView: View {
    let year: Int
    let summary: YearProgressSummary
    let days: [YearDayDot]

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.background, AppColors.surface],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 28) {
                Text("10X")
                    .font(.tenxDisplay)
                    .foregroundStyle(AppColors.textPrimary)

                Text(verbatim: "\(year) Year Progress")
                    .font(.tenxDisplaySecondary)
                    .foregroundStyle(AppColors.accent)

                HStack(spacing: 18) {
                    metricBlock(title: "Completed", value: "\(summary.completedDays)")
                    metricBlock(title: "Year", value: String(format: "%.1f%%", summary.yearCompletionPercent))
                    metricBlock(title: "Days Left", value: "\(summary.daysLeft)")
                }

                YearProgressShareGridView(days: days)
                    .frame(height: 420)
                    .padding(16)
                    .background(AppColors.surface.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                Text("Build your streak, one day at a time.")
                    .font(.tenxShareBody)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(80)
        }
        .frame(width: 1200, height: 1200)
        .clipShape(RoundedRectangle(cornerRadius: 80, style: .continuous))
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            Text(value)
                .font(.tenxHero)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

private struct YearProgressShareGridView: View {
    let days: [YearDayDot]

    var body: some View {
        GeometryReader { proxy in
            let spacingX: CGFloat = 5
            let spacingYMin: CGFloat = 4
            let layout = YearProgressGridLayout.layout(
                for: proxy.size,
                totalDays: days.count,
                spacingX: spacingX,
                spacingYMin: spacingYMin,
                minColumns: 24,
                maxColumns: 32
            )
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacingX), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: layout.spacingY) {
                ForEach(days) { day in
                    Circle()
                        .fill(day.status.color)
                        .frame(width: layout.dotSize, height: layout.dotSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
