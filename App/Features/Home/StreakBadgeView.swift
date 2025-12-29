import SwiftUI

struct StreakBadgeView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(streak > 0 ? Color.tenxAccent : Color.tenxTextSecondary)
            Text("\(streak)")
                .font(.tenxBody)
                .foregroundStyle(Color.tenxTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.tenxCard)
        .clipShape(Capsule())
    }
}
