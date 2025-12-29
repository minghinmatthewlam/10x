import SwiftUI

struct StreakBadgeView: View {
    let streak: Int
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundStyle(streak > 0 ? theme.textPrimary : theme.textMuted)
            Text("\(streak)")
                .font(.tenxBody.monospacedDigit())
                .foregroundStyle(streak > 0 ? theme.textPrimary : theme.textMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(theme.surface)
        .clipShape(Capsule())
    }
}
