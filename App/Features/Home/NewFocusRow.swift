import SwiftUI

struct NewFocusRow: View {
    let placeholder: String
    let onAdd: (String, FocusTag?) -> Void

    @Environment(\.tenxTheme) private var theme
    @FocusState private var isFocused: Bool
    @State private var title: String = ""
    @State private var tag: FocusTag?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(placeholder, text: $title, axis: .vertical)
                .font(.tenxLargeBody)
                .foregroundStyle(theme.textPrimary)
                .textInputAutocapitalization(.sentences)
                .lineLimit(1...3)
                .focused($isFocused)
                .onSubmit { commitIfNeeded() }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        commitIfNeeded()
                    }
                }

            FocusTagPickerView(tag: $tag)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(theme.textMuted.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func commitIfNeeded() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let safeTitle = trimmed.count > AppConstants.maxFocusTitleLength
            ? String(trimmed.prefix(AppConstants.maxFocusTitleLength))
            : trimmed
        onAdd(safeTitle, tag)
        title = ""
        tag = nil
        isFocused = true
    }
}
