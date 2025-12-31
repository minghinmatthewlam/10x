import SwiftUI

struct NewFocusRow: View {
    let placeholder: String
    let onAdd: (String, FocusTag?) -> Void

    @FocusState private var isFocused: Bool
    @State private var title: String = ""
    @State private var tag: FocusTag?

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $title)
                .font(.tenxLargeBody)
                .foregroundStyle(AppColors.textPrimary)
                .textInputAutocapitalization(.sentences)
                .lineLimit(1)
                .truncationMode(.tail)
                .submitLabel(.done)
                .focused($isFocused)
                .onSubmit {
                    commitIfNeeded()
                    isFocused = false
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        commitIfNeeded()
                    }
                }
                .layoutPriority(1)

            Spacer(minLength: 8)

            FocusTagPickerView(tag: $tag)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AppColors.textMuted.opacity(0.15), lineWidth: 1)
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
        isFocused = false
    }
}
