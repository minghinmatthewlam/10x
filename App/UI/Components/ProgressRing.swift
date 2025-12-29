import SwiftUI

struct ProgressRing: View {
    let progress: Double
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.card.opacity(0.4), lineWidth: 8)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(theme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
