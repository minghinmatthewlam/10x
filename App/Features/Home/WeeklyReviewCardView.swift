import SwiftUI

struct WeeklyReviewCardView: View {
    let summary: WeeklySummary
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly completion")
                        .font(.tenxTitle)
                        .foregroundStyle(theme.textPrimary)
                    if let badgeText {
                        Text(badgeText)
                            .font(.tenxCaption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.textPrimary.opacity(0.12))
                            .clipShape(Capsule())
                            .foregroundStyle(theme.textPrimary)
                    }
                }
                Spacer()
                Text("\(completionPercent)%")
                    .font(.tenxSmall)
                    .foregroundStyle(theme.textSecondary)
            }

            Text("You completed \(summary.completed) of \(summary.total) focuses (\(completionPercent)%).")
                .font(.tenxSmall)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(20)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var completionPercent: Int {
        guard summary.total > 0 else { return 0 }
        return Int((Double(summary.completed) / Double(summary.total)) * 100)
    }

    private var badgeText: String? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? nil : "Week in progress"
    }

}
