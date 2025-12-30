import SwiftUI

struct WelcomeView: View {
    let onBegin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Spacer()

            VStack(alignment: .leading, spacing: 32) {
                Text("10x")
                    .font(.tenxLogo)
                    .foregroundStyle(AppColors.textPrimary)

                Text("What would make\ntoday extraordinary?")
                    .font(.tenxHero)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(4)

                Text("Each day, choose 1-3 focuses.\nComplete two to keep your streak alive.")
                    .font(.tenxBody)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            Spacer()
            Spacer()

            Button("Begin") {
                onBegin()
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: .infinity)

            Spacer()
                .frame(height: 48)
        }
        .padding(.horizontal, 32)
        .background(AppColors.background)
    }
}
