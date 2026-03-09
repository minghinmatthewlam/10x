import SwiftUI
import TenXShared

struct YearProgressPreviewTileView: View {
    let year: Int
    let days: [YearDayDot]
    let summary: YearProgressSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            YearProgressDotGrid(colors: days.map { $0.status.color },
                                inset: 6,
                                spacingXMin: 4,
                                spacingYMin: 3,
                                minColumns: 18,
                                maxColumns: 28)
                .frame(height: 96)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)

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
                .accessibilityHidden(true)
        }
    }

    private var footer: some View {
        HStack {
            Text(footerText)
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityLabel(footerAccessibilityLabel)

            Spacer()

            HStack(spacing: 6) {
                Text("View year")
                    .font(.tenxCaption)
                    .foregroundStyle(AppColors.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.tenxMicroSemibold)
                    .foregroundStyle(AppColors.textMuted)
                    .accessibilityHidden(true)
            }
        }
    }

    private var footerText: String {
        guard summary.totalDays > 0 else { return "Year data will appear here" }
        return "\(summary.daysLeft)d left • \(String(format: "%.0f%%", summary.yearCompletionPercent))"
    }

    private var footerAccessibilityLabel: String {
        guard summary.totalDays > 0 else { return "Year data will appear here" }
        return "\(summary.daysLeft) days left, \(String(format: "%.0f", summary.yearCompletionPercent)) percent complete"
    }
}
