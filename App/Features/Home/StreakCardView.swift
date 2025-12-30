import SwiftUI

struct StreakCardView: View {
    let streak: Int
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Streak")
                        .font(.tenxCaption)
                        .foregroundStyle(theme.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(streak)")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(theme.textPrimary)
                        Text("days")
                            .font(.tenxSmall)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                Spacer()

                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(streak > 0 ? Color.orange : theme.textMuted)
            }

            Text("Complete two out of three to increase your streak or maintain your streak.")
                .font(.tenxCaption)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    theme.card,
                    theme.card.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(theme.textMuted.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
