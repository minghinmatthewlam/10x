import SwiftUI

struct FocusEditView: View {
    @Environment(\.dismiss) private var dismiss

    let focus: DailyFocus
    let goals: [TenXGoal]
    let onSave: (String, UUID) throws -> Void

    @State private var title: String
    @State private var selectedGoalUUID: UUID?
    @State private var errorMessage: String?

    init(focus: DailyFocus, goals: [TenXGoal], onSave: @escaping (String, UUID) throws -> Void) {
        self.focus = focus
        self.goals = goals
        self.onSave = onSave
        _title = State(initialValue: focus.title)
        _selectedGoalUUID = State(initialValue: focus.goal?.uuid ?? goals.first?.uuid)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus") {
                    TextField("Focus title", text: $title)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Goal") {
                    Picker("Goal", selection: $selectedGoalUUID) {
                        ForEach(goals, id: \.uuid) { goal in
                            Text(goal.title).tag(Optional(goal.uuid))
                        }
                    }
                }
            }
            .navigationTitle("Edit Focus")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
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
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && selectedGoalUUID != nil
    }

    private func save() {
        guard let goalUUID = selectedGoalUUID else { return }
        do {
            try onSave(title, goalUUID)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
