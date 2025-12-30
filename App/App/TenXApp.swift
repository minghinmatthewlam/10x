import SwiftUI
import SwiftData

@main
struct TenXApp: App {
    @StateObject private var appState = AppState()
    private let container = ModelContainerFactory.make()

    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            ThemedRootView()
                .environmentObject(appState)
                .modelContainer(container)
                .preferredColorScheme(AppAppearance.colorScheme(for: appearanceMode))
                .onOpenURL { url in
                    appState.handle(url: url)
                }
        }
    }
}
