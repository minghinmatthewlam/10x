import SwiftUI

struct FocusTagPickerView: View {
    @Binding var tag: FocusTag?

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
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.surface.opacity(0.8))
            .clipShape(Capsule())
        }
    }
}
