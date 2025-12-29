import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.tenxTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody.weight(.medium))
            .foregroundStyle(theme.background)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(theme.accent.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(Capsule())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.tenxTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody.weight(.medium))
            .foregroundStyle(theme.textSecondary.opacity(configuration.isPressed ? 0.6 : 1))
    }
}

struct GhostButtonStyle: ButtonStyle {
    @Environment(\.tenxTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxSmall)
            .foregroundStyle(theme.textMuted.opacity(configuration.isPressed ? 0.5 : 1))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(theme.surface.opacity(configuration.isPressed ? 0.5 : 1))
            .clipShape(Capsule())
    }
}
