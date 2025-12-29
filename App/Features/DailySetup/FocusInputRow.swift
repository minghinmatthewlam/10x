import SwiftUI

struct FocusInputRow: View {
    @Binding var draft: TenXStore.FocusDraft
    let goals: [TenXGoal]
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Focus \(index + 1)")
                .font(.tenxCaption)
                .foregroundStyle(Color.tenxTextSecondary)

            TextField("What matters most?", text: $draft.title)
                .textInputAutocapitalization(.sentences)
                .padding(12)
                .background(Color.tenxCard)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Picker("Goal", selection: $draft.goalUUID) {
                Text("Select goal").tag(UUID?.none)
                ForEach(goals, id: \.uuid) { goal in
                    Text(goal.title).tag(Optional(goal.uuid))
                }
            }
            .pickerStyle(.menu)
        }
    }
}
