import SwiftUI

struct ThemedRootView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RootView()
            .environment(\.tenxTheme, themeManager.theme.palette(for: colorScheme))
    }
}
