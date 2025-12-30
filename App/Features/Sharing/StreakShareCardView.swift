import SwiftUI

struct StreakShareCardView: View {
    let streak: Int

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.background, AppColors.surface],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 20) {
                Text("10x")
                    .font(.tenxDisplay)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Streak \(streak) days")
                    .font(.tenxDisplaySecondary)
                    .foregroundStyle(AppColors.accent)

                Text("1-3 focuses a day. Complete two to keep it alive.")
                    .font(.tenxShareBody)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(80)
        }
        .frame(width: 1200, height: 1200)
        .clipShape(RoundedRectangle(cornerRadius: 80, style: .continuous))
    }
}
