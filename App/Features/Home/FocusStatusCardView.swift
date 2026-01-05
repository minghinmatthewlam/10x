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
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.tenxIconSmall)
                        Text("Share")
                            .font(.tenxTinySemibold)
                    }
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.surface.opacity(0.7))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .tenxGlassCard(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
