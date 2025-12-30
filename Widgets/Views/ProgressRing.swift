import SwiftUI
import TenXShared

struct ProgressRing: View {
    let progress: Double
    let palette: ThemePalette

    var body: some View {
        ZStack {
            Circle()
                .stroke(palette.textPrimary.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(palette.textPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
