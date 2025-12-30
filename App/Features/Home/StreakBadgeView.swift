import SwiftUI

struct StreakBadgeView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.tenxIconSmall)
                .foregroundStyle(streak > 0 ? AppColors.textPrimary : AppColors.textMuted)
            Text("\(streak)")
                .font(.tenxBody.monospacedDigit())
                .foregroundStyle(streak > 0 ? AppColors.textPrimary : AppColors.textMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.surface)
        .clipShape(Capsule())
    }
}
