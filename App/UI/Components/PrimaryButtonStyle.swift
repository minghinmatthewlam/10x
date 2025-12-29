import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody.weight(.medium))
            .foregroundStyle(Color.tenxBackground)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.tenxAccent.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(Capsule())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody.weight(.medium))
            .foregroundStyle(Color.tenxTextSecondary.opacity(configuration.isPressed ? 0.6 : 1))
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxSmall)
            .foregroundStyle(Color.tenxTextMuted.opacity(configuration.isPressed ? 0.5 : 1))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.tenxSurface.opacity(configuration.isPressed ? 0.5 : 1))
            .clipShape(Capsule())
    }
}
