import SwiftUI

struct WeeklyReviewCardView: View {
    let summary: WeeklySummary
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly completion")
                    .font(.tenxTitle)
                    .foregroundStyle(theme.textPrimary)
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

}
