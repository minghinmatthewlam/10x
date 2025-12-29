import SwiftUI

struct StreakBadgeView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundStyle(streak > 0 ? Color.tenxTextPrimary : Color.tenxTextMuted)
            Text("\(streak)")
                .font(.tenxBody.monospacedDigit())
                .foregroundStyle(streak > 0 ? Color.tenxTextPrimary : Color.tenxTextMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.tenxSurface)
        .clipShape(Capsule())
    }
}
