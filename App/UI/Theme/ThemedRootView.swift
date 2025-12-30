import SwiftUI

struct ThemedRootView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

    var body: some View {
        RootView()
            .environment(\.tenxTheme, themeManager.theme.palette(for: resolvedColorScheme))
    }

    private var resolvedColorScheme: ColorScheme {
        guard let mode = AppearanceMode(rawValue: appearanceMode) else { return colorScheme }
        switch mode {
        case .system:
            return colorScheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
