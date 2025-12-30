import SwiftUI

struct ProgressSummaryCardView: View {
    let completed: Int
    let total: Int
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Progress")
                    .font(.tenxTitle)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.tenxSmall)
                    .foregroundStyle(theme.textSecondary)
            }

            progressBar

            Text(statusText)
                .font(.tenxCaption)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(20)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let ratio = total == 0 ? 0 : CGFloat(completed) / CGFloat(total)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.surface)
                    .frame(height: 8)

                Capsule()
                    .fill(theme.accent)
                    .frame(width: width * ratio, height: 8)
            }
        }
        .frame(height: 8)
    }

    private var statusText: String {
        guard total > 0 else { return "Set your focuses to begin" }
        if completed >= min(2, total) {
            return "Streak active"
        }
        let remaining = max(0, min(2, total) - completed)
        return "\(remaining) more needed for streak"
    }
}
