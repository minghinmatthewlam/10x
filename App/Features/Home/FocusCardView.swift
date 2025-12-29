import SwiftUI

struct FocusCardView: View {
    let focus: DailyFocus
    let onToggle: () -> Void

    @Environment(\.tenxTheme) private var theme

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .strokeBorder(
                        focus.isCompleted ? theme.complete : theme.textMuted,
                        lineWidth: 1.5
                    )
                    .background(
                        Circle()
                            .fill(focus.isCompleted ? theme.complete : Color.clear)
                    )
                    .frame(width: 24, height: 24)
                    .overlay {
                        if focus.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(theme.background)
                        }
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(focus.title)
                        .font(.tenxLargeBody)
                        .foregroundStyle(focus.isCompleted ? theme.textSecondary : theme.textPrimary)
                        .strikethrough(focus.isCompleted, color: theme.textSecondary)
                        .multilineTextAlignment(.leading)

                    if let tag = focus.tag {
                        Text(tag.label)
                            .font(.tenxSmall)
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(FocusCardButtonStyle())
    }
}
