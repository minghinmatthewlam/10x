import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody)
            .foregroundStyle(Color.black)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.tenxAccent.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
