import SwiftUI

struct FocusChecklistRow: View {
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .strokeBorder(isCompleted ? AppColors.complete : AppColors.textMuted,
                              lineWidth: 1.5)
                .background(
                    Circle()
                        .fill(isCompleted ? AppColors.complete : Color.clear)
                )
                .frame(width: 18, height: 18)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.tenxTinyBold)
                            .foregroundStyle(AppColors.background)
                    }
                }

            Text(title)
                .font(.tenxBody)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
