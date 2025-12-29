import SwiftUI

struct IncompleteDayPromptView: View {
    let unfinished: [TenXStore.FocusDraft]
    let onContinue: () -> Void
    let onFreshStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yesterday wasn’t finished.")
                .font(.tenxTitle)
                .foregroundStyle(Color.tenxTextPrimary)

            Text("Pick up where you left off or start fresh.")
                .font(.tenxBody)
                .foregroundStyle(Color.tenxTextSecondary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(unfinished.enumerated()), id: \.offset) { _, draft in
                    Text("• \(draft.title)")
                        .font(.tenxBody)
                        .foregroundStyle(Color.tenxTextPrimary)
                }
            }

            HStack(spacing: 12) {
                Button("Continue") { onContinue() }
                    .buttonStyle(PrimaryButtonStyle())

                Button("Start Fresh") { onFreshStart() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .background(Color.tenxCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
