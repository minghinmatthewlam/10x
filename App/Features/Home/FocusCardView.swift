import SwiftUI

struct FocusCardView: View {
    let focus: DailyFocus
    let onToggle: () -> Void
    let onTagChange: (FocusTag?) -> Void

    @Environment(\.tenxTheme) private var theme

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
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

                    Text(focus.title)
                        .font(.tenxLargeBody)
                        .foregroundStyle(focus.isCompleted ? theme.textSecondary : theme.textPrimary)
                        .strikethrough(focus.isCompleted, color: theme.textSecondary)
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
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
