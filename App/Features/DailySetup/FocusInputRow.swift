import SwiftUI

struct FocusInputRow: View {
    @Binding var draft: TenXStore.FocusDraft
    let placeholder: String
    let isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $draft.title, axis: .vertical)
            .font(.tenxLargeBody)
            .foregroundStyle(Color.tenxTextPrimary)
            .textInputAutocapitalization(.sentences)
            .lineLimit(1...3)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.tenxSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                isFocused ? Color.tenxTextMuted : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
    }
}
