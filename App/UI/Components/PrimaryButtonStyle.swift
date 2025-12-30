import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody.weight(.medium))
            .foregroundStyle(AppColors.background)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(AppColors.accent.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(Capsule())
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxBody.weight(.medium))
            .foregroundStyle(AppColors.textSecondary.opacity(configuration.isPressed ? 0.6 : 1))
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tenxSmall)
            .foregroundStyle(AppColors.textMuted.opacity(configuration.isPressed ? 0.5 : 1))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppColors.surface.opacity(configuration.isPressed ? 0.5 : 1))
            .clipShape(Capsule())
    }
}
