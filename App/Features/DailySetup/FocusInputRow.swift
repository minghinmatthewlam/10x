import SwiftUI

struct FocusInputRow: View {
    @Binding var draft: TenXStore.FocusDraft
    let placeholder: String
    let isFocused: Bool
    let commitOnBlur: Bool
    let onCommit: (() -> Void)?
    let onRequestBlur: (() -> Void)?

    init(draft: Binding<TenXStore.FocusDraft>,
         placeholder: String,
         isFocused: Bool,
         commitOnBlur: Bool = false,
         onCommit: (() -> Void)? = nil,
         onRequestBlur: (() -> Void)? = nil) {
        _draft = draft
        self.placeholder = placeholder
        self.isFocused = isFocused
        self.commitOnBlur = commitOnBlur
        self.onCommit = onCommit
        self.onRequestBlur = onRequestBlur
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $draft.title)
                .font(.tenxLargeBody)
                .foregroundStyle(AppColors.textPrimary)
                .textInputAutocapitalization(.sentences)
                .lineLimit(1)
                .truncationMode(.tail)
                .submitLabel(.done)
                .onSubmit {
                    onCommit?()
                    onRequestBlur?()
                }
                .onChange(of: isFocused) { _, focused in
                    if commitOnBlur && !focused {
                        onCommit?()
                    }
                }
                .layoutPriority(1)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isFocused ? AppColors.textMuted : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}
