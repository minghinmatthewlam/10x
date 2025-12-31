import SwiftUI

private struct TenXThemeModifier: ViewModifier {
    @EnvironmentObject private var theme: ThemeController

    func body(content: Content) -> some View {
        content.preferredColorScheme(theme.preferredColorScheme)
    }
}

extension View {
    func tenxTheme() -> some View {
        modifier(TenXThemeModifier())
    }
}
