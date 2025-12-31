import SwiftUI

struct FocusInputRow: View {
    @Binding var draft: TenXStore.FocusDraft
    let placeholder: String
    let isFocused: Bool
    let onCommit: (() -> Void)?

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
            HStack(alignment: .top, spacing: 12) {
                TextField(placeholder, text: $draft.title, axis: .vertical)
                    .font(.tenxLargeBody)
                    .foregroundStyle(AppColors.textPrimary)
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
                if onCommit != nil {
                    Button {
                        onCommit?()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.tenxIconMedium)
                            .foregroundStyle(canCommit ? AppColors.accent : AppColors.textMuted)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canCommit)
                    .accessibilityLabel("Save focus")
                }
            }

            HStack {
                Spacer()
                FocusTagPickerView(tag: $draft.tag)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
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

    private var canCommit: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
