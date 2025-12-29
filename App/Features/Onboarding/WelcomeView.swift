import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("10x")
                .font(.tenxTitle)
                .foregroundStyle(Color.tenxAccent)

            Text("Pick three goals. Every day, choose three focuses aligned to those goals.")
                .font(.tenxBody)
                .foregroundStyle(Color.tenxTextPrimary)

            VStack(alignment: .leading, spacing: 12) {
                Label("Exactly three focuses per day", systemImage: "checkmark.circle.fill")
                Label("Streak stays alive if you complete at least one", systemImage: "flame.fill")
                Label("No noise. Just progress.", systemImage: "moon.stars.fill")
            }
            .font(.tenxBody)
            .foregroundStyle(Color.tenxTextSecondary)

            Spacer()
        }
        .padding(32)
        .background(Color.tenxBackground)
    }
}
