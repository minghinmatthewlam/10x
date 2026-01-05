import SwiftUI

struct FocusDragPreviewRow: View {
    let focus: DailyFocus

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .strokeBorder(
                    focus.isCompleted ? AppColors.complete : AppColors.textMuted,
                    lineWidth: 1.5
                )
                .background(
                    Circle()
                        .fill(focus.isCompleted ? AppColors.complete : Color.clear)
                )
                .frame(width: 24, height: 24)
                .overlay {
                    if focus.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.tenxTinyBold)
                            .foregroundStyle(AppColors.background)
                    }
                }

            Text(focus.title)
                .font(.tenxLargeBody)
                .foregroundStyle(focus.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)
    }
}
