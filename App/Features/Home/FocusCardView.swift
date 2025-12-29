import SwiftUI

struct FocusCardView: View {
    let focus: DailyFocus
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .strokeBorder(
                        focus.isCompleted ? Color.tenxComplete : Color.tenxTextMuted,
                        lineWidth: 1.5
                    )
                    .background(
                        Circle()
                            .fill(focus.isCompleted ? Color.tenxComplete : Color.clear)
                    )
                    .frame(width: 24, height: 24)
                    .overlay {
                        if focus.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.tenxBackground)
                        }
                    }

                Text(focus.title)
                    .font(.tenxLargeBody)
                    .foregroundStyle(focus.isCompleted ? Color.tenxTextSecondary : Color.tenxTextPrimary)
                    .strikethrough(focus.isCompleted, color: Color.tenxTextSecondary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(FocusCardButtonStyle())
    }
}
