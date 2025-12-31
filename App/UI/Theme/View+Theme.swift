import SwiftUI

private struct TenXThemeModifier: ViewModifier {
    @EnvironmentObject private var theme: ThemeController
    @Environment(\.colorScheme) private var systemScheme

    func body(content: Content) -> some View {
        content.preferredColorScheme(theme.resolvedColorScheme(system: systemScheme))
    }
}

extension View {
    func tenxTheme() -> some View {
        modifier(TenXThemeModifier())
    }
}
