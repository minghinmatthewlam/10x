import SwiftUI
import SwiftData

@main
struct TenXApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    private let container = ModelContainerFactory.make()

    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .environment(\.tenxTheme, themeManager.theme.palette)
                .modelContainer(container)
                .preferredColorScheme(AppAppearance.colorScheme(for: appearanceMode))
                .onOpenURL { url in
                    appState.handle(url: url)
                }
        }
    }
}
