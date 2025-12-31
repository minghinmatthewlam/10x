import SwiftUI

struct ThemedRootView: View {
    @EnvironmentObject private var theme: ThemeController
    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        RootView()
            .tenxTheme()
            .onAppear {
                theme.handleSystemSchemeChange(systemScheme)
            }
            .onChange(of: systemScheme) { _, newValue in
                theme.handleSystemSchemeChange(newValue)
            }
    }
}
