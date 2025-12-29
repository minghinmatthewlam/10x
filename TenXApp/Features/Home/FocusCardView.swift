import SwiftUI

struct FocusCardView: View {
    let focus: DailyFocus
    let goalTitle: String?
    let onToggle: () -> Void

    @State private var showConfirm = false

    var body: some View {
        Button {
            if focus.isCompleted {
                showConfirm = true
            } else {
                onToggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(focus.isCompleted ? Color.tenxAccent : Color.tenxTextSecondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(focus.title)
                        .font(.tenxBody)
                        .foregroundStyle(Color.tenxTextPrimary)
                    if let goalTitle {
                        Text(goalTitle)
                            .font(.tenxCaption)
                            .foregroundStyle(Color.tenxTextSecondary)
                    }
                }
                Spacer()
            }
            .padding(16)
        }
        .buttonStyle(FocusCardButtonStyle())
        .confirmationDialog("Mark focus as incomplete?", isPresented: $showConfirm) {
            Button("Mark Incomplete", role: .destructive) {
                onToggle()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
