import SwiftUI

struct FocusTagPickerView: View {
    @Binding var tag: FocusTag?
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        Menu {
            Button("No Tag") { tag = nil }
            ForEach(FocusTag.allCases) { tag in
                Button(tag.label) {
                    self.tag = tag
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(tag?.label ?? "Add tag")
                    .font(.tenxSmall)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(theme.surface.opacity(0.8))
            .clipShape(Capsule())
        }
    }
}
