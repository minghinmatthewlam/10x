import SwiftUI

struct FocusInputRow: View {
    @Binding var draft: TenXStore.FocusDraft
    let placeholder: String
    let isFocused: Bool
    let onCommit: (() -> Void)?

    @Environment(\.tenxTheme) private var theme

    init(draft: Binding<TenXStore.FocusDraft>,
         placeholder: String,
         isFocused: Bool,
         onCommit: (() -> Void)? = nil) {
        _draft = draft
        self.placeholder = placeholder
        self.isFocused = isFocused
        self.onCommit = onCommit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(placeholder, text: $draft.title, axis: .vertical)
                .font(.tenxLargeBody)
                .foregroundStyle(theme.textPrimary)
                .textInputAutocapitalization(.sentences)
                .lineLimit(1...3)
                .onSubmit {
                    onCommit?()
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        onCommit?()
                    }
                }

            FocusTagPickerView(tag: $draft.tag)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isFocused ? theme.textMuted : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}
