import SwiftUI

struct FocusEditView: View {
    @Environment(\.dismiss) private var dismiss

    let focus: DailyFocus
    let onSave: (String, FocusTag?) throws -> Void

    @State private var title: String
    @State private var tag: FocusTag?
    @State private var errorMessage: String?

    init(focus: DailyFocus, onSave: @escaping (String, FocusTag?) throws -> Void) {
        self.focus = focus
        self.onSave = onSave
        _title = State(initialValue: focus.title)
        _tag = State(initialValue: focus.tag)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Edit focus")
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textPrimary)

                TextField("What matters most?", text: $title)
                    .font(.tenxLargeBody)
                    .foregroundStyle(AppColors.textPrimary)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .onSubmit {
                        save()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColors.surface)
                    )

                FocusTagPickerView(tag: $tag)

                Spacer()

                Button("Save") {
                    save()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.4)
            }
            .padding(24)
            .background(AppColors.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.tenxIconButton)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .toolbarBackground(AppColors.background, for: .navigationBar)
        }
        .alert("Oops", isPresented: Binding(get: {
            errorMessage != nil
        }, set: { isPresented in
            if !isPresented { errorMessage = nil }
        })) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        do {
            try onSave(title, tag)
            Haptics.mediumImpact()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
