import SwiftUI

struct YearProgressPreviewTileView: View {
    let year: Int
    let days: [YearDayDot]
    let summary: YearProgressSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            YearProgressMiniGridView(days: days)
                .frame(height: 96)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            footer
        }
        .padding(20)
        .tenxGlassCard(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Year Progress")
                    .font(.tenxCaption)
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(verbatim: String(year))
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            Image(systemName: "calendar")
                .font(.tenxIconMedium)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var footer: some View {
        HStack {
            Text(footerText)
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            HStack(spacing: 6) {
                Text("View year")
                    .font(.tenxCaption)
                    .foregroundStyle(AppColors.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.tenxMicroSemibold)
                    .foregroundStyle(AppColors.textMuted)
            }
        }
    }

    private var footerText: String {
        guard summary.totalDays > 0 else { return "Year data will appear here" }
        return "\(summary.daysLeft)d left • \(String(format: "%.0f%%", summary.yearCompletionPercent))"
    }
}

private struct YearProgressMiniGridView: View {
    let days: [YearDayDot]

    var body: some View {
        GeometryReader { proxy in
            let inset: CGFloat = 6
            let spacingXMin: CGFloat = 4
            let spacingYMin: CGFloat = 3
            let availableSize = CGSize(width: max(0, proxy.size.width - inset * 2),
                                       height: max(0, proxy.size.height - inset * 2))
            let layout = YearProgressGridLayout.layout(
                for: availableSize,
                totalDays: days.count,
                spacingX: spacingXMin,
                spacingYMin: spacingYMin,
                minColumns: 18,
                maxColumns: 28
            )
            let spacingX = layout.columns > 1
                ? max(spacingXMin,
                      (availableSize.width - CGFloat(layout.columns) * layout.dotSize) / CGFloat(layout.columns - 1))
                : 0
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacingX), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: layout.spacingY) {
                ForEach(days) { day in
                    Circle()
                        .fill(day.status.color)
                        .frame(width: layout.dotSize, height: layout.dotSize)
                }
            }
            .frame(width: availableSize.width, height: availableSize.height, alignment: .topLeading)
            .padding(inset)
        }
    }
}
