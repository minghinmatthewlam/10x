import SwiftUI

struct FocusEditView: View {
    @Environment(\.dismiss) private var dismiss

    let focus: DailyFocus
    let onSave: (String) throws -> Void

    @State private var title: String
    @State private var errorMessage: String?

    init(focus: DailyFocus, onSave: @escaping (String) throws -> Void) {
        self.focus = focus
        self.onSave = onSave
        _title = State(initialValue: focus.title)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Edit focus")
                    .font(.tenxTitle)
                    .foregroundStyle(Color.tenxTextPrimary)

                TextField("What matters most?", text: $title, axis: .vertical)
                    .font(.tenxLargeBody)
                    .foregroundStyle(Color.tenxTextPrimary)
                    .textInputAutocapitalization(.sentences)
                    .lineLimit(1...4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.tenxSurface)
                    )

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
            .background(Color.tenxBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.tenxTextSecondary)
                    }
                }
            }
            .toolbarBackground(Color.tenxBackground, for: .navigationBar)
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
            try onSave(title)
            Haptics.mediumImpact()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
