import SwiftUI

struct WeeklyReviewCardView: View {
    let summary: WeeklySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly progress")
                        .font(.tenxTitle)
                        .foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
                Text("\(completionPercent)%")
                    .font(.tenxSmall)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text("You completed \(summary.completed) of \(summary.total) focuses (\(completionPercent)%).")
                .font(.tenxSmall)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(20)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var completionPercent: Int {
        guard summary.total > 0 else { return 0 }
        return Int((Double(summary.completed) / Double(summary.total)) * 100)
    }
}
