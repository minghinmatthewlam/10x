import SwiftUI

struct StreakCardView: View {
    let streak: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Streak")
                        .font(.tenxCaption)
                        .foregroundStyle(AppColors.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(streak)")
                            .font(.tenxStat)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("days")
                            .font(.tenxSmall)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                Spacer()

                Image(systemName: "flame.fill")
                    .font(.tenxIconLarge)
                    .foregroundStyle(streak > 0 ? Color.orange : AppColors.textMuted)
            }

            Text("Complete 2/3 focuses to increase your streak.")
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.card,
                    AppColors.card.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(AppColors.textMuted.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
