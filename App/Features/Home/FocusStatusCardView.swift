import SwiftUI

struct FocusStatusCardView: View {
    let status: FocusStatus
    let streak: Int
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Streak")
                        .font(.tenxCaption)
                        .foregroundStyle(AppColors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(streak)")
                            .font(.tenxStat)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("days")
                            .font(.tenxSmall)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "flame.fill")
                    .font(.tenxIconLarge)
                    .foregroundStyle(streak > 0 ? Color.orange : AppColors.textMuted)
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(status.message)
                    .font(.tenxSmall)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .layoutPriority(1)

                Spacer()

                Button {
                    onShare()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.tenxIconSmall)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(AppColors.surface.opacity(0.7))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share")
            }
        }
        .padding(20)
        .tenxGlassCard(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
