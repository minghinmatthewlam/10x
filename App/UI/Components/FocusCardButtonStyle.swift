import SwiftUI

struct FocusCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
