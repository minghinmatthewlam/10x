import SwiftUI
import TenXShared

struct StreakShareCardView: View {
    let streak: Int
    let theme: ThemePalette

    var body: some View {
        ZStack {
            LinearGradient(colors: [theme.background, theme.surface],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 20) {
                Text("10x")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)

                Text("Streak \(streak) days")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(theme.accent)

                Text("1-3 focuses a day. One completed keeps it alive.")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(80)
        }
        .frame(width: 1200, height: 1200)
        .clipShape(RoundedRectangle(cornerRadius: 80, style: .continuous))
    }
}
