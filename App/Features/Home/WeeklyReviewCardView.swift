import SwiftUI

struct WeeklyReviewCardView: View {
    let summary: WeeklySummary
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This week")
                    .font(.tenxTitle)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(summary.completed)/\(summary.total)")
                    .font(.tenxSmall)
                    .foregroundStyle(theme.textSecondary)
            }

            Text("\(summary.daysWithCompletion) of 7 days kept your streak alive")
                .font(.tenxSmall)
                .foregroundStyle(theme.textSecondary)

            if summary.tagSummaries.isEmpty {
                Text("Add tags to see focus patterns.")
                    .font(.tenxSmall)
                    .foregroundStyle(theme.textMuted)
            } else {
                VStack(spacing: 12) {
                    ForEach(summary.tagSummaries) { tag in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(tag.label)
                                    .font(.tenxSmall)
                                    .foregroundStyle(theme.textPrimary)
                                Spacer()
                                Text("\(tag.completed)/\(tag.total)")
                                    .font(.tenxSmall)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            ProgressView(value: Double(tag.completed), total: Double(tag.total))
                                .tint(theme.accent)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
