import SwiftUI

struct FocusInlineEditRow: View {
    let focus: DailyFocus
    let onToggle: () -> Void
    let onTitleCommit: (String) -> Void
    let onTagChange: (FocusTag?) -> Void

    @FocusState private var isFocused: Bool
    @State private var title: String

    init(focus: DailyFocus,
         onToggle: @escaping () -> Void,
         onTitleCommit: @escaping (String) -> Void,
         onTagChange: @escaping (FocusTag?) -> Void) {
        self.focus = focus
        self.onToggle = onToggle
        self.onTitleCommit = onTitleCommit
        self.onTagChange = onTagChange
        _title = State(initialValue: focus.title)
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
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
                                .font(.tenxTinyBold)
                                .foregroundStyle(AppColors.background)
                        }
                    }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 10) {
                TextField("Focus", text: $title, axis: .vertical)
                    .font(.tenxLargeBody)
                    .foregroundStyle(focus.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                    .strikethrough(focus.isCompleted, color: AppColors.textSecondary)
                    .textInputAutocapitalization(.sentences)
                    .lineLimit(1...3)
                    .focused($isFocused)
                    .onSubmit(commitIfNeeded)
                    .onChange(of: isFocused) { _, focused in
                        if !focused {
                            commitIfNeeded()
                        }
                    }
                    .onChange(of: focus.title) { _, newValue in
                        if !isFocused {
                            title = newValue
                        }
                    }

                FocusTagPickerView(tag: Binding(get: {
                    focus.tag
                }, set: { newTag in
                    onTagChange(newTag)
                }))
            }
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

    private func commitIfNeeded() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            title = focus.title
            return
        }
        if trimmed.count > AppConstants.maxFocusTitleLength {
            let truncated = String(trimmed.prefix(AppConstants.maxFocusTitleLength))
            title = truncated
            onTitleCommit(truncated)
            return
        }
        if trimmed != focus.title {
            onTitleCommit(trimmed)
        }
    }
}
