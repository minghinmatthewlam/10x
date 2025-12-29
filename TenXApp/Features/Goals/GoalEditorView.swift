import SwiftUI

struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String

    let onSave: (String) -> Void

    init(title: String = "", onSave: @escaping (String) -> Void) {
        _title = State(initialValue: title)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Goal title", text: $title)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .navigationTitle("Goal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(title)
                        dismiss()
                    }
                }
            }
        }
    }
}
