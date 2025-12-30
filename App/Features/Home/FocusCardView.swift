import SwiftUI

struct FocusCardView: View {
    let focus: DailyFocus
    let onToggle: () -> Void
    let onTagChange: (FocusTag?) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                HStack(spacing: 16) {
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
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.background)
                            }
                        }

                    Text(focus.title)
                        .font(.tenxLargeBody)
                        .foregroundStyle(focus.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                        .strikethrough(focus.isCompleted, color: AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            FocusTagPickerView(tag: Binding(get: {
                focus.tag
            }, set: { newTag in
                onTagChange(newTag)
            }))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(AppColors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColors.textMuted.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
